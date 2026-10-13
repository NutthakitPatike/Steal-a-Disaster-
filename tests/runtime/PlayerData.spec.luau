--!strict
-- P1-03 isolated mock UpdateAsync contract tests; no DataStore keys are accessed.
return function(): number
    local Schema = require(game.ServerScriptService.Server.ProfileSchema)
    local Transactions = require(game.ServerScriptService.Server.Transactions)
    local PlayerData = require(game.ServerScriptService.Server.PlayerData)
    local n = 0
    local function check(value, label)
        assert(value, label)
        n += 1
    end
    local function fakeStore()
        local store = { records = {}, failBefore = false, failAfter = false, retryCallback = false }
        function store:UpdateAsync(key, fn)
            if self.failBefore then
                self.failBefore = false
                error("simulated throttle")
            end
            local previous = Schema.Clone(self.records[key])
            if self.retryCallback then
                self.retryCallback = false
                fn(Schema.Clone(previous))
            end
            local proposed = fn(Schema.Clone(previous))
            if proposed ~= nil then
                self.records[key] = Schema.Clone(proposed)
            end
            if self.failAfter then
                self.failAfter = false
                error("committed but lost ACK")
            end
            return Schema.Clone(proposed)
        end
        return store
    end
    local function grant(amount)
        return function(profile)
            profile.coins += amount
            return true, { delta = amount }
        end
    end
    local starter = Schema.New()
    check(Schema.Validate(starter) == true, "default valid")
    local invalid = Schema.Clone(starter)
    invalid.coins = -1
    local valid, reason = Schema.Validate(invalid)
    check(not valid and reason == "InvalidBalances", "negative invalid")
    invalid = Schema.Clone(starter)
    invalid.schemaVersion = 2
    valid, reason = Schema.Validate(invalid)
    check(not valid and reason == "FutureSchema", "future version invalid")
    local changed, issue = Transactions.Apply(starter, "invalid_item_01", 0, function(profile)
        profile.coins = -1
        return true, {}
    end)
    check(changed == nil and issue == "InvalidBalances" and starter.coins == 0, "rejected mutation unchanged")

    local store = fakeStore()
    local a, b = PlayerData.new(store), PlayerData.new(store)
    local p, e = a:Acquire(111, "server-A", 100)
    check(p ~= nil and e == nil and p.revision == 0, "new profile acquire")
    local other, why = b:Acquire(111, "server-B", 100)
    check(other == nil and why == "Locked", "concurrent owner rejected")
    local copy = a:GetServerSnapshot(111)
    copy.coins = 999
    check(a:GetServerSnapshot(111).coins == 0, "clone isolation")
    store.retryCallback = true
    local receipt, errorCode = a:Transact(111, "op_credit_00001", 0, 101, grant(80))
    check(receipt ~= nil and errorCode == nil and receipt.revision == 1, "commit callback retry")
    check(store.records["PlayerV1_111"].coins == 80, "retry did not double credit")
    receipt, errorCode = a:Transact(111, "op_credit_00001", 0, 102, grant(80))
    check(receipt and receipt.revision == 1 and not errorCode, "duplicate receipt replay")
    check(store.records["PlayerV1_111"].coins == 80, "duplicate no extra credit")
    receipt, errorCode = a:Transact(111, "op_credit_00002", 0, 103, grant(10))
    check(receipt == nil and errorCode == "StaleRevision", "stale rejection")
    check(store.records["PlayerV1_111"].coins == 80, "stale did not mutate")
    store.failAfter = true
    receipt, errorCode = a:Transact(111, "op_credit_00003", 1, 104, grant(5))
    check(receipt == nil and errorCode == "SavePending", "lost ACK unresolved")
    check(store.records["PlayerV1_111"].coins == 85, "lost ACK committed")
    local pendingRenewed, pendingRenewCode = a:Renew(111, 105)
    check(pendingRenewed and pendingRenewCode == nil, "pending write permits lease renewal")
    check(store.records["PlayerV1_111"].session.leaseExpiry == 225
        and store.records["PlayerV1_111"].coins == 85,
        "renew preserves pending gameplay outcome")
    receipt, errorCode = a:Transact(111, "op_credit_00004", 2, 105, grant(500))
    check(receipt == nil and errorCode == "Busy", "pending blocks new operation")
    receipt, errorCode = a:Transact(111, "op_credit_00003", 1, 106, grant(5))
    check(receipt and not errorCode and receipt.revision == 2, "retry resolves lost ACK")
    check(store.records["PlayerV1_111"].coins == 85, "lost ACK replay exact once")
    store.failBefore = true
    receipt, errorCode = a:Transact(111, "op_credit_00005", 2, 107, grant(1))
    check(receipt == nil and errorCode == "SavePending", "throttle unresolved")
    check(store.records["PlayerV1_111"].coins == 85, "throttle unchanged")
    receipt, errorCode = a:Transact(111, "op_credit_00005", 2, 108, grant(1))
    check(receipt and receipt.revision == 3, "throttle retry success")
    check(store.records["PlayerV1_111"].coins == 86, "throttle retry only once")
    local renewed, rc = a:Renew(111, 110)
    check(renewed and rc == nil, "renew session")
    other, why = b:Acquire(111, "server-B", 111)
    check(other == nil and why == "Locked", "renewed lease blocks takeover")
    other, why = b:Acquire(111, "server-B", 231)
    check(other and not why and other.session.generation > p.session.generation, "expiry fences owner")
    receipt, errorCode = a:Transact(111, "op_credit_00006", 3, 232, grant(99))
    check(receipt == nil and errorCode == "LeaseLost", "stale owner cannot write")
    check(store.records["PlayerV1_111"].coins == 86, "fenced write no mint")
    store.records["PlayerV1_222"] = { schemaVersion = 999 }
    local bad, badReason = a:Acquire(222, "server-A", 200)
    check(bad == nil and badReason == "FutureSchema", "future data fail closed")
    check(store.records["PlayerV1_222"].schemaVersion == 999, "future profile preserved")
    store.records["PlayerV1_333"] = { coins = -123 }
    bad, badReason = a:Acquire(333, "server-A", 200)
    check(bad == nil and badReason ~= nil, "corrupt profile denied")
    check(store.records["PlayerV1_333"].coins == -123, "corrupt profile preserved")
    local closed, closeError = b:Close(111, 232)
    check(closed and closeError == nil, "close owned session")
    p, e = a:Acquire(111, "server-A", 233)
    check(p and not e and p.coins == 86, "rejoin reloads committed balance")
    -- Acquiring a lease can also commit while the transport loses its ACK.
    local secondStore = fakeStore()
    secondStore.failAfter = true
    local c = PlayerData.new(secondStore)
    local result, acquireError = c:Acquire(444, "server-C", 200)
    check(result == nil and acquireError == "StorageUnavailable", "acquire lost ACK")
    local committedLease = secondStore.records["PlayerV1_444"].session
    check(committedLease ~= nil, "acquire actually committed")
    result, acquireError = c:Acquire(444, "server-C", 201)
    check(result and not acquireError and result.session.token == committedLease.token,
        "acquire retry reuses original token")
    check(result.session.generation == committedLease.generation, "acquire retry does not steal its own lease")
    local badOp, badCode = c:Transact(444, "op_error_00001", 0, 202, function()
        error("broken callback")
    end)
    check(badOp == nil and badCode == "MutationFailed", "callback exception is not committed")
    check(secondStore.records["PlayerV1_444"].revision == 0, "callback exception did not mutate storage")
    return n
end
