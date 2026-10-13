--!strict
-- P1-04: server-only PHYSICAL exit witness, not a bank/save operation.
-- Zone-facing side is authored local -Z. Verify orientation on the test map
-- before integration. Client requests never provide positions, exit IDs or speed.
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Definitions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Definitions"))

local ReturnProof = {}
ReturnProof.__index = ReturnProof

local SAMPLE_GAP = 0.25
local TOLERANCE = 2
local APPROACH_RANGE = 6
local MAX_SPEED = 70

local function finite(value: any): boolean
    return type(value) == "number" and value == value and math.abs(value) < 9999999000
end

local function positionValid(value: any): boolean
    return typeof(value) == "Vector3"
        and finite(value.X)
        and finite(value.Y)
        and finite(value.Z)
        and math.abs(value.X) < 1000000
        and math.abs(value.Y) < 1000000
        and math.abs(value.Z) < 1000000
end

local function validUser(userId: any): boolean
    return type(userId) == "number" and userId > 0 and userId % 1 == 0
end

local function validBase(baseId: any): boolean
    return type(baseId) == "number"
        and baseId % 1 == 0
        and baseId >= 1
        and baseId <= Definitions.BaseCount
end

function ReturnProof.new(
    crateService: any,
    observer: any,
    clock: () -> number,
    resolveExit: (string) -> BasePart?,
    assignedBase: (number) -> number?
)
    assert(RunService:IsServer(), "ServerOnly")
    assert(
        type(crateService) == "table"
            and type(crateService.GetCarry) == "function"
            and type(observer) == "table"
            and type(observer.Character) == "function"
            and type(clock) == "function"
            and type(resolveExit) == "function"
            and type(assignedBase) == "function",
        "Server-owned crate and world contracts required"
    )
    return setmetatable({
        crates = crateService,
        observer = observer,
        clock = clock,
        resolveExit = resolveExit,
        assignedBase = assignedBase,
        paths = {},
    }, ReturnProof)
end

-- Called by a trusted server coordinator only after a crate is actually carried.
-- exitPart must be a registered WorldRegistry ZoneExit BasePart.
function ReturnProof:Begin(userId: number, exitPart: BasePart)
    if
        not validUser(userId)
        or typeof(exitPart) ~= "Instance"
        or not exitPart:IsA("BasePart")
        or not exitPart.Anchored
        or not exitPart:IsDescendantOf(workspace)
        or not Definitions.IsZoneId(exitPart:GetAttribute("ZoneId"))
        or exitPart:GetAttribute("ZoneSide") ~= "-Z"
    then
        return false, "InvalidAnchor"
    end
    if self.paths[userId] then
        return false, "AlreadyTracking"
    end
    local carry = self.crates:GetCarry(userId)
    if not carry or carry.zoneId ~= exitPart:GetAttribute("ZoneId") then
        return false, "WrongZoneOrCarry"
    end
    -- Resolve from server-owned WorldRegistry and base assignment, not a client hint.
    local ok, resolvedExit, baseId = pcall(function()
        return self.resolveExit(carry.zoneId), self.assignedBase(userId)
    end)
    if not ok or resolvedExit ~= exitPart or not validBase(baseId) then
        return false, "UntrustedExitOrBase"
    end
    local now = self.clock()
    if not finite(now) or now < 0 then
        return false, "InvalidTime"
    end
    local character = self.observer:Character(userId)
    if not character or not positionValid(character.position) then
        return false, "NotReady"
    end
    local localPosition = exitPart.CFrame:PointToObjectSpace(character.position)
    local half = exitPart.Size * 0.5
    if
        not positionValid(localPosition)
        or math.abs(localPosition.X) > half.X
        or math.abs(localPosition.Y) > half.Y
        or localPosition.Z > -half.Z
        or localPosition.Z < -half.Z - APPROACH_RANGE
    then
        return false, "NotZoneSide"
    end
    self.paths[userId] = {
        crateId = carry.crateId,
        zoneId = carry.zoneId,
        baseId = baseId,
        exitPart = exitPart,
        originalCFrame = exitPart.CFrame,
        originalSize = exitPart.Size,
        stage = "Approach",
        position = character.position,
        at = now,
    }
    return true, nil
end

function ReturnProof:Cancel(userId: number)
    self.paths[userId] = nil
end

function ReturnProof:Status(userId: number): string
    local state = self.paths[userId]
    return state and state.stage or "Absent"
end

-- A save coordinator can consume an already-completed physical witness.
-- Never accept a caller-supplied witness or award anything before durable ACK.
function ReturnProof:Witness(userId: number)
    local state = self.paths[userId]
    if not state or state.stage ~= "AwaitingDurableCommit" then
        return nil, "NotWitnessed"
    end
    local carry = self.crates:GetCarry(userId)
    if
        not carry
        or carry.crateId ~= state.crateId
        or carry.zoneId ~= state.zoneId
        or (carry.tier ~= "Common" and carry.tier ~= "Rare")
        or type(carry.lootVersion) ~= "number"
        or carry.lootVersion % 1 ~= 0
        or carry.lootVersion < 1
        or carry.lootVersion > 2147483647
    then
        self:Cancel(userId)
        return nil, "CarryChanged"
    end
    local exitPart = state.exitPart
    if
        not exitPart:IsDescendantOf(workspace)
        or not exitPart.Anchored
        or exitPart:GetAttribute("ZoneId") ~= state.zoneId
        or exitPart:GetAttribute("ZoneSide") ~= "-Z"
        or exitPart.CFrame ~= state.originalCFrame
        or exitPart.Size ~= state.originalSize
    then
        self:Cancel(userId)
        return nil, "AnchorChanged"
    end
    local actor = self.observer:Character(userId)
    if not actor or not positionValid(actor.position) then
        self:Cancel(userId)
        return nil, "NotReady"
    end
    local point = exitPart.CFrame:PointToObjectSpace(actor.position)
    local half = exitPart.Size * 0.5
    if
        math.abs(point.X) > half.X
        or math.abs(point.Y) > half.Y
        or point.Z < half.Z
        or point.Z > half.Z + APPROACH_RANGE
    then
        self:Cancel(userId)
        return nil, "LeftExit"
    end
    return {
        crateId = state.crateId,
        zoneId = state.zoneId,
        tier = carry.tier,
        lootVersion = carry.lootVersion,
        exitId = state.zoneId,
    },
        nil
end

local function insideCrossSection(localPoint: Vector3, half: Vector3): boolean
    return math.abs(localPoint.X) <= half.X and math.abs(localPoint.Y) <= half.Y
end

function ReturnProof:Step(userId: number, speedCap: number)
    local state = self.paths[userId]
    if not state then
        return nil, "NotTracking"
    end
    if state.stage == "AwaitingDurableCommit" then
        return nil, "AlreadyWitnessed"
    end
    if not finite(speedCap) or speedCap <= 0 or speedCap > MAX_SPEED then
        self:Cancel(userId)
        return nil, "InvalidSpeedCap"
    end
    local current = self.crates:GetCarry(userId)
    if not current or current.crateId ~= state.crateId or current.zoneId ~= state.zoneId then
        self:Cancel(userId)
        return nil, "CarryChanged"
    end
    local now = self.clock()
    local character = self.observer:Character(userId)
    if not finite(now) or not character or not positionValid(character.position) then
        self:Cancel(userId)
        return nil, "InvalidObservation"
    end
    local elapsed = now - state.at
    if
        elapsed <= 0
        or elapsed > SAMPLE_GAP
        or (character.position - state.position).Magnitude > speedCap * elapsed + TOLERANCE
    then
        self:Cancel(userId)
        return nil, "InvalidTraversal"
    end
    local exitPart = state.exitPart
    if
        not exitPart:IsDescendantOf(workspace)
        or not exitPart.Anchored
        or exitPart:GetAttribute("ZoneId") ~= state.zoneId
        or exitPart:GetAttribute("ZoneSide") ~= "-Z"
        or exitPart.CFrame ~= state.originalCFrame
        or exitPart.Size ~= state.originalSize
    then
        self:Cancel(userId)
        return nil, "AnchorChanged"
    end
    local half = exitPart.Size * 0.5
    local localPosition = exitPart.CFrame:PointToObjectSpace(character.position)
    if not insideCrossSection(localPosition, half) then
        self:Cancel(userId)
        return nil, "OutsideExit"
    end
    if state.stage == "Approach" then
        if localPosition.Z >= -half.Z and localPosition.Z <= 0 then
            state.stage = "Inside"
        elseif localPosition.Z > 0 then
            self:Cancel(userId)
            return nil, "SkippedEntrance"
        end
    elseif state.stage == "Inside" then
        if localPosition.Z < -half.Z then
            self:Cancel(userId)
            return nil, "Backtracked"
        elseif localPosition.Z > 0 and localPosition.Z <= half.Z then
            state.stage = "AcrossCenter"
        elseif localPosition.Z > half.Z then
            self:Cancel(userId)
            return nil, "SkippedCenter"
        end
    elseif state.stage == "AcrossCenter" then
        if localPosition.Z < 0 then
            self:Cancel(userId)
            return nil, "Backtracked"
        elseif localPosition.Z >= half.Z and localPosition.Z <= half.Z + APPROACH_RANGE then
            state.stage = "AwaitingDurableCommit"
        elseif localPosition.Z > half.Z + APPROACH_RANGE then
            self:Cancel(userId)
            return nil, "SkippedExit"
        end
    end
    state.position = character.position
    state.at = now
    if state.stage ~= "AwaitingDurableCommit" then
        return nil, "InProgress"
    end
    -- This witness MUST be committed via PlayerData.Transact under session fencing.
    -- It grants no item, does not bank a crate, and never teleports the player.
    return {
        crateId = state.crateId,
        zoneId = state.zoneId,
        baseId = state.baseId,
        returnCheckpoint = "Exit",
    },
        nil
end

return table.freeze(ReturnProof)
