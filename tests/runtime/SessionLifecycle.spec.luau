--!strict
-- Isolated lifecycle state-machine tests. No real users or DataStore access.
return function(): number
    local Lifecycle = require(game.ServerScriptService.Server.SessionLifecycle)
    local n = 0
    local function check(value, label)
        assert(value, label)
        n += 1
    end
    local data = {
        sessions = {},
        failRenew = false,
        failClose = false,
        pending = false,
        calls = { renew = 0, close = 0, acquire = 0, transact = 0 },
    }
    function data:Acquire(userId, jobId, now)
        self.calls.acquire += 1
        if self.sessions[userId] then
            return nil, "Locked"
        end
        local value = {session = {ownerJobId = jobId, token = "token", generation = 1,
            leaseExpiry = now + 120}, revision = 0}
        self.sessions[userId] = value
        return value, nil
    end
    function data:GetServerSnapshot(userId)
        return self.sessions[userId]
    end
    function data:Renew(userId, now)
        self.calls.renew += 1
        if self.failRenew then
            self.failRenew = false
            return false, "StorageUnavailable"
        end
        self.sessions[userId].session.leaseExpiry = now + 120
        return true, nil
    end
    function data:Close(userId, _now)
        self.calls.close += 1
        if self.failClose then
            self.failClose = false
            return false, "StorageUnavailable"
        end
        self.sessions[userId] = nil
        return true, nil
    end
    function data:Transact(userId, operationId, _rev, _now, _mutation)
        self.calls.transact += 1
        if self.pending then
            self.pending = false
            return nil, "SavePending"
        end
        return {operationId = operationId, revision = 1}, nil
    end
    local life = Lifecycle.new(data)
    check(life:Status(11) == "Absent", "initial absent")
    local profile, code = life:Join(11, "test-job", 100)
    check(profile ~= nil and code == nil and life:IsReady(11, 100), "join -> ready")
    local again, already = life:Join(11, "test-job", 101)
    check(again == nil and already == "AlreadyManaged", "duplicate join prevented")
    life:Heartbeat(129)
    check(data.calls.renew == 0, "no premature renewal")
    life:Heartbeat(130)
    check(data.calls.renew == 1 and life:IsReady(11, 131), "30s renewal")
    data.failRenew = true
    life:Heartbeat(160)
    check(life:Status(11) == "Degraded", "failed renewal degrades")
    local blocked, why = life:Transact(11, "safe_op_12345", 0, 161, function() return true end)
    check(blocked == nil and why == "NotReady" and data.calls.transact == 0,
        "degraded blocks writes")
    life:Heartbeat(164)
    check(data.calls.renew == 2, "retry not premature")
    life:Heartbeat(165)
    check(data.calls.renew == 3 and life:Status(11) == "Ready", "retry restores session")
    data.pending = true
    local receipt, issue = life:Transact(11, "safe_op_12345", 0, 166, function() return true end)
    check(receipt == nil and issue == "SavePending" and life:Status(11) == "Pending",
        "ambiguous write gates new operations")
    blocked, why = life:Transact(11, "other_op_12345", 0, 167, function() return true end)
    check(blocked == nil and why == "NotReady" and data.calls.transact == 1,
        "pending blocks new command")
    receipt, issue = life:ResolvePending(11, "safe_op_12345", 0, 167, function() return true end)
    check(receipt and issue == nil and life:Status(11) == "Ready", "retry pending receipt")
    data.failClose = true
    local released, closeCode = life:Leave(11, 168)
    check(not released and closeCode == "StorageUnavailable" and life:Status(11) == "Closing",
        "failed close not discarded")
    life:Heartbeat(172)
    check(life:Status(11) == "Closing", "close retry waits five seconds")
    local recovered = life:Heartbeat(173)
    check(recovered == 1 and life:Status(11) == "Absent", "close retry releases")

    local twice, e = life:Join(22, "another-job", 250)
    check(twice and e == nil, "second player ready")
    check(life:IsReady(22, 360), "lease still valid with margin")
    check(not life:IsReady(22, 365), "expiry margin denies writes")
    life:Heartbeat(365)
    check(life:Status(22) == "Expired", "expired profile marked")
    local done, closeIssue = life:Shutdown(366)
    check(done and closeIssue == nil and life:Status(22) == "Absent",
        "shutdown releases managed profiles")
    check(not life.schedulerRunning, "scheduler stopped")
    check(life:Heartbeat(-1) == 0, "bad time rejected")
    return n
end
