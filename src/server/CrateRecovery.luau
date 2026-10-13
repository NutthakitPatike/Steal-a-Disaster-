--!strict
-- P1-04 opt-in safe-exit recovery. No teleport, prompt, inventory or DataStore.
-- The player must physically return to the saved Zone exit to pick up their
-- secured crate; rejoining at home is NOT equivalent to delivery.
local RunService = game:GetService("RunService")
local Schema = require(script.Parent:WaitForChild("ProfileSchema"))
local Recovery = {}
Recovery.__index = Recovery

local CHECKPOINT_RADIUS = 8

local function finiteVector(position: any): boolean
    return typeof(position) == "Vector3"
        and position.X == position.X
        and position.Y == position.Y
        and position.Z == position.Z
        and math.abs(position.X) < 1000000
        and math.abs(position.Y) < 1000000
        and math.abs(position.Z) < 1000000
end

function Recovery.new(
    data: any,
    lifecycle: any,
    crates: any,
    observer: any,
    resolveExit: (string) -> BasePart?
)
    assert(RunService:IsServer(), "ServerOnly")
    assert(
        type(data) == "table"
            and type(data.GetServerSnapshot) == "function"
            and type(lifecycle) == "table"
            and type(lifecycle.Status) == "function"
            and type(crates) == "table"
            and type(crates.RestoreSecured) == "function"
            and type(observer) == "table"
            and type(observer.Character) == "function"
            and type(resolveExit) == "function",
        "Trusted recovery services required"
    )
    return setmetatable({
        data = data,
        lifecycle = lifecycle,
        crates = crates,
        observer = observer,
        resolveExit = resolveExit,
    }, Recovery)
end

-- Pure lookup: caller uses this to display a waypoint, NEVER to teleport.
function Recovery.Marker(profile: any, resolveExit: (string) -> BasePart?)
    if not Schema.Validate(profile) or not profile.returnPending then
        return nil, "NotReturning"
    end
    local pending = profile.returnPending
    local ok, anchor = pcall(resolveExit, pending.zoneId)
    if
        not ok
        or typeof(anchor) ~= "Instance"
        or not anchor:IsA("BasePart")
        or not anchor.Anchored
        or not anchor:IsDescendantOf(workspace)
        or anchor:GetAttribute("ZoneId") ~= pending.zoneId
        or anchor:GetAttribute("ZoneSide") ~= "-Z"
        or not finiteVector(anchor.Position)
    then
        return nil, "InvalidExit"
    end
    local marker = anchor.CFrame:PointToWorldSpace(Vector3.new(0, 0, anchor.Size.Z / 2 + 2))
    if not finiteVector(marker) then
        return nil, "InvalidExit"
    end
    return { crateId = pending.crateId, zoneId = pending.zoneId, position = marker }, nil
end

-- Call from a SERVER prompt after server-owned profile is acquired and ready.
-- Does not move the player or make any durable profile changes.
function Recovery:Resume(userId: number)
    if
        type(userId) ~= "number"
        or userId <= 0
        or userId % 1 ~= 0
        or self.lifecycle:Status(userId) ~= "Ready"
    then
        return nil, "NotReady"
    end
    local profile = self.data:GetServerSnapshot(userId)
    local marker, issue = Recovery.Marker(profile, self.resolveExit)
    if not marker then
        return nil, issue
    end
    local observed = self.observer:Character(userId)
    if
        not observed
        or not finiteVector(observed.position)
        or (observed.position - marker.position).Magnitude > CHECKPOINT_RADIUS
    then
        return nil, "MustVisitExitCheckpoint"
    end
    local restored, restoreIssue = self.crates:RestoreSecured(userId, profile)
    if not restored then
        return nil, restoreIssue
    end
    return restored, nil
end

return table.freeze(Recovery)
