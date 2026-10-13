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

    local pendingProfile = life:Join(33, "pending-job", 400)
    check(pendingProfile ~= nil, "pending recovery fixture acquired")
    data.pending = true
    receipt, issue = life:Transact(33, "pending_op_12345", 0, 401, function() return true end)
    check(receipt == nil and issue == "SavePending" and life:Status(33) == "Pending",
        "pending state entered")
    local releasedPending, pendingCloseCode = life:Leave(33, 402)
    check(not releasedPending and pendingCloseCode == "PendingOperation"
        and life:Status(33) == "Pending", "leave cannot drop pending receipt")
    local wrongReceipt, wrongIssue = life:ResolvePending(33, "other_op_12345", 0, 403,
        function() return true end)
    check(wrongReceipt == nil and wrongIssue == "WrongPendingOperation",
        "wrong operation cannot recover pending write")
    wrongReceipt, wrongIssue = life:ResolvePending(33, "pending_op_12345", 1, 403,
        function() return true end)
    check(wrongReceipt == nil and wrongIssue == "WrongPendingOperation",
        "wrong revision cannot recover pending write")
    data.failRenew = true
    local previousRenewCalls = data.calls.renew
    life:Heartbeat(430)
    check(data.calls.renew == previousRenewCalls + 1 and life:Status(33) == "Pending",
        "failed renewal preserves pending gate")
    life:Heartbeat(434)
    check(data.calls.renew == previousRenewCalls + 1, "pending renewal respects retry delay")
    life:Heartbeat(435)
    check(data.sessions[33].session.leaseExpiry == 555 and life:Status(33) == "Pending",
        "successful pending renewal extends lease without unblocking writes")
    blocked, why = life:Transact(33, "fresh_op_12345", 0, 520,
        function() return true end)
    check(blocked == nil and why == "NotReady", "pending renewal never admits new operation")
    receipt, issue = life:ResolvePending(33, "pending_op_12345", 0, 520,
        function() return true end)
    check(receipt ~= nil and issue == nil and life:Status(33) == "Ready",
        "pending receipt recovered after original lease expiry")
    local closedPending = life:Leave(33, 521)
    check(closedPending and life:Status(33) == "Absent", "recovered session closes cleanly")
    check(life:Heartbeat(-1) == 0, "bad time rejected")
    return n
end
