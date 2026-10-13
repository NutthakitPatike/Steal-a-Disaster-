--!strict
-- P1-02 contract tests. Run as an isolated ModuleScript in Studio Edit mode.
-- These tests create/destroy only a temporary ServerStorage folder.
return function(): number
    local CollectionService = game:GetService("CollectionService")
    local Definitions = require(game.ReplicatedStorage.Shared.Definitions)
    local Registry = require(game.ServerScriptService.Server.WorldRegistry)
    local Router = require(game.ServerScriptService.Server.RemoteRouter)
    local passed = 0
    local function check(condition, message)
        assert(condition, message)
        passed += 1
    end
    check(Definitions.ProtocolVersion == 1, "protocol version")
    check(#Definitions.ZoneIds == 5, "five zones")
    check(Definitions.IsZoneId("tornado_town"), "zone identifier")
    check(not Definitions.IsZoneId("unknown"), "unknown zone rejected")
    local valid = {
        protocol = 1,
        requestId = "contract_000001",
        expectedRevision = 0,
        action = "Snapshot",
        payload = {},
    }
    local parsed, noError = Router.ParseEnvelope(valid)
    check(parsed ~= nil and noError == nil, "valid snapshot")
    local function rejects(raw, expected)
        local request, errorCode = Router.ParseEnvelope(raw)
        check(request == nil and errorCode == expected, "bad validation " .. tostring(errorCode))
    end
    rejects({ protocol = 2, requestId = valid.requestId, expectedRevision = 0, action = "Snapshot", payload = {} }, Definitions.Codes.UnsupportedProtocol)
    rejects({ protocol = 1, requestId = valid.requestId, expectedRevision = 0, action = "GrantCoins", payload = {} }, Definitions.Codes.UnknownAction)
    rejects({ protocol = 1, requestId = valid.requestId, expectedRevision = 0, action = "Snapshot", payload = {coins = 1000} }, Definitions.Codes.InvalidRequest)
    rejects({ protocol = 1, requestId = valid.requestId, expectedRevision = 0, action = "Snapshot", payload = {}, bonus = 42 }, Definitions.Codes.InvalidRequest)
    rejects({ protocol = 1, requestId = valid.requestId, expectedRevision = 0 / 0, action = "Snapshot", payload = {} }, Definitions.Codes.InvalidRequest)
    rejects({ protocol = 1, requestId = valid.requestId, expectedRevision = math.huge, action = "Snapshot", payload = {} }, Definitions.Codes.InvalidRequest)
    rejects({ protocol = 1, requestId = "bad !", expectedRevision = 0, action = "Snapshot", payload = {} }, Definitions.Codes.InvalidRequest)

    local status = Registry.Refresh()
    check(not status.ok and #status.errors > 0, "missing authored world fails closed")
    check(Registry.Resolve("Base", 1) == nil, "missing base is not invented")

    local root = Instance.new("Folder")
    root.Name = "P102ContractTestWorld"
    root:SetAttribute("WorldContractVersion", Definitions.WorldContractVersion)
    root.Parent = game:GetService("ServerStorage")
    local function anchor(name, tag, attr, value)
        local part = Instance.new("Part")
        part.Name = name
        part.Anchored = true
        part:SetAttribute(attr, value)
        part.Parent = root
        CollectionService:AddTag(part, tag)
        return part
    end
    local good, problem = pcall(function()
        for i = 1, Definitions.BaseCount do
            anchor("Base" .. i, Definitions.WorldTags.Base, "BaseId", i)
        end
        local entry = anchor("Entry", Definitions.WorldTags.ZoneEntry, "ZoneId", Definitions.ZoneIds[1])
        anchor("Exit", Definitions.WorldTags.ZoneExit, "ZoneId", Definitions.ZoneIds[1])
        anchor("Node", Definitions.WorldTags.CrateNode, "NodeId", "test_node_1")
        local report = Registry.Validate(root)
        check(report.ok and #report.warnings == 4, "valid Zone1 test world")
        local duplicate = anchor("Duplicate", Definitions.WorldTags.Base, "BaseId", 1)
        report = Registry.Validate(root)
        check(not report.ok and table.concat(report.errors, ";"):find("Duplicate") ~= nil, "duplicate base rejected")
        duplicate:Destroy()
        entry:Destroy()
        report = Registry.Validate(root)
        check(not report.ok, "missing Zone1 entry rejected")
        root:SetAttribute("WorldContractVersion", 99)
        report = Registry.Validate(root)
        check(not report.ok, "wrong world version rejected")
    end)
    root:Destroy()
    if not good then
        error(problem)
    end
    return passed
end
