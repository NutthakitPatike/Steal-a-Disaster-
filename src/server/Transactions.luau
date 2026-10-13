--!strict
-- P1-03: pure profile transform used INSIDE UpdateAsync callbacks.
-- Mutate must be deterministic/non-yielding; never use RNG, events or external services here.
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")
local Schema = require(ServerScriptService:WaitForChild("Server"):WaitForChild("ProfileSchema"))

local Transactions = {}

function Transactions.Apply(existing: any, operationId: string, expectedRevision: number, mutate: (any) -> (boolean, any))
    if type(operationId) ~= "string" or #operationId < 8 or #operationId > 64
        or not operationId:match("^[%w_%-]+$") then
        return nil, "InvalidOperation"
    end
    local valid, reason = Schema.Validate(existing)
    if not valid then
        return nil, reason
    end
    local previous = existing.receipts[operationId]
    if previous then
        return existing, nil, previous
    end
    if existing.revision ~= expectedRevision then
        return nil, "StaleRevision"
    end
    if type(mutate) ~= "function" then
        return nil, "InvalidOperation"
    end
    local changed = Schema.Clone(existing)
    local safe, accepted, result = pcall(mutate, changed)
    if not safe then
        return nil, "MutationFailed"
    end
    if accepted ~= true then
        return nil, type(result) == "string" and result or "Rejected"
    end
    changed.revision += 1
    local receipt = {
        operationId = operationId,
        revision = changed.revision,
        result = result == nil and {} or result,
    }
    changed.receipts[operationId] = receipt
    table.insert(changed.receiptOrder, operationId)
    while #changed.receiptOrder > Schema.MaxReceipts do
        local oldest = table.remove(changed.receiptOrder, 1)
        changed.receipts[oldest] = nil
    end
    local ok, errorCode = Schema.Validate(changed)
    if not ok then
        return nil, errorCode
    end
    local encoded, json = pcall(HttpService.JSONEncode, HttpService, changed)
    if not encoded or #json > Schema.MaxSerializedBytes then
        return nil, "ProfileTooLarge"
    end
    return changed, nil, receipt
end

return table.freeze(Transactions)
