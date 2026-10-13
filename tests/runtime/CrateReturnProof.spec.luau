--!strict
-- Server-only boundary tests. Creates and destroys a temporary NON-PERSISTENT anchor.
return function(): number
    local Proof = require(game.ServerScriptService.Server.CrateReturnProof)
    local count = 0
    local function check(value: any, why: string)
        assert(value, why)
        count += 1
    end
    local exit = Instance.new("Part")
    exit.Name = "MockExit_DoNotSave"
    exit.Anchored = true
    exit.Size = Vector3.new(12, 12, 8)
    exit.CFrame = CFrame.new(0, 0, 0)
    exit:SetAttribute("ZoneId", "tornado_town")
    exit:SetAttribute("ZoneSide", "-Z")
    exit.Parent = workspace

    local time = 100
    local position = Vector3.new(0, 0, -5)
    local alive = true
    local assigned = 2
    local carried = {
        crateId = "crate_return_0001",
        zoneId = "tornado_town",
        tier = "Rare",
        lootVersion = 2,
    }
    local service = {
        GetCarry = function(_self, id)
            return id == 101 and carried or nil
        end,
    }
    local sensor = {
        Character = function(_self, id)
            return id == 101 and alive and { position = position } or nil
        end,
    }
    local trustedExit = exit
    local gate = Proof.new(service, sensor, function()
        return time
    end, function(zone)
        return zone == "tornado_town" and trustedExit or nil
    end, function(id)
        return id == 101 and assigned or nil
    end)

    local result, code = gate:Begin(101, exit)
    check(
        result and code == nil and gate:Status(101) == "Approach",
        "zone-facing approach accepted"
    )
    local duplicate, reason = gate:Begin(101, exit)
    check(not duplicate and reason == "AlreadyTracking", "duplicate crossing not restarted")
    time += 0.1
    position = Vector3.new(0, 0, -3)
    local proof, issue = gate:Step(101, 70)
    check(
        proof == nil and issue == "InProgress" and gate:Status(101) == "Inside",
        "inside zone exit volume"
    )
    time += 0.1
    position = Vector3.new(0, 0, 0.5)
    proof, issue = gate:Step(101, 70)
    check(
        proof == nil and issue == "InProgress" and gate:Status(101) == "AcrossCenter",
        "crossed center in proper order"
    )
    time += 0.1
    position = Vector3.new(0, 0, 4.5)
    proof, issue = gate:Step(101, 70)
    check(
        proof
            and issue == nil
            and proof.crateId == carried.crateId
            and proof.baseId == 2
            and proof.returnCheckpoint == "Exit"
            and gate:Status(101) == "AwaitingDurableCommit",
        "full physical crossing grants ONLY commit intent"
    )
    local replay, replayReason = gate:Step(101, 70)
    check(replay == nil and replayReason == "AlreadyWitnessed", "cannot mint second witness")
    local secured, secureError = gate:Witness(101)
    check(
        secured
            and secureError == nil
            and secured.crateId == carried.crateId
            and secured.tier == "Rare"
            and secured.lootVersion == 2
            and secured.exitId == "tornado_town",
        "durable witness derives tier and loot version from server-owned carry"
    )
    check(service:GetCarry(101) == carried, "witness never consumes crate or grants item")
    gate:Cancel(101)
    secured, secureError = gate:Witness(101)
    check(
        secured == nil and secureError == "NotWitnessed",
        "cancelled crossing cannot authorize save"
    )
    check(gate:Status(101) == "Absent", "cancel releases witness")

    position = Vector3.new(0, 0, 5)
    result, code = gate:Begin(101, exit)
    check(not result and code == "NotZoneSide", "cannot begin from hub side")
    position = Vector3.new(0, 0, -5)
    assigned = nil
    result, code = gate:Begin(101, exit)
    check(not result and code == "UntrustedExitOrBase", "missing own base denied")
    assigned = 2
    trustedExit = nil
    result, code = gate:Begin(101, exit)
    check(not result and code == "UntrustedExitOrBase", "unregistered exit denied")
    trustedExit = exit

    result = gate:Begin(101, exit)
    time += 0.1
    position = Vector3.new(0, 0, 1)
    proof, issue = gate:Step(101, 70)
    check(
        proof == nil and issue == "SkippedEntrance" and gate:Status(101) == "Absent",
        "one-frame exit skip denied"
    )
    position = Vector3.new(0, 0, -5)
    gate:Begin(101, exit)
    time += 0.1
    position = Vector3.new(6.1, 0, -3)
    proof, issue = gate:Step(101, 70)
    check(proof == nil and issue == "OutsideExit", "off-axis shortcut denied")

    position = Vector3.new(0, 0, -5)
    gate:Begin(101, exit)
    time += 0.3
    position = Vector3.new(0, 0, -3)
    proof, issue = gate:Step(101, 70)
    check(proof == nil and issue == "InvalidTraversal", "long sample gap denied")

    position = Vector3.new(0, 0, -5)
    gate:Begin(101, exit)
    time += 0.1
    position = Vector3.new(0, 0, -2)
    proof, issue = gate:Step(101, 1)
    check(proof == nil and issue == "InvalidTraversal", "server speed cap enforced")

    position = Vector3.new(0, 0, -5)
    gate:Begin(101, exit)
    exit.CFrame = CFrame.new(0, 0, 2)
    time += 0.1
    position = Vector3.new(0, 0, -3)
    proof, issue = gate:Step(101, 70)
    check(proof == nil and issue == "AnchorChanged", "moving exit cannot forge crossing")
    exit.CFrame = CFrame.new(0, 0, 0)

    position = Vector3.new(0, 0, -5)
    gate:Begin(101, exit)
    carried = nil
    time += 0.1
    proof, issue = gate:Step(101, 70)
    check(proof == nil and issue == "CarryChanged", "lost crate cancels route")

    carried = { crateId = "crate_return_0001", zoneId = "tornado_town" }
    gate:Begin(101, exit)
    alive = false
    time += 0.1
    proof, issue = gate:Step(101, 70)
    check(proof == nil and issue == "InvalidObservation", "death cancels route")

    exit:Destroy()
    return count
end
