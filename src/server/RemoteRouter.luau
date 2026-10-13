--!strict
-- P1-02: bounded, server-authoritative public request boundary.
-- No gameplay mutation endpoints are enabled until the relevant owner implements them.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Definitions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Definitions"))
local WorldRegistry = require(script.Parent:WaitForChild("WorldRegistry"))

local Router = {}
local started = false
local connections = {}
local buckets = {}
local requestEvent
local responseEvent

local function finiteInteger(value: any, min: number, max: number): boolean
    return type(value) == "number" and value == value and value >= min and value <= max and value % 1 == 0
end

local function simpleValue(value: any, depth: number, seen: { [table]: boolean }, count: { number }): boolean
    count[1] += 1
    if count[1] > Definitions.MaxRequestNodes then
        return false
    end
    local kind = typeof(value)
    if kind == "string" then
        return #value <= Definitions.MaxRequestBytes and utf8.len(value) ~= nil
    elseif kind == "number" then
        return value == value and value ~= math.huge and value ~= -math.huge
    elseif kind == "boolean" then
        return true
    elseif kind ~= "table" or depth >= Definitions.MaxRequestDepth or seen[value] then
        return false
    end
    seen[value] = true
    for key, child in pairs(value) do
        if type(key) ~= "string" or #key > Definitions.MaxIdBytes or utf8.len(key) == nil then
            return false
        end
        if not simpleValue(child, depth + 1, seen, count) then
            return false
        end
    end
    seen[value] = nil
    return true
end

function Router.ParseEnvelope(value: any)
    if typeof(value) ~= "table" then
        return nil, Definitions.Codes.InvalidRequest
    end
    for key in pairs(value) do
        if key ~= "protocol" and key ~= "requestId" and key ~= "expectedRevision"
            and key ~= "action" and key ~= "payload" then
            return nil, Definitions.Codes.InvalidRequest
        end
    end
    if value.protocol ~= Definitions.ProtocolVersion then
        return nil, Definitions.Codes.UnsupportedProtocol
    end
    if type(value.requestId) ~= "string" or #value.requestId < 8
        or #value.requestId > Definitions.MaxIdBytes
        or not value.requestId:match("^[%w_%-]+$") then
        return nil, Definitions.Codes.InvalidRequest
    end
    if not finiteInteger(value.expectedRevision, 0, 2147483647) then
        return nil, Definitions.Codes.InvalidRequest
    end
    if value.action ~= Definitions.Actions.Snapshot then
        return nil, Definitions.Codes.UnknownAction
    end
    if typeof(value.payload) ~= "table" or next(value.payload) ~= nil then
        return nil, Definitions.Codes.InvalidRequest
    end
    if not simpleValue(value, 0, {}, { 0 }) then
        return nil, Definitions.Codes.InvalidRequest
    end
    local ok, json = pcall(HttpService.JSONEncode, HttpService, value)
    if not ok or #json > Definitions.MaxRequestBytes then
        return nil, Definitions.Codes.InvalidRequest
    end
    return { requestId = value.requestId, action = value.action, expectedRevision = value.expectedRevision }, nil
end

local function allow(userId: number, action: string)
    local now = os.clock()
    local user = buckets[userId]
    if not user then
        user = {}
        buckets[userId] = user
    end
    local key = user[action]
    if not key then
        key = { tokens = 2, at = now }
        user[action] = key
    end
    key.tokens = math.min(2, key.tokens + math.max(0, now - key.at))
    key.at = now
    if key.tokens < 1 then
        return false
    end
    key.tokens -= 1
    return true
end

local function ensure(parent: Instance, name: string, className: string)
    local old = parent:FindFirstChild(name)
    if old then
        assert(old.ClassName == className, ("Unexpected %s instance for %s"):format(old.ClassName, name))
        return old
    end
    local instance = Instance.new(className)
    instance.Name = name
    instance.Parent = parent
    return instance
end

function Router.Start()
    if started then
        return
    end
    local folder = ensure(ReplicatedStorage, "DisasterProtocolV1", "Folder")
    requestEvent = ensure(folder, "Request", "RemoteEvent")
    responseEvent = ensure(folder, "Response", "RemoteEvent")
    local world = WorldRegistry.Refresh()
    if not world.ok then
        warn("[DisasterProtocol] World not ready: " .. table.concat(world.errors, "; "))
    end
    table.insert(connections, requestEvent.OnServerEvent:Connect(function(player, payload)
        if player.Parent ~= Players then
            return
        end
        if not allow(player.UserId, "Snapshot") then
            -- Do not amplify a malicious flood into an outbound response flood.
            return
        end
        local request, code = Router.ParseEnvelope(payload)
        if not request then
            responseEvent:FireClient(player, { status = "error", code = code })
            return
        end
        -- P1-03 will replace NotReady with a session-safe snapshot. Never
        -- present in-memory prototype attributes as durable account state.
        responseEvent:FireClient(player, {
            requestId = request.requestId,
            status = "error",
            code = Definitions.Codes.NotReady,
            revision = 0,
        })
    end))
    table.insert(connections, Players.PlayerRemoving:Connect(function(player)
        buckets[player.UserId] = nil
    end))
    started = true
end

function Router.Stop()
    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end
    table.clear(connections)
    table.clear(buckets)
    started = false
end

return Router
