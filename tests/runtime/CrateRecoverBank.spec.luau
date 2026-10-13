--!strict
-- P1-04/P1-06 in-memory fault tests. Run inside isolated Studio test place.
-- Creates only two temporary, local BaseParts; no real players or DataStore.
return function(): number
    local Server = game.ServerScriptService.Server
    local Schema = require(Server.ProfileSchema)
    local PlayerData = require(Server.PlayerData)
    local SessionLifecycle = require(Server.SessionLifecycle)
    local Crates = require(Server.Crates)
    local Recovery = require(Server.CrateRecovery)
    local Bank = require(Server.CrateBank)
    local checks = 0
    local function check(ok: any, message: string)
        assert(ok, message)
        checks += 1
    end

    local crateId = "crate_recovery_0001"
    local pending = {
        crateId = crateId,
        zoneId = "tornado_town",
        tier = "Rare",
        lootVersion = 7,
        exitId = "tornado_town",
        checkpointVersion = 1,
        secureOperationId = crateId,
        securedAt = 100,
    }
    local store = { records = {}, callbackRetry = false, failAfter = false }
    function store:UpdateAsync(key, fn)
        local current = Schema.Clone(self.records[key])
        if self.callbackRetry then
            self.callbackRetry = false
            fn(Schema.Clone(current))
        end
        local proposed = fn(Schema.Clone(current))
        if proposed then
            self.records[key] = Schema.Clone(proposed)
        end
        if self.failAfter then
            self.failAfter = false
            error("saved, lost acknowledgement")
        end
        return Schema.Clone(proposed)
    end
    local profile = Schema.New()
    profile.returnPending = Schema.Clone(pending)
    check(Schema.Validate(profile) == true, "durable saved return valid")
    store.records["PlayerV1_101"] = Schema.Clone(profile)
    local data = PlayerData.new(store)
    local lifecycle = SessionLifecycle.new(data)
    local acquired = lifecycle:Join(101, "isolated-test-server", 100)
    check(acquired and acquired.returnPending.crateId == crateId, "owned session loads return")

    local exitPart = Instance.new("Part")
    exitPart.Name = "Mock_RecoveryExit"
    exitPart.Anchored = true
    exitPart.Size = Vector3.new(12, 12, 8)
    exitPart.CFrame = CFrame.new(0, 0, 0)
    exitPart:SetAttribute("ZoneId", "tornado_town")
    exitPart:SetAttribute("ZoneSide", "-Z")
    exitPart.Parent = workspace
    local base = Instance.new("Part")
    base.Name = "Mock_OwnBase"
    base.Anchored = true
    base.CFrame = CFrame.new(30, 0, 0)
    base:SetAttribute("BaseId", 2)
    base.Parent = workspace

    local now = 100
    local playerPosition = base.Position
    local observation = {
        Character = function(_self, userId)
            return userId == 101 and { position = playerPosition } or nil
        end,
    }
    local crates = Crates.new(function()
        return now
    end, function()
        return nil
    end)
    local recovery = Recovery.new(data, lifecycle, crates, observation, function(zone)
        return zone == "tornado_town" and exitPart or nil
    end)
    local marker, issue = Recovery.Marker(data:GetServerSnapshot(101), function(_zone)
        return exitPart
    end)
    check(
        marker
            and issue == nil
            and marker.zoneId == "tornado_town"
            and marker.position == Vector3.new(0, 0, 6),
        "rejoin marker stays at Zone safe exit"
    )
    local restored, restoreIssue = recovery:Resume(101)
    check(
        restored == nil and restoreIssue == "MustVisitExitCheckpoint",
        "rejoin at home does not grant a bankable carried crate"
    )
    check(crates:GetSecured(101) == nil, "rejoin at home cannot skip travel")
    playerPosition = marker.position
    restored, restoreIssue = recovery:Resume(101)
    check(
        restored
            and restoreIssue == nil
            and restored.crateId == crateId
            and restored.tier == "Rare"
            and restored.lootVersion == 7,
        "server profile restores immutable crate at exit"
    )
    check(
        crates:GetCarry(101) == nil and crates:GetSecured(101) ~= nil,
        "secured crate distinct from uncommitted PvE carry"
    )
    local repeated = recovery:Resume(101)
    check(repeated and repeated.crateId == crateId, "repeated recovery is idempotent")
    crates:ClearPlayer(101)
    check(
        crates:GetSecured(101) == nil
            and store.records["PlayerV1_101"].returnPending.crateId == crateId,
        "death/disconnect clears transient carry but not durable checkpoint"
    )
    restored = recovery:Resume(101)
    check(restored and restored.crateId == crateId, "rejoin recovery can retry")
    local loaned = Schema.New()
    loaned.returnPending = Schema.Clone(pending)
    local enemyRestore, enemyError = crates:RestoreSecured(202, loaned)
    check(
        enemyRestore == nil and enemyError == "DuplicateSecuredCrate",
        "same crate cannot be held by another player in this server"
    )

    local rolls = 0
    local service = Bank.new(lifecycle, data, crates, observation, function(baseId)
        return baseId == 2 and base or nil
    end, function(userId)
        return userId == 101 and 2 or nil
    end, function(saved)
        rolls += 1
        check(
            saved.crateId == crateId and saved.tier == "Rare",
            "loot based on trusted persisted tier"
        )
        return { speciesId = "tornado_alpha", variantId = "normal", rank = 2 }
    end, function(saved, outcome)
        return saved.lootVersion == 7
            and outcome.speciesId == "tornado_alpha"
            and outcome.variantId == "normal"
            and outcome.rank == 2
    end)
    local denied, deniedCode = service:Deposit(101, 0, 101)
    check(
        denied == nil and deniedCode == "OutOfRange" and rolls == 0,
        "cannot bank remotely from safe-exit marker"
    )
    playerPosition = base.Position
    store.callbackRetry = true
    store.failAfter = true
    local receipt, saveCode = service:Deposit(101, 0, 102)
    check(
        receipt == nil and saveCode == "SavePending" and rolls == 1,
        "first save with lost ACK blocks grant"
    )
    local written = store.records["PlayerV1_101"]
    check(
        written.revision == 1
            and written.returnPending == nil
            and written.bankedCrates[crateId].hiddenSpeciesId == "tornado_alpha"
            and written.bankedCrates[crateId].hiddenRank == 2,
        "one banked outcome committed despite callback retry"
    )
    check(
        written.coins == 0 and next(written.items) == nil and #written.receiptOrder == 1,
        "banking never grants item or coins"
    )
    check(
        crates:GetSecured(101) ~= nil and lifecycle:Status(101) == "Pending",
        "do not release carry without positive durable acknowledgement"
    )
    receipt, saveCode = service:Deposit(101, 1, 103)
    check(
        receipt == nil and saveCode == "WrongPendingRevision",
        "ambiguous save forbids changing revision"
    )
    receipt, saveCode = service:Deposit(101, 0, 104)
    check(
        receipt
            and saveCode == nil
            and receipt.result.kind == "Banked"
            and receipt.result.crateId == crateId
            and receipt.revision == 1,
        "retry returns original persisted receipt"
    )
    check(
        rolls == 1 and crates:GetSecured(101) == nil and lifecycle:Status(101) == "Ready",
        "lost ACK retry did not reroll or leave old carry"
    )
    check(
        Schema.Validate(data:GetServerSnapshot(101)) == true,
        "recovered snapshot satisfies banked schema"
    )
    restored, restoreIssue = recovery:Resume(101)
    check(
        restored == nil and restoreIssue == "NotReturning",
        "banked crate cannot be rehydrated a second time"
    )
    denied, deniedCode = service:Deposit(101, 1, 105)
    check(
        denied == nil and deniedCode == "NotReturning" and rolls == 1,
        "duplicate deposit cannot reroll after committed bank"
    )

    local tampered = Schema.Clone(store.records["PlayerV1_101"])
    tampered.bankedCrates[crateId].hiddenSpeciesId = ""
    local schemaOk, schemaErr = Schema.Validate(tampered)
    check(not schemaOk and schemaErr == "InvalidBankedCrate", "missing hidden reward fails closed")
    tampered = Schema.Clone(store.records["PlayerV1_101"])
    tampered.bankedCrates[crateId].bankOperationId = "forged"
    schemaOk, schemaErr = Schema.Validate(tampered)
    check(
        not schemaOk and schemaErr == "InvalidBankedCrate",
        "bank operation identity cannot be forged"
    )
    tampered = Schema.Clone(store.records["PlayerV1_101"])
    tampered.items[crateId] = {
        speciesId = "tornado_alpha",
        rank = 1,
        variantId = "normal",
        originZone = "tornado_town",
        acquiredAt = 105,
        itemVersion = 1,
        locked = false,
        transferTracked = false,
    }
    schemaOk, schemaErr = Schema.Validate(tampered)
    check(
        not schemaOk and schemaErr == "InvalidBankedCrate",
        "banked and owned duplicate ID rejected"
    )
    -- The first safe-exit save can happen BEFORE disconnect: converting the
    -- same live PvE carry to secured must work without any duplicate pickup.
    local direct = Crates.new(function()
        return 100
    end, function(_userId, _crate)
        return {
            ready = true,
            alive = true,
            visible = true,
            position = Vector3.new(0, 0, 0),
        }
    end)
    local registered =
        direct:Register("crate_direct_0001", "tornado_town", "Common", 1, Vector3.new(0, 0, 0))
    check(registered, "direct live crate registered")
    local grabbed = direct:Begin(101, "crate_direct_0001", "Snatch")
    check(grabbed and direct:GetCarry(101), "player has temporary PvE carry")
    local securedProfile = Schema.New()
    securedProfile.returnPending = {
        crateId = "crate_direct_0001",
        zoneId = "tornado_town",
        tier = "Common",
        lootVersion = 1,
        exitId = "tornado_town",
        checkpointVersion = 1,
        secureOperationId = "crate_direct_0001",
        securedAt = 100,
    }
    local converted, convertedIssue = direct:RestoreSecured(101, securedProfile)
    check(
        converted and convertedIssue == nil and not direct:GetCarry(101) and direct:GetSecured(101),
        "same crate converts from live capture to durable secured carry"
    )
    direct:ClearPlayer(101)
    check(
        not direct:GetSecured(101) and securedProfile.returnPending ~= nil,
        "later disconnect never erases durable checkpoint"
    )
    exitPart:Destroy()
    base:Destroy()
    return checks
end
