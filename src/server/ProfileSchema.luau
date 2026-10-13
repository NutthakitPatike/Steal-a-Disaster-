--!strict
-- P1-03: versioned, server-only profile values. Never hydrate after a failed load.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Definitions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Definitions"))
local Schema = {}

Schema.Version = 1
Schema.MaxItems = 100
Schema.MaxReceipts = 128
Schema.MaxSerializedBytes = 256 * 1024
Schema.MaxCoins = 1000000000

local function int(value: any, lo: number, hi: number): boolean
    return type(value) == "number"
        and value == value
        and value % 1 == 0
        and value >= lo
        and value <= hi
end

local function serializable(
    value: any,
    depth: number,
    seen: { [any]: boolean },
    budget: { number }
): boolean
    budget[1] += 1
    if budget[1] > 12000 or depth > 12 then
        return false
    end
    if type(value) == "number" then
        return value == value and value ~= math.huge and value ~= -math.huge
    elseif type(value) == "string" then
        return #value <= 4096 and utf8.len(value) ~= nil
    elseif type(value) == "boolean" then
        return true
    elseif type(value) ~= "table" or seen[value] then
        return false
    end
    seen[value] = true
    for key, child in pairs(value) do
        if
            not (type(key) == "string" or (int(key, 1, 20000)))
            or not serializable(child, depth + 1, seen, budget)
        then
            return false
        end
    end
    seen[value] = nil
    return true
end

function Schema.Clone<T>(value: T): T
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for key, item in pairs(value :: any) do
        copy[key] = Schema.Clone(item)
    end
    return copy :: any
end

function Schema.New()
    return {
        schemaVersion = Schema.Version,
        revision = 0,
        contentVersion = 1,
        coins = 0,
        speedPowerMilli = 0,
        upgrades = { treadmill = 0, pen = 0, slots = 4 },
        unlockedZones = { tornado_town = true },
        successfulDeliveries = {},
        ownedTrails = {},
        equippedTrail = "none",
        items = {},
        bankedCrates = {},
        storedIncomeMilli = 0,
        incomeRemainder = 0,
        lastCheckpointAt = 0,
        index = {},
        indexBonusClaimed = {},
        tutorialStep = 0,
        activePlaySeconds = 0,
        shieldUntil = 0,
        shieldCooldownUntil = 0,
        receipts = {},
        receiptOrder = {},
        pendingTransfers = {},
        pendingItemOperations = {},
        eventClaims = {},
        fencingCounter = 0,
        -- session and returnPending are absent by default; Roblox serialization omits nil.
    }
end

local function map(value: any): boolean
    return type(value) == "table"
end

function Schema.Validate(profile: any): (boolean, string?)
    if type(profile) ~= "table" then
        return false, "InvalidProfile"
    end
    if not int(profile.schemaVersion, 1, Schema.Version) then
        return false,
            type(profile.schemaVersion) == "number"
                    and profile.schemaVersion > Schema.Version
                    and "FutureSchema"
                or "InvalidSchema"
    end
    if
        not int(profile.revision, 0, 2147483647) or not int(profile.contentVersion, 1, 2147483647)
    then
        return false, "InvalidRevision"
    end
    if
        not int(profile.coins, 0, Schema.MaxCoins) or not int(profile.speedPowerMilli, 0, 10000000)
    then
        return false, "InvalidBalances"
    end
    if
        not map(profile.upgrades)
        or not int(profile.upgrades.treadmill, 0, 3)
        or not int(profile.upgrades.pen, 0, 3)
        or (
            profile.upgrades.slots ~= 4
            and profile.upgrades.slots ~= 6
            and profile.upgrades.slots ~= 8
        )
    then
        return false, "InvalidUpgrades"
    end
    for _, name in ipairs({
        "unlockedZones",
        "successfulDeliveries",
        "ownedTrails",
        "items",
        "bankedCrates",
        "index",
        "indexBonusClaimed",
        "receipts",
        "receiptOrder",
        "pendingTransfers",
        "pendingItemOperations",
        "eventClaims",
    }) do
        if not map(profile[name]) then
            return false, "Invalid_" .. name
        end
    end
    if
        type(profile.equippedTrail) ~= "string"
        or #profile.equippedTrail > 64
        or not int(profile.storedIncomeMilli, 0, 1000000000000)
        or not int(profile.incomeRemainder, 0, 999)
        or not int(profile.lastCheckpointAt, 0, 9999999999)
        or not int(profile.tutorialStep, 0, 1000)
        or not int(profile.activePlaySeconds, 0, 1000000000)
        or not int(profile.shieldUntil, 0, 9999999999)
        or not int(profile.shieldCooldownUntil, 0, 9999999999)
        or not int(profile.fencingCounter, 0, 2147483647)
    then
        return false, "InvalidProgress"
    end
    if profile.unlockedZones.tornado_town ~= true then
        return false, "MissingStarterZone"
    end
    local itemCount, slots = 0, {}
    for id, item in pairs(profile.items) do
        itemCount += 1
        if
            type(id) ~= "string"
            or #id > 64
            or #id == 0
            or type(item) ~= "table"
            or type(item.speciesId) ~= "string"
            or #item.speciesId > 64
            or not int(item.rank, 1, 3)
            or type(item.variantId) ~= "string"
            or #item.variantId > 64
            or type(item.originZone) ~= "string"
            or #item.originZone > 64
            or not int(item.itemVersion, 1, 2147483647)
            or type(item.locked) ~= "boolean"
            or type(item.transferTracked) ~= "boolean"
            or not int(item.acquiredAt, 0, 9999999999)
        then
            return false, "InvalidItem"
        end
        if item.slotId ~= nil then
            if not int(item.slotId, 1, profile.upgrades.slots) or slots[item.slotId] then
                return false, "DuplicateOrInvalidSlot"
            end
            slots[item.slotId] = true
        end
    end
    if itemCount > Schema.MaxItems then
        return false, "InventoryFull"
    end
    local count, unique = 0, {}
    for _, id in ipairs(profile.receiptOrder) do
        count += 1
        if type(id) ~= "string" or not profile.receipts[id] or unique[id] then
            return false, "InvalidReceiptOrder"
        end
        unique[id] = true
    end
    if count > Schema.MaxReceipts then
        return false, "TooManyReceipts"
    end
    for id, receipt in pairs(profile.receipts) do
        if
            not unique[id]
            or type(receipt) ~= "table"
            or receipt.operationId ~= id
            or not int(receipt.revision, 1, profile.revision)
        then
            return false, "InvalidReceipt"
        end
    end
    local session = profile.session
    if
        session ~= nil
        and (
            type(session) ~= "table"
            or type(session.ownerJobId) ~= "string"
            or #session.ownerJobId == 0
            or type(session.token) ~= "string"
            or #session.token == 0
            or not int(session.generation, 1, profile.fencingCounter)
            or not int(session.leaseExpiry, 0, 9999999999)
        )
    then
        return false, "InvalidSession"
    end
    -- P1-04: secured exit checkpoint is durable, but not yet a banked reward.
    -- Reject unknown fields and any duplicate/invalid identity before loading.
    local pending = profile.returnPending
    if pending ~= nil then
        if type(pending) ~= "table" then
            return false, "InvalidReturnPending"
        end
        for field in pairs(pending) do
            if
                field ~= "crateId"
                and field ~= "zoneId"
                and field ~= "tier"
                and field ~= "lootVersion"
                and field ~= "exitId"
                and field ~= "checkpointVersion"
                and field ~= "secureOperationId"
                and field ~= "securedAt"
            then
                return false, "InvalidReturnPending"
            end
        end
        if
            type(pending.crateId) ~= "string"
            or #pending.crateId < 8
            or #pending.crateId > 64
            or not pending.crateId:match("^[%w_%-]+$")
            or not Definitions.IsZoneId(pending.zoneId)
            or profile.unlockedZones[pending.zoneId] ~= true
            or (pending.tier ~= "Common" and pending.tier ~= "Rare")
            or not int(pending.lootVersion, 1, 2147483647)
            or pending.exitId ~= pending.zoneId
            or pending.secureOperationId ~= pending.crateId
            or pending.checkpointVersion ~= 1
            or not int(pending.securedAt, 0, 9999999999)
            or profile.bankedCrates[pending.crateId] ~= nil
        then
            return false, "InvalidReturnPending"
        end
    end
    if not serializable(profile, 0, {}, { 0 }) then
        return false, "NotSerializable"
    end
    return true, nil
end

return table.freeze(Schema)
