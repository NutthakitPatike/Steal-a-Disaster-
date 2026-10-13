--!strict
-- P1-03: session-fenced profile coordinator with a supplied UpdateAsync adapter.
-- IMPORTANT: no production DataStore is opened by this module; bootstrap does not require it.
-- UpdateAsync callbacks are pure and may be invoked more than once.
local HttpService = game:GetService("HttpService")
local Schema = require(script.Parent:WaitForChild("ProfileSchema"))
local Transactions = require(script.Parent:WaitForChild("Transactions"))

local PlayerData = {}
PlayerData.__index = PlayerData

function PlayerData.new(adapter: any)
    assert(type(adapter) == "table" and type(adapter.UpdateAsync) == "function", "UpdateAsync adapter required")
    return setmetatable({
        adapter = adapter,
        sessions = {},
        snapshots = {},
        pending = {},
        busy = {},
        issuedTokens = {},
    }, PlayerData)
end

local function goodUserId(userId: any): boolean
    return type(userId) == "number" and userId > 0 and userId % 1 == 0
        and userId <= 9007199254740991
end

local function validTime(now: any): boolean
    return type(now) == "number" and now % 1 == 0 and now >= 0 and now <= 9999999000
end

local function key(userId: number): string
    return ("PlayerV1_%d"):format(userId)
end

local function sameSession(profile: any, owned: any, now: number): boolean
    local session = profile and profile.session
    return session ~= nil and owned ~= nil
        and session.ownerJobId == owned.ownerJobId
        and session.token == owned.token
        and session.generation == owned.generation
        and session.leaseExpiry > now
end

function PlayerData:Acquire(userId: number, jobId: string, now: number)
    if not goodUserId(userId) or type(jobId) ~= "string" or #jobId < 1 or #jobId > 128
        or not validTime(now) then
        return nil, "InvalidArgument"
    end
    if self.busy[userId] or self.pending[userId] then
        return nil, "Busy"
    end
    local owned = self.sessions[userId]
    if owned and owned.ownerJobId ~= jobId then
        return nil, "Busy"
    end
    local token = owned and owned.token or self.issuedTokens[userId]
    if not token then
        token = HttpService:GenerateGUID(false)
        self.issuedTokens[userId] = token
    end
    self.busy[userId] = true
    local blocked = "Locked"
    local success, saved = pcall(function()
        return self.adapter:UpdateAsync(key(userId), function(current)
            local base = current == nil and Schema.New() or Schema.Clone(current)
            local valid, reason = Schema.Validate(base)
            if not valid then
                blocked = reason or "InvalidProfile"
                return nil
            end
            local previous = base.session
            if previous and previous.leaseExpiry > now
                and (previous.ownerJobId ~= jobId or previous.token ~= token) then
                blocked = "Locked"
                return nil
            end
            if not previous or previous.ownerJobId ~= jobId or previous.token ~= token then
                base.fencingCounter += 1
            end
            base.session = {
                ownerJobId = jobId,
                token = token,
                generation = base.fencingCounter,
                leaseExpiry = now + 120,
            }
            local ok, issue = Schema.Validate(base)
            if not ok then
                blocked = issue or "InvalidProfile"
                return nil
            end
            return base
        end)
    end)
    self.busy[userId] = nil
    if not success then
        -- Preserve the token: an ACK could have been lost AFTER the acquisition committed.
        return nil, "StorageUnavailable"
    end
    if not saved or not saved.session or saved.session.token ~= token
        or saved.session.ownerJobId ~= jobId then
        return nil, blocked
    end
    self.sessions[userId] = Schema.Clone(saved.session)
    self.snapshots[userId] = Schema.Clone(saved)
    return Schema.Clone(saved), nil
end

function PlayerData:Transact(userId: number, operationId: string, expectedRevision: number,
    now: number, mutation: (any) -> (boolean, any))
    if not goodUserId(userId) or not validTime(now) then
        return nil, "InvalidArgument"
    end
    local owned = self.sessions[userId]
    if not owned then
        return nil, "NotReady"
    end
    if self.busy[userId] or (self.pending[userId] and self.pending[userId] ~= operationId) then
        return nil, "Busy"
    end
    if type(operationId) ~= "string" or #operationId < 8 or #operationId > 64
        or type(mutation) ~= "function" then
        return nil, "InvalidOperation"
    end
    self.busy[userId] = true
    local blocked = "Unknown"
    local success, saved = pcall(function()
        return self.adapter:UpdateAsync(key(userId), function(current)
            local valid, reason = Schema.Validate(current)
            if not valid then
                blocked = reason or "InvalidProfile"
                return nil
            end
            if not sameSession(current, owned, now) then
                blocked = "LeaseLost"
                return nil
            end
            local updated, issue = Transactions.Apply(current, operationId, expectedRevision, mutation)
            if not updated then
                blocked = issue or "Rejected"
            end
            return updated
        end)
    end)
    self.busy[userId] = nil
    if not success then
        -- Don't acknowledge/revert an ambiguous commit. Block DIFFERENT operationIds
        -- until the caller retries THIS operationId with the same deterministic mutation.
        self.pending[userId] = operationId
        return nil, "SavePending"
    end
    if not saved then
        return nil, blocked
    end
    local receipt = saved.receipts and saved.receipts[operationId]
    if not receipt or not sameSession(saved, owned, now) then
        return nil, "LeaseLost"
    end
    self.pending[userId] = nil
    self.snapshots[userId] = Schema.Clone(saved)
    return Schema.Clone(receipt), nil
end

function PlayerData:Renew(userId: number, now: number)
    local owned = self.sessions[userId]
    if not owned or not validTime(now) then
        return false, "NotReady"
    end
    -- Pending gameplay writes must not block independent lease renewal.
    -- Renewal updates session metadata only; it never acknowledges the write.
    if self.busy[userId] then
        return false, "Busy"
    end
    self.busy[userId] = true
    local rejected = "LeaseLost"
    local success, saved = pcall(function()
        return self.adapter:UpdateAsync(key(userId), function(current)
            local valid, reason = Schema.Validate(current)
            if not valid then
                rejected = reason or "InvalidProfile"
                return nil
            end
            if not sameSession(current, owned, now) then
                return nil
            end
            local draft = Schema.Clone(current)
            draft.session.leaseExpiry = now + 120
            return draft
        end)
    end)
    self.busy[userId] = nil
    if not success or not saved then
        return false, success and rejected or "StorageUnavailable"
    end
    self.sessions[userId] = Schema.Clone(saved.session)
    self.snapshots[userId] = Schema.Clone(saved)
    return true, nil
end

function PlayerData:Close(userId: number, now: number)
    local owned = self.sessions[userId]
    if not owned or not validTime(now) then
        return false, "NotReady"
    end
    if self.busy[userId] or self.pending[userId] then
        return false, "Busy"
    end
    self.busy[userId] = true
    local rejected = "LeaseLost"
    local success, saved = pcall(function()
        return self.adapter:UpdateAsync(key(userId), function(current)
            local valid, reason = Schema.Validate(current)
            if not valid then
                rejected = reason or "InvalidProfile"
                return nil
            end
            -- Previous Close may have committed even if its acknowledgement was lost.
            -- An already absent lease is safe to finalize; never clear a foreign owner.
            if current.session == nil then
                return current
            end
            if not sameSession(current, owned, now) then
                return nil
            end
            local draft = Schema.Clone(current)
            draft.session = nil
            return draft
        end)
    end)
    self.busy[userId] = nil
    if not success or not saved then
        return false, success and rejected or "StorageUnavailable"
    end
    self.sessions[userId] = nil
    self.snapshots[userId] = nil
    self.issuedTokens[userId] = nil
    return true, nil
end

function PlayerData:GetServerSnapshot(userId: number)
    local value = self.snapshots[userId]
    return value and Schema.Clone(value) or nil
end

return table.freeze(PlayerData)
