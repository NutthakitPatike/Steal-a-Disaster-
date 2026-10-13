--!strict
-- P1-04: isolated server-side crate capture state machine.
-- This module is NOT wired to RemoteRouter, DataStore or live gameplay.
-- clock and observe are trusted, synchronous SERVER functions. Never pass
-- client timestamps, positions, LOS flags or rarity values into this API.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Definitions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Definitions"))

local Crates = {}
Crates.__index = Crates

local MAX_WORLD = 20
local MAX_ZONE = 4
local MAX_DISTANCE = 10
local MAX_HOLD_MOVEMENT = 2
local HOLD_SECONDS = 2
local RESERVATION_SECONDS = 3
local SAMPLE_GRACE = 0.25
local CRATE_TTL = 90

local function validTime(now: any): boolean
    return type(now) == "number"
        and now == now
        and now ~= math.huge
        and now >= 0
        and now < 9999999000
end

local function finitePosition(value: any): boolean
    return typeof(value) == "Vector3"
        and value.X == value.X
        and value.Y == value.Y
        and value.Z == value.Z
        and math.abs(value.X) < 1000000
        and math.abs(value.Y) < 1000000
        and math.abs(value.Z) < 1000000
end

local function validUser(userId: any): boolean
    return type(userId) == "number"
        and userId > 0
        and userId % 1 == 0
        and userId <= 9007199254740991
end

local function validId(value: any): boolean
    -- Reserve two characters for deterministic "b_" banking operation IDs.
    return type(value) == "string"
        and #value >= 8
        and #value <= 62
        and value:match("^[%w_%-]+$") ~= nil
end

function Crates.new(clock: () -> number, observe: (number, any) -> any)
    assert(
        type(clock) == "function" and type(observe) == "function",
        "Trusted server clock and observation callbacks required"
    )
    return setmetatable({
        clock = clock,
        observe = observe,
        crates = {},
        carrying = {},
        secured = {},
        reservations = {},
        zoneCounts = {},
        activeCount = 0,
    }, Crates)
end

function Crates:_now()
    local now = self.clock()
    if not validTime(now) then
        return nil
    end
    return now
end

function Crates:_retire(crate)
    if crate.counted then
        crate.counted = false
        self.activeCount -= 1
        self.zoneCounts[crate.zoneId] -= 1
    end
end

function Crates:_release(crate, now: number)
    self.reservations[crate.holder] = nil
    crate.holder = nil
    crate.holdStarted = nil
    crate.startPosition = nil
    crate.lastSample = nil
    if now >= crate.expiresAt then
        crate.state = "Expired"
        self:_retire(crate)
    else
        crate.state = "Available"
    end
end

function Crates:_validActor(userId: number, crate, startPosition: Vector3?)
    local success, observation = pcall(self.observe, userId, crate)
    if
        not success
        or type(observation) ~= "table"
        or observation.ready ~= true
        or observation.alive ~= true
        or observation.visible ~= true
        or not finitePosition(observation.position)
    then
        return nil, "InvalidActor"
    end
    if (observation.position - crate.position).Magnitude > MAX_DISTANCE then
        return nil, "OutOfRange"
    end
    if startPosition and (observation.position - startPosition).Magnitude > MAX_HOLD_MOVEMENT then
        return nil, "MovedDuringHold"
    end
    return observation.position, nil
end

-- Server creates crate identities, chooses tiers and performs physical spawn checks.
-- No RNG occurs here; both methods preserve the exact same crate tier/lootVersion.
function Crates:Register(
    crateId: string,
    zoneId: string,
    tier: string,
    lootVersion: number,
    position: Vector3
)
    local now = self:_now()
    if
        not now
        or not validId(crateId)
        or not Definitions.IsZoneId(zoneId)
        or (tier ~= "Common" and tier ~= "Rare")
        or type(lootVersion) ~= "number"
        or lootVersion % 1 ~= 0
        or lootVersion < 1
        or lootVersion > 2147483647
        or not finitePosition(position)
    then
        return nil, "InvalidCrate"
    end
    if self.crates[crateId] then
        return nil, "DuplicateCrate"
    end
    if self.activeCount >= MAX_WORLD or (self.zoneCounts[zoneId] or 0) >= MAX_ZONE then
        return nil, "ZoneOrWorldFull"
    end
    local crate = {
        id = crateId,
        zoneId = zoneId,
        tier = tier,
        lootVersion = lootVersion,
        position = position,
        state = "Available",
        expiresAt = now + CRATE_TTL,
        counted = true,
    }
    self.crates[crateId] = crate
    self.activeCount += 1
    self.zoneCounts[zoneId] = (self.zoneCounts[zoneId] or 0) + 1
    return true, nil
end

function Crates:_capture(crate, userId: number, method: string, now: number)
    self:_retire(crate)
    if crate.holder then
        self.reservations[crate.holder] = nil
    end
    crate.holder = userId
    crate.state = "Carried"
    crate.holdStarted = nil
    crate.startPosition = nil
    crate.lastSample = nil
    self.carrying[userId] = crate.id
    -- Server-only ephemeral receipt; this is NOT a persisted bank or loot grant.
    return {
        crateId = crate.id,
        zoneId = crate.zoneId,
        tier = crate.tier,
        lootVersion = crate.lootVersion,
        method = method,
        alertAt = now + (method == "Snatch" and 0.75 or 2.5),
    }
end

function Crates:Begin(userId: number, crateId: string, method: string)
    local now = self:_now()
    if
        not now
        or not validUser(userId)
        or not validId(crateId)
        or (method ~= "Stabilize" and method ~= "Snatch")
    then
        return nil, "InvalidRequest"
    end
    if self.carrying[userId] then
        return nil, "AlreadyCarrying"
    end
    if self.reservations[userId] then
        return nil, "AlreadyHolding"
    end
    local crate = self.crates[crateId]
    if not crate then
        return nil, "UnknownCrate"
    end
    if crate.state ~= "Available" then
        return nil, "Unavailable"
    end
    if now >= crate.expiresAt then
        crate.state = "Expired"
        self:_retire(crate)
        return nil, "Expired"
    end
    local position, issue = self:_validActor(userId, crate)
    if not position then
        return nil, issue
    end
    if method == "Snatch" then
        return self:_capture(crate, userId, method, now), nil
    end
    crate.state = "Reserved"
    crate.holder = userId
    crate.startPosition = position
    crate.holdStarted = now
    crate.lastSample = now
    crate.deadline = now + RESERVATION_SECONDS
    self.reservations[userId] = crateId
    return { crateId = crateId, status = "Holding", seconds = HOLD_SECONDS }, nil
end

-- Call from a server-owned ~10Hz scheduler, never from a RemoteEvent.
-- Stale samples fail closed when Finish is attempted.
function Crates:Heartbeat()
    local now = self:_now()
    if not now then
        return false, "InvalidTime"
    end
    for id, crate in pairs(self.crates) do
        if crate.state == "Reserved" then
            -- A missed server sample invalidates a supposedly continuous hold.
            local valid = now <= crate.deadline and now - crate.lastSample <= SAMPLE_GRACE
            if valid then
                valid = self:_validActor(crate.holder, crate, crate.startPosition) ~= nil
            end
            if not valid then
                self:_release(crate, now)
            else
                crate.lastSample = now
            end
        elseif crate.state == "Available" and now >= crate.expiresAt then
            crate.state = "Expired"
            self:_retire(crate)
        elseif crate.state == "Expired" and now >= crate.expiresAt + 30 then
            self.crates[id] = nil
        elseif crate.state == "Lost" and crate.lostAt and now >= crate.lostAt + 30 then
            self.crates[id] = nil
        end
    end
    return true, nil
end

function Crates:Finish(userId: number, crateId: string)
    local now = self:_now()
    if not now or not validUser(userId) or not validId(crateId) then
        return nil, "InvalidRequest"
    end
    local crate = self.crates[crateId]
    if
        not crate
        or crate.state ~= "Reserved"
        or crate.holder ~= userId
        or self.reservations[userId] ~= crateId
    then
        return nil, "NotHolding"
    end
    if now > crate.deadline or now - crate.lastSample > SAMPLE_GRACE then
        self:_release(crate, now)
        return nil, "HoldInterrupted"
    end
    local position, issue = self:_validActor(userId, crate, crate.startPosition)
    if not position then
        self:_release(crate, now)
        return nil, issue
    end
    if now - crate.holdStarted < HOLD_SECONDS then
        return nil, "TooSoon"
    end
    return self:_capture(crate, userId, "Stabilize", now), nil
end

function Crates:Cancel(userId: number)
    local now = self:_now()
    local id = self.reservations[userId]
    if not now or not id then
        return false
    end
    local crate = self.crates[id]
    if crate and crate.state == "Reserved" and crate.holder == userId then
        self:_release(crate, now)
        return true
    end
    return false
end

-- Called on death/disconnect while carrying an UNSECURED crate.
-- Secure-return and bank transitions belong to the separate durable protocol.
function Crates:ClearPlayer(userId: number)
    self:Cancel(userId)
    -- Secured crates remain durable in the profile. Never delete returnPending
    -- just because a character dies or the player disconnects.
    self.secured[userId] = nil
    local crateId = self.carrying[userId]
    self.carrying[userId] = nil
    local crate = crateId and self.crates[crateId]
    if crate and crate.state == "Carried" and crate.holder == userId then
        crate.state = "Lost"
        crate.holder = nil
        crate.lostAt = self:_now()
    end
end

function Crates:GetCarry(userId: number)
    local crate = self.crates[self.carrying[userId]]
    if not crate or crate.state ~= "Carried" or crate.holder ~= userId then
        return nil
    end
    return {
        crateId = crate.id,
        zoneId = crate.zoneId,
        tier = crate.tier,
        lootVersion = crate.lootVersion,
    }
end

-- Restore ONLY from a validated, owned server profile after physically reaching
-- its Zone's safe-exit checkpoint. This has no rewards or world teleports.
function Crates:RestoreSecured(userId: number, profile: any)
    local Schema = require(script.Parent:WaitForChild("ProfileSchema"))
    if not validUser(userId) or not Schema.Validate(profile) or not profile.returnPending then
        return nil, "InvalidProfile"
    end
    local pending = profile.returnPending
    if self.carrying[userId] then
        -- A freshly secured exit has a durable returnPending but still has
        -- the earlier temporary PvE carry. Convert only THAT exact crate.
        local held = self:GetCarry(userId)
        if
            not held
            or held.crateId ~= pending.crateId
            or held.zoneId ~= pending.zoneId
            or held.tier ~= pending.tier
            or held.lootVersion ~= pending.lootVersion
        then
            return nil, "AlreadyCarrying"
        end
        -- Discard the uncommitted temporary state; durable returnPending stays
        -- in the profile and is authoritative after this conversion.
        self:ClearPlayer(userId)
    end
    if self.secured[userId] then
        if self.secured[userId].crateId == pending.crateId then
            return Schema.Clone(self.secured[userId]), nil
        end
        return nil, "AlreadySecured"
    end
    local active = self.crates[pending.crateId]
    if
        active
        and (active.state == "Available" or active.state == "Reserved" or active.state == "Carried")
    then
        return nil, "ConflictingCrate"
    end
    for holder, existing in pairs(self.secured) do
        if holder ~= userId and existing.crateId == pending.crateId then
            return nil, "DuplicateSecuredCrate"
        end
    end
    local descriptor = {
        crateId = pending.crateId,
        zoneId = pending.zoneId,
        tier = pending.tier,
        lootVersion = pending.lootVersion,
    }
    self.secured[userId] = descriptor
    return Schema.Clone(descriptor), nil
end

function Crates:GetSecured(userId: number)
    local stored = self.secured[userId]
    return stored
            and {
                crateId = stored.crateId,
                zoneId = stored.zoneId,
                tier = stored.tier,
                lootVersion = stored.lootVersion,
            }
        or nil
end

function Crates:ReleaseSecured(userId: number, crateId: string): boolean
    if self.secured[userId] and self.secured[userId].crateId == crateId then
        self.secured[userId] = nil
        return true
    end
    return false
end

function Crates:Status(crateId: string): string
    local crate = self.crates[crateId]
    return crate and crate.state or "Absent"
end

return table.freeze(Crates)
