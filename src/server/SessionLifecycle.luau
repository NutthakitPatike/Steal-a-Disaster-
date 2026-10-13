--!strict
-- P1-03: opt-in server-owned profile lifecycle.
-- NEVER starts automatically and NEVER opens a DataStore. Requires a reviewed
-- PlayerData instance with an explicitly approved, isolated storage adapter.
local RunService = game:GetService("RunService")
local SessionLifecycle = {}
SessionLifecycle.__index = SessionLifecycle

local RENEW_AFTER = 30
local RETRY_AFTER = 5
local EXPIRY_MARGIN = 5

local function validTime(now: any): boolean
    return type(now) == "number" and now == now and now % 1 == 0
        and now >= 0 and now < 9999999000
end

function SessionLifecycle.new(data: any)
    assert(type(data) == "table"
        and type(data.Acquire) == "function"
        and type(data.Renew) == "function"
        and type(data.Close) == "function"
        and type(data.GetServerSnapshot) == "function"
        and type(data.Transact) == "function", "PlayerData coordinator required")
    return setmetatable({
        data = data,
        sessions = {},
        schedulerRunning = false,
        schedulerGeneration = 0,
    }, SessionLifecycle)
end

function SessionLifecycle:Status(userId: number): string
    local session = self.sessions[userId]
    return session and session.status or "Absent"
end

function SessionLifecycle:IsReady(userId: number, now: number): boolean
    local state = self.sessions[userId]
    return validTime(now) and state ~= nil and state.status == "Ready"
        and now < state.leaseExpiry - EXPIRY_MARGIN
end

function SessionLifecycle:Join(userId: number, jobId: string, now: number)
    if not validTime(now) then
        return nil, "InvalidTime"
    end
    if self.sessions[userId] then
        return nil, "AlreadyManaged"
    end
    local profile, issue = self.data:Acquire(userId, jobId, now)
    if not profile then
        return nil, issue or "Unavailable"
    end
    local owner = profile.session
    if type(owner) ~= "table" or type(owner.leaseExpiry) ~= "number"
        or owner.leaseExpiry <= now then
        return nil, "InvalidLease"
    end
    self.sessions[userId] = {
        status = "Ready",
        leaseExpiry = owner.leaseExpiry,
        nextRenewAt = now + RENEW_AFTER,
        errorCode = nil,
    }
    return profile, nil
end

function SessionLifecycle:Transact(userId: number, operationId: string, expectedRevision: number,
    now: number, mutation: (any) -> (boolean, any))
    if not self:IsReady(userId, now) then
        return nil, "NotReady"
    end
    local receipt, issue = self.data:Transact(userId, operationId, expectedRevision, now, mutation)
    if issue == "LeaseLost" then
        local state = self.sessions[userId]
        state.status = "Expired"
        state.errorCode = issue
    elseif issue == "SavePending" then
        -- Keep the same operation identity in the PlayerData coordinator.
        -- Block new gameplay requests until its receipt is reconciled.
        local state = self.sessions[userId]
        state.status = "Pending"
        state.errorCode = issue
    end
    return receipt, issue
end

function SessionLifecycle:ResolvePending(userId: number, operationId: string, expectedRevision: number,
    now: number, mutation: (any) -> (boolean, any))
    local state = self.sessions[userId]
    if not state or state.status ~= "Pending" or not validTime(now)
        or now >= state.leaseExpiry - EXPIRY_MARGIN then
        return nil, "NotReady"
    end
    -- PlayerData enforces the SAME operationId as the ambiguous attempt.
    local receipt, issue = self.data:Transact(userId, operationId, expectedRevision, now, mutation)
    if receipt then
        state.status = "Ready"
        state.errorCode = nil
    elseif issue == "LeaseLost" then
        state.status = "Expired"
        state.errorCode = issue
    end
    return receipt, issue
end

function SessionLifecycle:Leave(userId: number, now: number): (boolean, string?)
    local state = self.sessions[userId]
    if not state or not validTime(now) then
        return false, "NotManaged"
    end
    state.status = "Closing"
    local ok, issue = self.data:Close(userId, now)
    if ok then
        self.sessions[userId] = nil
        return true, nil
    end
    -- A failed Close must never be treated as a successful release.
    state.errorCode = issue or "CloseFailed"
    state.nextRenewAt = now + RETRY_AFTER
    return false, state.errorCode
end

function SessionLifecycle:Heartbeat(now: number)
    if not validTime(now) then
        return 0, "InvalidTime"
    end
    local recovered = 0
    for userId, state in pairs(self.sessions) do
        if now >= state.leaseExpiry - EXPIRY_MARGIN then
            state.status = "Expired"
            state.errorCode = "LeaseExpiring"
        elseif state.status == "Closing" then
            if now >= state.nextRenewAt then
                local released = self:Leave(userId, now)
                if released then
                    recovered += 1
                end
            end
        elseif state.status == "Ready" or state.status == "Degraded" then
            if now >= state.nextRenewAt then
                local ok, issue = self.data:Renew(userId, now)
                if ok then
                    local profile = self.data:GetServerSnapshot(userId)
                    local owner = profile and profile.session
                    if owner and type(owner.leaseExpiry) == "number" and owner.leaseExpiry > now then
                        state.leaseExpiry = owner.leaseExpiry
                        state.nextRenewAt = now + RENEW_AFTER
                        state.status = "Ready"
                        state.errorCode = nil
                        recovered += 1
                    else
                        state.status = "Degraded"
                        state.nextRenewAt = now + RETRY_AFTER
                        state.errorCode = "MissingRenewSnapshot"
                    end
                else
                    state.status = issue == "LeaseLost" and "Expired" or "Degraded"
                    state.nextRenewAt = now + RETRY_AFTER
                    state.errorCode = issue or "RenewFailed"
                end
            end
        end
    end
    return recovered, nil
end

function SessionLifecycle:StartScheduler()
    assert(RunService:IsServer(), "ServerOnly")
    if self.schedulerRunning then
        return
    end
    self.schedulerRunning = true
    self.schedulerGeneration += 1
    local current = self.schedulerGeneration
    task.spawn(function()
        while self.schedulerRunning and self.schedulerGeneration == current do
            task.wait(1)
            if self.schedulerRunning and self.schedulerGeneration == current then
                self:Heartbeat(os.time())
            end
        end
    end)
end

function SessionLifecycle:StopScheduler()
    self.schedulerRunning = false
    self.schedulerGeneration += 1
end

function SessionLifecycle:Shutdown(now: number)
    self:StopScheduler()
    local failures = {}
    for userId in pairs(self.sessions) do
        local done, issue = self:Leave(userId, now)
        if not done then
            failures[userId] = issue
        end
    end
    if next(failures) == nil then
        return true, nil
    end
    return false, failures
end

return table.freeze(SessionLifecycle)
