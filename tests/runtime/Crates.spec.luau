--!strict
-- P1-04 isolated mock tests: no Roblox users, remotes, persistent data or map edits.
return function(): number
    local Crates = require(game.ServerScriptService.Server.Crates)
    local checks = 0
    local function check(value, message: string)
        assert(value, message)
        checks += 1
    end
    local now = 100
    local origin = Vector3.new(0, 0, 0)
    local users = {
        [11] = { position = origin, ready = true, alive = true, visible = true },
        [22] = { position = origin, ready = true, alive = true, visible = true },
    }
    local service = Crates.new(function()
        return now
    end, function(userId, _crate)
        return users[userId]
    end)
    local ok, issue = service:Register("crate_0001", "tornado_town", "Common", 1, origin)
    check(
        ok and issue == nil and service:Status("crate_0001") == "Available",
        "register allowed tier"
    )
    ok, issue = service:Register("crate_0001", "tornado_town", "Rare", 1, origin)
    check(not ok and issue == "DuplicateCrate", "duplicate crate ID rejected")
    ok, issue = service:Register("crate_0002", "invalid_zone", "Common", 1, origin)
    check(not ok and issue == "InvalidCrate", "invalid zone rejected")
    ok, issue = service:Register("crate_0002", "tornado_town", "Secret", 1, origin)
    check(not ok and issue == "InvalidCrate", "non-launch tier rejected")
    local held, holdIssue = service:Begin(11, "crate_0001", "Stabilize")
    check(held and holdIssue == nil and held.status == "Holding", "Stabilize reserves crate")
    local contested, reason = service:Begin(22, "crate_0001", "Snatch")
    check(contested == nil and reason == "Unavailable", "simultaneous claim cannot win")
    local premature, early = service:Finish(11, "crate_0001")
    check(premature == nil and early == "TooSoon", "cannot fake 2 second hold")
    users[11].position = Vector3.new(3, 0, 0)
    now = 100.1
    service:Heartbeat()
    check(service:Status("crate_0001") == "Available", "moving more than 2 studs cancels")
    users[11].position = origin
    local snatched, snatchError = service:Begin(22, "crate_0001", "Snatch")
    check(
        snatched
            and snatchError == nil
            and snatched.method == "Snatch"
            and snatched.tier == "Common"
            and snatched.lootVersion == 1
            and snatched.alertAt == now + 0.75,
        "Snatch claims fixed tier instantly"
    )
    local cannotRetake, retakeError = service:Begin(11, "crate_0001", "Snatch")
    check(cannotRetake == nil and retakeError == "Unavailable", "one permanent winner")
    service:Register("crate_0002", "tornado_town", "Rare", 2, origin)
    local second, secondError = service:Begin(22, "crate_0002", "Snatch")
    check(second == nil and secondError == "AlreadyCarrying", "one carried crate per player")
    local carry = service:GetCarry(22)
    check(
        carry and carry.crateId == "crate_0001" and carry.zoneId == "tornado_town",
        "server-controlled carry record"
    )
    service:ClearPlayer(22)
    check(
        not service:GetCarry(22) and service:Status("crate_0001") == "Lost",
        "unsecured crate lost on player departure"
    )

    local invalid, invalidIssue = service:Begin(11, "crate_0002", "Snatch")
    check(
        invalid
            and invalidIssue == nil
            and invalid.method == "Snatch"
            and invalid.tier == "Rare"
            and invalid.lootVersion == 2,
        "method never modifies registered tier or loot pool version"
    )
    service:ClearPlayer(11)

    service:Register("crate_0003", "tornado_town", "Rare", 3, origin)
    users[11].visible = false
    invalid, invalidIssue = service:Begin(11, "crate_0003", "Snatch")
    check(invalid == nil and invalidIssue == "InvalidActor", "LOS must be server observed")
    users[11].visible = true
    users[11].ready = false
    invalid, invalidIssue = service:Begin(11, "crate_0003", "Snatch")
    check(invalid == nil and invalidIssue == "InvalidActor", "profile readiness enforced")
    users[11].ready = true
    users[11].position = Vector3.new(11, 0, 0)
    invalid, invalidIssue = service:Begin(11, "crate_0003", "Snatch")
    check(invalid == nil and invalidIssue == "OutOfRange", "10 stud bound enforced")
    users[11].position = Vector3.new(math.huge, 0, 0)
    invalid, invalidIssue = service:Begin(11, "crate_0003", "Snatch")
    check(
        invalid == nil and invalidIssue == "InvalidActor",
        "nonfinite character position rejected"
    )
    users[11].position = origin

    local initiated = service:Begin(11, "crate_0003", "Stabilize")
    check(initiated and service:Status("crate_0003") == "Reserved", "hold can restart")
    local concurrent, concurrentError = service:Begin(11, "crate_0002", "Stabilize")
    check(
        concurrent == nil and concurrentError == "AlreadyHolding",
        "one reserved crate per player"
    )
    for sample = 1, 20 do
        now = 100.1 + sample * 0.1
        service:Heartbeat()
    end
    now = 102.11
    local completed, completedError = service:Finish(11, "crate_0003")
    check(
        completed
            and completedError == nil
            and completed.method == "Stabilize"
            and completed.alertAt == now + 2.5
            and completed.lootVersion == 3,
        "10 Hz verified full hold grants only original crate"
    )
    check(
        service:Status("crate_0003") == "Carried" and service:GetCarry(11),
        "successful hold changes state and records carry"
    )
    service:ClearPlayer(11)

    now = 150
    service:Register("crate_0004", "tornado_town", "Common", 1, origin)
    service:Begin(11, "crate_0004", "Stabilize")
    now = 152.1
    local stale, staleIssue = service:Finish(11, "crate_0004")
    check(
        stale == nil
            and staleIssue == "HoldInterrupted"
            and service:Status("crate_0004") == "Available",
        "two seconds without server samples fails closed"
    )
    now = 152.2
    service:Begin(11, "crate_0004", "Stabilize")
    now = 152.6
    service:Heartbeat()
    check(service:Status("crate_0004") == "Available", "missed server sampling window cancels hold")
    now = 152.7
    service:Begin(11, "crate_0004", "Stabilize")
    users[11].alive = false
    service:Heartbeat()
    check(service:Status("crate_0004") == "Available", "death cancels hold")
    users[11].alive = true
    service:Begin(11, "crate_0004", "Stabilize")
    check(
        service:Cancel(11) and service:Status("crate_0004") == "Available",
        "client release frees reservation"
    )
    check(not service:Cancel(11), "duplicate cancel has no effect")

    now = 242.2
    service:Heartbeat()
    check(service:Status("crate_0004") == "Expired", "90 second TTL enforced")
    now = 273
    service:Heartbeat()
    check(service:Status("crate_0004") == "Absent", "expired crate garbage collected")
    check(service:Status("crate_0001") == "Absent", "lost crate garbage collected")
    local invalidSpawn, spawnCode =
        service:Register("crate_bad_pos", "tornado_town", "Common", 1, Vector3.new(math.huge, 0, 0))
    check(invalidSpawn == nil and spawnCode == "InvalidCrate", "nonfinite spawn vector rejected")

    for index = 1, 4 do
        local registered =
            service:Register("limit_000" .. tostring(index), "tsunami_coast", "Common", 1, origin)
        check(registered, "four crate per zone limit allows " .. tostring(index))
    end
    local denied, deniedReason =
        service:Register("limit_0005", "tsunami_coast", "Common", 1, origin)
    check(denied == nil and deniedReason == "ZoneOrWorldFull", "fifth zone crate blocked")

    -- A reservation that started just before the normal TTL may finish its
    -- verified 2s hold. TTL expiration alone cannot steal a reserved crate.
    now = 300
    service:Register("near_expiry_01", "tornado_town", "Rare", 4, origin)
    now = 389.9
    local reserve = service:Begin(11, "near_expiry_01", "Stabilize")
    check(reserve and reserve.status == "Holding", "reserved just before TTL")
    for sample = 1, 20 do
        now = 389.9 + sample * 0.1
        service:Heartbeat()
    end
    now = 391.91
    local afterExpiry, afterExpiryError = service:Finish(11, "near_expiry_01")
    check(
        afterExpiry
            and afterExpiryError == nil
            and afterExpiry.tier == "Rare"
            and service:Status("near_expiry_01") == "Carried",
        "valid reservation survives normal crate TTL"
    )
    service:ClearPlayer(11)
    return checks
end
