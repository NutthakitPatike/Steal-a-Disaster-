--!strict
-- P1-02: validation of an authored world; never creates/replaces the player's map.
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Definitions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Definitions"))

local Registry = {}
local current = nil

local function collect(root: Instance, tag: string, idAttribute: string, allowed: (any) -> boolean)
    local found = {}
    local problems = {}
    for _, instance in ipairs(CollectionService:GetTagged(tag)) do
        if instance:IsDescendantOf(root) then
            local id = instance:GetAttribute(idAttribute)
            if not instance:IsA("BasePart") or not allowed(id) then
                table.insert(problems, ("Invalid %s anchor: %s"):format(tag, instance:GetFullName()))
            elseif found[id] then
                table.insert(problems, ("Duplicate %s id %s"):format(tag, tostring(id)))
            else
                found[id] = instance
            end
        end
    end
    return found, problems
end

function Registry.Validate(root: Instance?)
    local errors = {}
    local warnings = {}
    local anchors = { bases = {}, entries = {}, exits = {}, crateNodes = {} }
    if not root or not root:IsA("Folder") and not root:IsA("Model") then
        return { ok = false, errors = { "Missing Workspace.DisasterWorld root" }, warnings = warnings, anchors = anchors }
    end
    if root:GetAttribute("WorldContractVersion") ~= Definitions.WorldContractVersion then
        table.insert(errors, "Missing or unsupported WorldContractVersion")
    end
    local function zoneId(value)
        return Definitions.IsZoneId(value)
    end
    local function baseId(value)
        return type(value) == "number" and value % 1 == 0 and value >= 1 and value <= Definitions.BaseCount
    end
    local bases, a = collect(root, Definitions.WorldTags.Base, "BaseId", baseId)
    local entries, b = collect(root, Definitions.WorldTags.ZoneEntry, "ZoneId", zoneId)
    local exits, c = collect(root, Definitions.WorldTags.ZoneExit, "ZoneId", zoneId)
    local nodes, d = collect(root, Definitions.WorldTags.CrateNode, "NodeId", function(value)
        return type(value) == "string" and #value > 0 and #value <= Definitions.MaxIdBytes
    end)
    anchors.bases, anchors.entries, anchors.exits, anchors.crateNodes = bases, entries, exits, nodes
    for _, issues in ipairs({ a, b, c, d }) do
        for _, problem in ipairs(issues) do
            table.insert(errors, problem)
        end
    end
    for slot = 1, Definitions.BaseCount do
        if not bases[slot] then
            table.insert(errors, ("Missing base %d"):format(slot))
        end
    end
    -- Only Zone 1 is mandatory at the first P1 vertical slice. Later Zones
    -- remain disabled until their physical anchors and progression gate exist.
    local firstZone = Definitions.ZoneIds[1]
    if not entries[firstZone] or not exits[firstZone] then
        table.insert(errors, "Missing entry/exit for Zone 1")
    end
    for _, zone in ipairs(Definitions.ZoneIds) do
        if not entries[zone] or not exits[zone] then
            if zone ~= firstZone then
                table.insert(warnings, ("Zone disabled (missing anchors): %s"):format(zone))
            end
        end
    end
    if next(nodes) == nil then
        table.insert(errors, "Missing crate spawn nodes")
    end
    return { ok = #errors == 0, errors = errors, warnings = warnings, anchors = anchors }
end

function Registry.Refresh()
    local result = Registry.Validate(workspace:FindFirstChild("DisasterWorld"))
    current = result
    return result
end

function Registry.Ready(): boolean
    return current ~= nil and current.ok == true
end

function Registry.Resolve(kind: string, id: any): BasePart?
    if not current or not current.ok then
        return nil
    end
    local maps = {
        Base = current.anchors.bases,
        ZoneEntry = current.anchors.entries,
        ZoneExit = current.anchors.exits,
        CrateNode = current.anchors.crateNodes,
    }
    local selected = maps[kind]
    return selected and selected[id] or nil
end

return table.freeze(Registry)
