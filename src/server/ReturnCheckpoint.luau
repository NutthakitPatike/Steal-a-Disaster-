--!strict
-- P1-04: opt-in durable exit checkpoint. No DataStore opens on require.
-- Instantiated ONLY by a trusted server coordinator with an owned session
-- lifecycle and completed CrateReturnProof witness. No client-provided payload.
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Schema = require(script.Parent:WaitForChild("ProfileSchema"))
local Definitions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Definitions"))

local ReturnCheckpoint = {}
ReturnCheckpoint.__index = ReturnCheckpoint

local function whole(value: any, min: number, max: number): boolean
    return type(value) == "number"
        and value == value
        and value % 1 == 0
        and value >= min
        and value <= max
end

local function identifier(value: any): boolean
    return type(value) == "string"
        and #value >= 8
        and #value <= 64
        and value:match("^[%w_%-]+$") ~= nil
end

local function validWitness(witness: any): boolean
    return type(witness) == "table"
        and identifier(witness.crateId)
        and #witness.crateId <= 62
        and Definitions.IsZoneId(witness.zoneId)
        and (witness.tier == "Common" or witness.tier == "Rare")
        and whole(witness.lootVersion, 1, 2147483647)
        and witness.exitId == witness.zoneId
end

local function countEntries(map: any): number
    local count = 0
    for _ in pairs(map) do
        count += 1
    end
    return count
end

-- Pure, retryable UpdateAsync transform: no Raycast, RNG or mutable service state.
-- OperationId equals the globally unique server crateId. It stays stable after
-- a lost ACK, and a saved returnPending outlives the 128-entry receipt window.
function ReturnCheckpoint.Mutation(witness: any, securedAt: number)
    assert(
        validWitness(witness) and whole(securedAt, 0, 9999999999),
        "Trusted immutable witness and server timestamp required"
    )
    local descriptor = {
        crateId = witness.crateId,
        zoneId = witness.zoneId,
        tier = witness.tier,
        lootVersion = witness.lootVersion,
        exitId = witness.exitId,
        checkpointVersion = 1,
        secureOperationId = witness.crateId,
        securedAt = securedAt,
    }
    return function(profile: any)
        if not profile.unlockedZones[descriptor.zoneId] then
            return false, "ZoneLocked"
        end
        if profile.returnPending ~= nil then
            return false, "AlreadyReturning"
        end
        if profile.bankedCrates[descriptor.crateId] ~= nil then
            return false, "AlreadyBanked"
        end
        local bankCount = countEntries(profile.bankedCrates)
        if bankCount >= 3 or countEntries(profile.items) + bankCount >= Schema.MaxItems then
            return false, "CapacityFull"
        end
        profile.returnPending = Schema.Clone(descriptor)
        -- No banked outcome, inventory, coins, remote or teleport here.
        return true,
            {
                kind = "ReturnPending",
                crateId = descriptor.crateId,
                zoneId = descriptor.zoneId,
                returnCheckpoint = "SafeExit",
            }
    end
end

function ReturnCheckpoint.new(lifecycle: any, witnessService: any)
    assert(RunService:IsServer(), "ServerOnly")
    assert(
        type(lifecycle) == "table"
            and type(lifecycle.Status) == "function"
            and type(lifecycle.Transact) == "function"
            and type(lifecycle.ResolvePending) == "function"
            and type(witnessService) == "table"
            and type(witnessService.Witness) == "function"
            and type(witnessService.Cancel) == "function",
        "Owned session and physical witness coordinator required"
    )
    return setmetatable({
        lifecycle = lifecycle,
        proof = witnessService,
        inflight = {},
    }, ReturnCheckpoint)
end

-- Called only by SERVER when the authenticated player's physical exit witness
-- has reached AwaitingDurableCommit. now must be an integer server Unix time.
function ReturnCheckpoint:Secure(userId: number, expectedRevision: number, now: number)
    if
        not whole(userId, 1, 9007199254740991)
        or not whole(expectedRevision, 0, 2147483647)
        or not whole(now, 0, 9999999999)
    then
        return nil, "InvalidRequest"
    end
    local work = self.inflight[userId]
    if work then
        if self.lifecycle:Status(userId) ~= "Pending" then
            return nil, "PendingStateChanged"
        end
    else
        if self.lifecycle:Status(userId) ~= "Ready" then
            return nil, "NotReady"
        end
        local witness, problem = self.proof:Witness(userId)
        if not witness or not validWitness(witness) then
            return nil, problem or "InvalidWitness"
        end
        work = {
            operationId = witness.crateId,
            expectedRevision = expectedRevision,
            -- Copy and freeze the server witness before the first storage call.
            witness = table.freeze({
                crateId = witness.crateId,
                zoneId = witness.zoneId,
                tier = witness.tier,
                lootVersion = witness.lootVersion,
                exitId = witness.exitId,
            }),
            securedAt = now,
        }
    end
    -- Never switch revision or operation identity while resolving an ambiguous
    -- save. Rebuild the same pure transform on each retry.
    if expectedRevision ~= work.expectedRevision then
        return nil, "WrongPendingRevision"
    end
    local mutate = ReturnCheckpoint.Mutation(work.witness, work.securedAt)
    local receipt, issue
    if self.inflight[userId] then
        receipt, issue = self.lifecycle:ResolvePending(
            userId,
            work.operationId,
            work.expectedRevision,
            now,
            mutate
        )
    else
        receipt, issue =
            self.lifecycle:Transact(userId, work.operationId, work.expectedRevision, now, mutate)
    end
    if issue == "SavePending" then
        self.inflight[userId] = work
        return nil, issue
    end
    if receipt then
        local result = receipt.result
        if
            type(result) ~= "table"
            or result.kind ~= "ReturnPending"
            or result.crateId ~= work.witness.crateId
            or result.zoneId ~= work.witness.zoneId
        then
            return nil, "ReceiptMismatch"
        end
        self.inflight[userId] = nil
        self.proof:Cancel(userId)
        return receipt, nil
    end
    -- Do not clear a blocked pending operation on lease expiry or storage loss.
    return nil, issue or "Unavailable"
end

-- Data-only rejoin view. Caller must restore the crate at the SAME Zone's
-- safe-exit marker and require a physical trip to the owner's CURRENT base.
-- Never auto-bank, auto-open or place the crate at home.
function ReturnCheckpoint.Recovery(profile: any)
    local ok = Schema.Validate(profile)
    if not ok or profile.returnPending == nil then
        return nil
    end
    local saved = profile.returnPending
    return {
        crateId = saved.crateId,
        zoneId = saved.zoneId,
        tier = saved.tier,
        lootVersion = saved.lootVersion,
        exitId = saved.exitId,
        returnCheckpoint = "SafeExit",
    }
end

return table.freeze(ReturnCheckpoint)
