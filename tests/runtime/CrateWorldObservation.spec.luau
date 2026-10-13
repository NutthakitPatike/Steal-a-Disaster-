--!strict
-- Mock-only tests. No live players, remotes, physical world edits or DataStore.
return function(): number
    local Sensor = require(game.ServerScriptService.Server.CrateWorldObservation)
    local Crates = require(game.ServerScriptService.Server.Crates)
    local Driver = require(game.ServerScriptService.Server.CrateHeartbeat)
    local checks = 0
    local function check(condition: any, message: string)
        assert(condition, message)
        checks += 1
    end

    local character = Instance.new("Model")
    character.Name = "MockCharacter"
    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = character
    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Anchored = true
    root.Position = Vector3.new(0, 4, 0)
    root.Parent = character

    local active = true
    local player = { Character = character }
    local lookup = {
        GetPlayerByUserId = function(_self, id)
            return id == 101 and player or nil
        end,
    }
    local blockDistance = nil
    local shouldThrow = false
    local rayCount = 0
    local world = {
        Raycast = function(_self, origin, direction, params)
            rayCount += 1
            check(
                origin.Y == 5.5 and direction.Magnitude > 0,
                "ray originates at server root position"
            )
            check(
                params.FilterType == Enum.RaycastFilterType.Exclude
                    and params.FilterDescendantsInstances[1] == character
                    and params.RespectCanCollide == true,
                "authoritative ray excludes only actor and honors collisions"
            )
            if shouldThrow then
                error("simulated raycast failure")
            end
            return blockDistance and { Distance = blockDistance } or nil
        end,
    }
    local sensor = Sensor.new(function(id)
        return id == 101 and active
    end, lookup, world)

    local observed, code = sensor:Character(0)
    check(observed == nil and code == "InvalidUser", "invalid user rejected")
    observed, code = sensor:Character(999)
    check(observed == nil and code == "NotReady", "unknown user not ready")
    local position = sensor:Character(101)
    check(position ~= nil and position.position == root.Position, "server root read")
    active = false
    observed, code = sensor:Character(101)
    check(observed == nil and code == "NotReady", "missing lease blocks capture")
    active = true
    local crate = { id = "crate_test_0001", position = Vector3.new(0, 4, 8) }
    local open = sensor:Capture(101, crate)
    check(
        open ~= nil
            and open.ready
            and open.alive
            and open.visible
            and open.position == root.Position,
        "unobstructed LOS"
    )
    blockDistance = 2
    local blocked = sensor:Capture(101, crate)
    check(blocked and not blocked.visible, "physical wall blocks capture")
    blockDistance = 7.9
    local nearEndpoint = sensor:Capture(101, crate)
    check(nearEndpoint and nearEndpoint.visible, "endpoint tolerance near crate")
    blockDistance = nil
    shouldThrow = true
    local unavailable = sensor:Capture(101, crate)
    check(unavailable and unavailable.visible == false, "Raycast errors fail closed")
    shouldThrow = false
    root.Position = Vector3.new(0, 4, 12)
    local tooFar = sensor:Capture(101, crate)
    check(tooFar and tooFar.position == root.Position, "sensor always uses actual root")
    root.Position = Vector3.new(math.huge, 4, 0)
    observed, code = sensor:Character(101)
    check(observed == nil and code == "InvalidCharacter", "infinite server position rejected")
    root.Position = Vector3.new(0, 4, 0)
    humanoid.Health = 0
    observed, code = sensor:Character(101)
    check(observed == nil and code == "InvalidCharacter", "dead character rejected")
    humanoid.Health = 100
    observed = sensor:Character(101)
    check(observed ~= nil, "respawn-ready model can be observed")

    local t = 100
    local crates = Crates.new(function()
        return t
    end, function(id, currentCrate)
        return sensor:Capture(id, currentCrate)
    end)
    local valid = crates:Register("crate_test_0001", "tornado_town", "Common", 1, crate.position)
    check(valid, "crate registered")
    blockDistance = 2
    local claimed, reason = crates:Begin(101, "crate_test_0001", "Snatch")
    check(claimed == nil and reason == "InvalidActor", "wall rejects real capture core")
    blockDistance = nil
    claimed, reason = crates:Begin(101, "crate_test_0001", "Snatch")
    check(claimed and reason == nil and crates:GetCarry(101), "real capture uses physical sensor")
    crates:ClearPlayer(101)
    check(not crates:GetCarry(101), "departed player loses unsecured carry")
    check(rayCount >= 5, "raycast was invoked during observation")

    local heartbeats = 0
    local fakeCrates = {
        Heartbeat = function(_self)
            heartbeats += 1
            return true, nil
        end,
    }
    local driver = Driver.new(fakeCrates, function()
        return t
    end)
    local ok = driver:Step()
    check(ok and heartbeats == 1, "driver ticks once on first sample")
    t += 0.05
    driver:Step()
    check(heartbeats == 1, "driver rate limits sub-100ms samples")
    t += 0.06
    driver:Step()
    check(heartbeats == 2, "driver resumes on 100ms interval")
    t -= 1
    local good, clockIssue = driver:Step()
    check(
        good == false and clockIssue == "ClockRegressed" and heartbeats == 2,
        "backwards monotonic clock rejected"
    )
    driver:Stop()
    check(not driver.running, "stopped driver stays inactive without Start")
    character:Destroy()
    return checks
end
