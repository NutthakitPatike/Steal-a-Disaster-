--!strict
-- P1-04 isolated durable-return regression. In-memory UpdateAsync ONLY.
-- No Roblox DataStore, live player, remotes, map edits or Publish.
return function(): number
    local Schema = require(game.ServerScriptService.Server.ProfileSchema)
    local Transactions = require(game.ServerScriptService.Server.Transactions)
    local PlayerData = require(game.ServerScriptService.Server.PlayerData)
    local SessionLifecycle = require(game.ServerScriptService.Server.SessionLifecycle)
    local Checkpoint = require(game.ServerScriptService.Server.ReturnCheckpoint)
    local n = 0
    local function check(value: any, message: string)
        assert(value, message)
        n += 1
    end
    local function fakeStore()
        local store = { records = {}, failBefore = false, failAfter = false, callbackRetry = false }
        function store:UpdateAsync(key, transform)
            if self.failBefore then
                self.failBefore = false
                error("throttled before commit")
            end
            local previous = Schema.Clone(self.records[key])
            if self.callbackRetry then
                self.callbackRetry = false
                transform(Schema.Clone(previous))
            end
            local result = transform(Schema.Clone(previous))
            if result ~= nil then
                self.records[key] = Schema.Clone(result)
            end
            if self.failAfter then
                self.failAfter = false
                error("ACK lost after commit")
            end
            return Schema.Clone(result)
        end
        return store
    end
    local witness = {
        crateId = "crate_secure_00001",
        zoneId = "tornado_town",
        tier = "Rare",
        lootVersion = 3,
        exitId = "tornado_town",
    }
    local fakeProof = {
        valid = true,
        cancelled = 0,
        Witness = function(self, _userId)
            return self.valid and Schema.Clone(witness) or nil, "NotWitnessed"
        end,
        Cancel = function(self, _userId)
            self.valid = false
            self.cancelled += 1
        end,
    }
    local storage = fakeStore()
    local data = PlayerData.new(storage)
    local lifecycle = SessionLifecycle.new(data)
    local joined, joinIssue = lifecycle:Join(101, "test-server", 100)
    check(joined and joinIssue == nil, "staging-owned session acquired in memory")
    local coordinator = Checkpoint.new(lifecycle, fakeProof)

    local record = Schema.New()
    check(Checkpoint.Recovery(record) == nil, "no automatic recovery for default profile")
    local malicious = Schema.Clone(record)
    malicious.returnPending = { crateId = "bad" }
    local valid, issue = Schema.Validate(malicious)
    check(not valid and issue == "InvalidReturnPending", "partial pending profile rejected")
    malicious = Schema.Clone(record)
    malicious.returnPending = {
        crateId = "crate_secure_00001",
        zoneId = "tornado_town",
        tier = "Rare",
        lootVersion = 3,
        exitId = "tornado_town",
        checkpointVersion = 1,
        secureOperationId = "crate_secure_00001",
        securedAt = 101,
        extraField = true,
    }
    valid, issue = Schema.Validate(malicious)
    check(not valid and issue == "InvalidReturnPending", "unknown pending fields rejected")

    storage.callbackRetry = true
    storage.failAfter = true
    local receipt, problem = coordinator:Secure(101, 0, 101)
    check(receipt == nil and problem == "SavePending", "commit lost ACK blocks early success")
    local committed = storage.records["PlayerV1_101"]
    check(
        committed
            and committed.revision == 1
            and committed.returnPending.crateId == witness.crateId
            and committed.returnPending.secureOperationId == witness.crateId,
        "one durable checkpoint despite callback retry and lost ACK"
    )
    check(
        #committed.receiptOrder == 1
            and committed.coins == 0
            and next(committed.items) == nil
            and next(committed.bankedCrates) == nil,
        "secured checkpoint gives no coins, banked crate or inventory"
    )
    check(fakeProof.cancelled == 0, "no witness consumption until durable receipt")
    check(lifecycle:Status(101) == "Pending", "pending session fenced")
    receipt, problem = coordinator:Secure(101, 5, 102)
    check(
        receipt == nil and problem == "WrongPendingRevision",
        "ambiguous operation cannot switch revision"
    )
    check(
        storage.records["PlayerV1_101"].revision == 1,
        "invalid replay never makes an additional commit"
    )
    witness.crateId = "crate_attacker_modified"
    receipt, problem = coordinator:Secure(101, 0, 102)
    check(
        receipt
            and problem == nil
            and receipt.result.kind == "ReturnPending"
            and receipt.result.crateId == "crate_secure_00001"
            and receipt.revision == 1,
        "retry reconciles original immutable server witness"
    )
    check(
        fakeProof.cancelled == 1 and lifecycle:Status(101) == "Ready",
        "witness cleared only after ACK"
    )
    check(
        storage.records["PlayerV1_101"].revision == 1
            and #storage.records["PlayerV1_101"].receiptOrder == 1,
        "ACK retry did not duplicate durable record"
    )
    local view = Checkpoint.Recovery(storage.records["PlayerV1_101"])
    check(
        view
            and view.crateId == "crate_secure_00001"
            and view.returnCheckpoint == "SafeExit"
            and view.tier == "Rare",
        "rejoin instruction is original Zone safe exit, never base"
    )
    check(
        view.returnCheckpoint ~= "Banked" and view.returnCheckpoint ~= "Home",
        "recovery does not auto-deposit or open"
    )
    receipt, problem = coordinator:Secure(101, 1, 103)
    check(receipt == nil and problem == "NotWitnessed", "consumed witness cannot replay")
    local other = PlayerData.new(storage)
    local stolen, locked = other:Acquire(101, "other-server", 103)
    check(stolen == nil and locked == "Locked", "foreign session cannot seize locked profile")

    local original = {
        crateId = "crate_secure_00002",
        zoneId = "tornado_town",
        tier = "Common",
        lootVersion = 1,
        exitId = "tornado_town",
    }
    local mutation = Checkpoint.Mutation(original, 110)
    original.tier = "Rare"
    local after, err = Transactions.Apply(Schema.New(), original.crateId, 0, mutation)
    check(
        after and err == nil and after.returnPending.tier == "Common",
        "mutation never uses caller-modified witness after construction"
    )
    local repeatResult, repeatErr = Transactions.Apply(after, "crate_secure_00002", 0, mutation)
    check(
        repeatResult and repeatErr == nil and repeatResult.revision == 1,
        "duplicate operation ID replays same receipt"
    )
    local duplicate, duplicateIssue = Transactions.Apply(
        after,
        "crate_secure_00003",
        1,
        Checkpoint.Mutation({
            crateId = "crate_secure_00003",
            zoneId = "tornado_town",
            tier = "Common",
            lootVersion = 1,
            exitId = "tornado_town",
        }, 111)
    )
    check(
        duplicate == nil and duplicateIssue == "AlreadyReturning",
        "cannot overwrite existing secured crate"
    )
    local bad = Schema.Clone(after)
    bad.returnPending.secureOperationId = "forged"
    valid, issue = Schema.Validate(bad)
    check(
        not valid and issue == "InvalidReturnPending",
        "tampered durable operation identity rejected"
    )

    local full = Schema.New()
    for i = 1, 100 do
        full.items["item_" .. tostring(i)] = {
            speciesId = "species_1",
            rank = 1,
            variantId = "normal",
            originZone = "tornado_town",
            itemVersion = 1,
            locked = false,
            transferTracked = false,
            acquiredAt = 100,
        }
    end
    check(Schema.Validate(full) == true, "capacity edge fixture valid")
    local rejected, why = Transactions.Apply(
        full,
        "crate_full_00001",
        0,
        Checkpoint.Mutation({
            crateId = "crate_full_00001",
            zoneId = "tornado_town",
            tier = "Rare",
            lootVersion = 1,
            exitId = "tornado_town",
        }, 112)
    )
    check(
        rejected == nil and why == "CapacityFull" and full.returnPending == nil,
        "full inventory never accepts secured crate"
    )

    local banked = Schema.New()
    for i = 1, 3 do
        local crateId = "banked_crate_" .. tostring(i)
        banked.bankedCrates[crateId] = {
            zoneId = "tornado_town",
            tier = "Common",
            lootVersion = 1,
            hiddenSpeciesId = "species_1",
            hiddenVariantId = "normal",
            hiddenRank = 1,
            reservedItemId = crateId,
            bankOperationId = "b_" .. crateId,
        }
    end
    check(Schema.Validate(banked) == true, "bank capacity fixture valid")
    rejected, why = Transactions.Apply(
        banked,
        "crate_banked_00001",
        0,
        Checkpoint.Mutation({
            crateId = "crate_banked_00001",
            zoneId = "tornado_town",
            tier = "Common",
            lootVersion = 1,
            exitId = "tornado_town",
        }, 113)
    )
    check(rejected == nil and why == "CapacityFull", "bank cap three enforced")

    local lockedProfile = Schema.New()
    rejected, why = Transactions.Apply(
        lockedProfile,
        "crate_zone_00001",
        0,
        Checkpoint.Mutation({
            crateId = "crate_zone_00001",
            zoneId = "tsunami_coast",
            tier = "Rare",
            lootVersion = 2,
            exitId = "tsunami_coast",
        }, 114)
    )
    check(rejected == nil and why == "ZoneLocked", "locked zone checkpoint refused")
    local unknown = Schema.New()
    unknown.returnPending = { crateId = "incomplete" }
    check(Checkpoint.Recovery(unknown) == nil, "invalid profile never auto-recovers")
    return n
end
