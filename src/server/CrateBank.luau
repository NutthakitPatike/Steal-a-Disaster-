--!strict
-- P1-04/P1-06 opt-in, server-only own-base banking of a secured crate.
-- An injected approved LootDefinitions callback prepares a single hidden
-- outcome BEFORE UpdateAsync; no RNG, physics, or services inside the transform.
-- Never call from a client remote without server-owned session/base checks.
local RunService = game:GetService("RunService")
local Schema = require(script.Parent:WaitForChild("ProfileSchema"))
local Bank = {}
Bank.__index = Bank

local function whole(n: any, lo: number, hi: number): boolean
    return type(n) == "number" and n == n and n % 1 == 0 and n >= lo and n <= hi
end

local function id(s: any): boolean
    return type(s) == "string" and #s >= 1 and #s <= 64 and s:match("^[%w_%-]+$") ~= nil
end

local function count(map: any): number
    local n = 0
    for _ in pairs(map) do
        n += 1
    end
    return n
end

local function sameCarry(a: any, b: any): boolean
    return a
        and b
        and a.crateId == b.crateId
        and a.zoneId == b.zoneId
        and a.tier == b.tier
        and a.lootVersion == b.lootVersion
end

-- A prepared hidden outcome MUST have come from a trusted, versioned rarity
-- pool. The caller also supplies a pure authoritative catalog validator.
function Bank.Mutation(pending: any, prepared: any)
    assert(
        type(pending) == "table"
            and id(pending.crateId)
            and #pending.crateId <= 62
            and type(pending.zoneId) == "string"
            and (pending.tier == "Common" or pending.tier == "Rare")
            and whole(pending.lootVersion, 1, 2147483647)
            and pending.exitId == pending.zoneId
            and pending.secureOperationId == pending.crateId,
        "Validated, immutable saved return descriptor required"
    )
    assert(
        type(prepared) == "table"
            and id(prepared.speciesId)
            and id(prepared.variantId)
            and whole(prepared.rank, 1, 3),
        "Validated server-generated hidden reward required"
    )
    local bankOp = "b_" .. pending.crateId
    local record = {
        zoneId = pending.zoneId,
        tier = pending.tier,
        lootVersion = pending.lootVersion,
        hiddenSpeciesId = prepared.speciesId,
        hiddenVariantId = prepared.variantId,
        hiddenRank = prepared.rank,
        reservedItemId = pending.crateId,
        bankOperationId = bankOp,
    }
    local expected = Schema.Clone(pending)
    return bankOp,
        function(profile: any)
            local live = profile.returnPending
            if
                not live
                or not sameCarry(live, expected)
                or live.secureOperationId ~= expected.secureOperationId
                or live.securedAt ~= expected.securedAt
            then
                return false, "ReturnChanged"
            end
            if profile.bankedCrates[expected.crateId] or profile.items[expected.crateId] then
                return false, "AlreadyConsumed"
            end
            local bankCount = count(profile.bankedCrates)
            if bankCount >= 3 or count(profile.items) + bankCount + 1 > Schema.MaxItems then
                return false, "CapacityFull"
            end
            -- Atomic replacement: one pending crate becomes one hidden banked result.
            profile.bankedCrates[expected.crateId] = Schema.Clone(record)
            profile.returnPending = nil
            return true,
                {
                    kind = "Banked",
                    crateId = expected.crateId,
                    zoneId = expected.zoneId,
                }
        end
end

function Bank.new(
    lifecycle: any,
    data: any,
    crates: any,
    observer: any,
    resolveBase: (number) -> BasePart?,
    assignedBase: (number) -> number?,
    prepareLoot: (any) -> any,
    validateLoot: (any, any) -> boolean
)
    assert(RunService:IsServer(), "ServerOnly")
    assert(
        type(lifecycle) == "table"
            and type(lifecycle.Status) == "function"
            and type(lifecycle.Transact) == "function"
            and type(lifecycle.ResolvePending) == "function"
            and type(data) == "table"
            and type(data.GetServerSnapshot) == "function"
            and type(crates) == "table"
            and type(crates.GetSecured) == "function"
            and type(crates.ReleaseSecured) == "function"
            and type(observer) == "table"
            and type(observer.Character) == "function"
            and type(resolveBase) == "function"
            and type(assignedBase) == "function"
            and type(prepareLoot) == "function"
            and type(validateLoot) == "function",
        "Trusted banking services, base ownership and loot catalog required"
    )
    return setmetatable({
        lifecycle = lifecycle,
        data = data,
        crates = crates,
        observer = observer,
        resolveBase = resolveBase,
        assignedBase = assignedBase,
        prepareLoot = prepareLoot,
        validateLoot = validateLoot,
        inflight = {},
    }, Bank)
end

function Bank:Deposit(userId: number, expectedRevision: number, now: number)
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
        if expectedRevision ~= work.expectedRevision then
            return nil, "WrongPendingRevision"
        end
    else
        if self.lifecycle:Status(userId) ~= "Ready" then
            return nil, "NotReady"
        end
        local profile = self.data:GetServerSnapshot(userId)
        if not profile or not Schema.Validate(profile) or not profile.returnPending then
            return nil, "NotReturning"
        end
        local pending = profile.returnPending
        if #pending.crateId > 62 then
            return nil, "UnsupportedCrateId"
        end
        if not sameCarry(self.crates:GetSecured(userId), pending) then
            return nil, "NotCarryingSecuredCrate"
        end
        local ok, baseId, base = pcall(function()
            local assigned = self.assignedBase(userId)
            return assigned, self.resolveBase(assigned)
        end)
        if
            not ok
            or not whole(baseId, 1, 7)
            or typeof(base) ~= "Instance"
            or not base:IsA("BasePart")
            or not base.Anchored
            or not base:IsDescendantOf(workspace)
            or base:GetAttribute("BaseId") ~= baseId
        then
            return nil, "InvalidOwnBase"
        end
        local observed = self.observer:Character(userId)
        if
            not observed
            or typeof(observed.position) ~= "Vector3"
            or observed.position.X ~= observed.position.X
            or observed.position.Y ~= observed.position.Y
            or observed.position.Z ~= observed.position.Z
            or (observed.position - base.Position).Magnitude > 8
        then
            return nil, "OutOfRange"
        end
        local preparedOk, prepared = pcall(self.prepareLoot, Schema.Clone(pending))
        if not preparedOk or type(prepared) ~= "table" then
            return nil, "LootUnavailable"
        end
        local catalogOk, catalogValid = pcall(self.validateLoot, Schema.Clone(pending), prepared)
        if not catalogOk or catalogValid ~= true then
            return nil, "InvalidLoot"
        end
        if
            not id(prepared.speciesId)
            or not id(prepared.variantId)
            or not whole(prepared.rank, 1, 3)
        then
            return nil, "InvalidLoot"
        end
        local frozen = {
            speciesId = prepared.speciesId,
            variantId = prepared.variantId,
            rank = prepared.rank,
        }
        work = {
            expectedRevision = expectedRevision,
            pending = Schema.Clone(pending),
            prepared = table.freeze(frozen),
            operationId = "b_" .. pending.crateId,
        }
    end
    local operationId, mutation = Bank.Mutation(work.pending, work.prepared)
    local receipt, issue
    if self.inflight[userId] then
        receipt, issue =
            self.lifecycle:ResolvePending(userId, operationId, work.expectedRevision, now, mutation)
    else
        receipt, issue =
            self.lifecycle:Transact(userId, operationId, work.expectedRevision, now, mutation)
    end
    if issue == "SavePending" then
        self.inflight[userId] = work
        return nil, issue
    end
    if not receipt then
        return nil, issue or "Unavailable"
    end
    if
        type(receipt.result) ~= "table"
        or receipt.result.kind ~= "Banked"
        or receipt.result.crateId ~= work.pending.crateId
        or receipt.result.zoneId ~= work.pending.zoneId
    then
        return nil, "ReceiptMismatch"
    end
    self.inflight[userId] = nil
    self.crates:ReleaseSecured(userId, work.pending.crateId)
    return receipt, nil
end

return table.freeze(Bank)
