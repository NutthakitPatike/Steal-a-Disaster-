--!strict
-- P1-04: opt-in, server-only physical observation of an active player.
-- Readiness and character state are server-owned. The client supplies NO position,
-- health, line-of-sight flag, crate tier or timestamp. Not connected to remotes.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Observation = {}
Observation.__index = Observation

local MAX_COORDINATE = 1000000
local SIGHT_HEIGHT = 1.5
local ENDPOINT_TOLERANCE = 0.25

local function finitePosition(value: any): boolean
    return typeof(value) == "Vector3"
        and value.X == value.X
        and value.Y == value.Y
        and value.Z == value.Z
        and math.abs(value.X) < MAX_COORDINATE
        and math.abs(value.Y) < MAX_COORDINATE
        and math.abs(value.Z) < MAX_COORDINATE
end

-- The optional services are solely for deterministic server-side test doubles.
-- Never construct this with services or callbacks taken from a RemoteEvent.
function Observation.new(isReady: (number) -> boolean, players: any?, world: any?)
    assert(RunService:IsServer(), "ServerOnly")
    assert(type(isReady) == "function", "Server-owned readiness callback required")
    local playerService = players or Players
    local worldService = world or Workspace
    assert(type(playerService.GetPlayerByUserId) == "function", "Player lookup required")
    assert(type(worldService.Raycast) == "function", "Workspace Raycast required")
    return setmetatable({
        isReady = isReady,
        players = playerService,
        world = worldService,
    }, Observation)
end

function Observation:Character(userId: number)
    if type(userId) ~= "number" or userId % 1 ~= 0 or userId <= 0 or userId > 9007199254740991 then
        return nil, "InvalidUser"
    end
    local readyOk, ready = pcall(self.isReady, userId)
    if not readyOk or ready ~= true then
        return nil, "NotReady"
    end
    local found, player = pcall(function()
        return self.players:GetPlayerByUserId(userId)
    end)
    if not found or not player then
        return nil, "MissingPlayer"
    end
    local character = player.Character
    if typeof(character) ~= "Instance" or not character:IsA("Model") then
        return nil, "MissingCharacter"
    end
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if
        not root
        or not root:IsA("BasePart")
        or not humanoid
        or humanoid.Health <= 0
        or humanoid:GetState() == Enum.HumanoidStateType.Dead
        or not finitePosition(root.Position)
    then
        return nil, "InvalidCharacter"
    end
    return {
        character = character,
        humanoid = humanoid,
        position = root.Position,
        root = root,
    },
        nil
end

-- Used by Crates.new(..., function(userId, crate) return sensor:Capture(...) end).
-- The complete crate record is trusted server state and never exposed to players.
function Observation:Capture(userId: number, crate: any)
    local character = self:Character(userId)
    if not character or type(crate) ~= "table" or not finitePosition(crate.position) then
        return nil
    end
    local origin = character.position + Vector3.new(0, SIGHT_HEIGHT, 0)
    local target = crate.position + Vector3.new(0, SIGHT_HEIGHT, 0)
    local direction = target - origin
    if direction.Magnitude > 10 or direction.Magnitude ~= direction.Magnitude then
        return {
            ready = true,
            alive = true,
            visible = false,
            position = character.position,
        }
    end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { character.character }
    params.IgnoreWater = true
    -- Only physical blockers should affect capture, not invisible trigger volumes.
    params.RespectCanCollide = true
    local success, hit = pcall(function()
        return self.world:Raycast(origin, direction, params)
    end)
    -- On Raycast failure, fail closed rather than allowing a through-wall claim.
    local visible = success
        and (
            not hit
            or (
                type(hit.Distance) == "number"
                and hit.Distance >= direction.Magnitude - ENDPOINT_TOLERANCE
            )
        )
    return {
        ready = true,
        alive = true,
        visible = visible,
        position = character.position,
    }
end

return table.freeze(Observation)
