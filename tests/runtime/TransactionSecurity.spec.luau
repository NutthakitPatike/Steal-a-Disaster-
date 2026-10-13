--!strict
-- P1-03 security contract: domain mutations cannot change ownership or receipts.
return function(): number
    local Schema = require(game.ServerScriptService.Server.ProfileSchema)
    local Transactions = require(game.ServerScriptService.Server.Transactions)
    local tests = 0
    local function check(value, label)
        assert(value, label)
        tests += 1
    end
    local initial = Schema.New()
    initial.session = { ownerJobId = "owner", token = "safe-token", generation = 1, leaseExpiry = 1200 }
    initial.fencingCounter = 1
    check(Schema.Validate(initial) == true, "fixture valid")
    local function forbidden(label, mutation)
        local before = Schema.Clone(initial)
        local result, code = Transactions.Apply(before, "tamper_" .. label .. "_001", 0, function(state)
            mutation(state)
            return true, { success = true }
        end)
        check(result == nil and code == "ForbiddenMetadataMutation", label .. " not rejected: " .. tostring(code))
        check(before.revision == 0 and before.session.ownerJobId == "owner"
            and next(before.receipts) == nil, label .. " changed original")
    end
    forbidden("session", function(p)
        p.session.ownerJobId = "other"
    end)
    forbidden("token", function(p)
        p.session.token = "stolen-token"
    end)
    forbidden("lease", function(p)
        p.session.leaseExpiry += 10000
    end)
    forbidden("fence", function(p)
        p.fencingCounter += 1
    end)
    forbidden("revision", function(p)
        p.revision = 100
    end)
    forbidden("schema", function(p)
        p.schemaVersion = 99
    end)
    forbidden("content", function(p)
        p.contentVersion += 1
    end)
    forbidden("receipt", function(p)
        p.receipts.fake = { operationId = "fake", revision = 1 }
    end)
    forbidden("ledger", function(p)
        table.insert(p.receiptOrder, "fake")
    end)
    forbidden("clearowner", function(p)
        p.session = nil
    end)
    local updated, problem = Transactions.Apply(initial, "legit_op_12345", 0, function(p)
        p.coins += 7
        return true, { delta = 7 }
    end)
    check(updated ~= nil and problem == nil and updated.coins == 7, "valid gameplay mutation")
    check(updated.session.ownerJobId == "owner" and updated.fencingCounter == 1, "metadata retained")
    check(updated.receipts.legit_op_12345.revision == 1, "receipt issued")
    check(initial.coins == 0 and initial.revision == 0, "original unchanged")
    local retry, err, receipt = Transactions.Apply(updated, "legit_op_12345", 0, function()
        error("must not invoke mutate on replay")
    end)
    check(retry ~= nil and err == nil and receipt.revision == 1 and retry.coins == 7, "replay is no-op")
    return tests
end
