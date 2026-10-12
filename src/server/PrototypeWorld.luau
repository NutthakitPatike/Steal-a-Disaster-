--!strict
-- Studio-only original procedural map: hub plus five themed sequential zones.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PrototypeConfig"))
local ZoneMap = require(script.Parent:WaitForChild("ZoneMap"))
local World = {}

local function part(
    parent: Instance,
    name: string,
    position: Vector3,
    size: Vector3,
    color: Color3,
    collides: boolean?
): Part
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.Position = position
    p.Color = color
    p.Material = Enum.Material.SmoothPlastic
    p.CanCollide = collides ~= false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function label(parent: Instance, name: string, text: string, offset: Vector3?): BillboardGui
    local gui = Instance.new("BillboardGui")
    gui.Name = name
    gui.AlwaysOnTop = true
    gui.Size = UDim2.fromOffset(260, 63)
    gui.StudsOffsetWorldSpace = offset or Vector3.new(0, 5, 0)
    gui.MaxDistance = 180
    local t = Instance.new("TextLabel")
    t.Size = UDim2.fromScale(1, 1)
    t.BackgroundColor3 = Color3.fromRGB(20, 27, 38)
    t.BackgroundTransparency = 0.17
    t.TextColor3 = Color3.fromRGB(250, 251, 255)
    t.TextStrokeTransparency = 0.65
    t.TextScaled = true
    t.Font = Enum.Font.GothamBold
    t.Text = text
    t.Parent = gui
    gui.Parent = parent
    return gui
end

local function prompt(owner: BasePart, action: string, hold: number): ProximityPrompt
    local p = Instance.new("ProximityPrompt")
    p.Name = action .. "Prompt"
    p.ActionText = action
    p.ObjectText = "Containment Crate"
    p.KeyboardKeyCode = Enum.KeyCode.E
    p.HoldDuration = hold
    p.MaxActivationDistance = 12
    p.RequiresLineOfSight = false
    p.Parent = owner
    return p
end

function World.create(name: string)
    assert(workspace:FindFirstChild(name) == nil, "Prototype workspace already exists")
    local root = Instance.new("Folder")
    root.Name = name
    root.Parent = workspace

    part(
        root,
        "HubFloor",
        Vector3.new(0, -1, 9),
        Vector3.new(188, 2, 140),
        Color3.fromRGB(90, 110, 127)
    )
    part(
        root,
        "MainApproach",
        Vector3.new(0, -1, -96),
        Vector3.new(44, 2, 112),
        Color3.fromRGB(155, 160, 155)
    )
    part(
        root,
        "ReturnApproach",
        Vector3.new(46, -1, -96),
        Vector3.new(12, 2, 112),
        Color3.fromRGB(169, 213, 220)
    )
    local zones = ZoneMap.create(root, part, label, Config)

    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "PrototypeSpawn"
    spawn.Size = Vector3.new(12, 1, 12)
    spawn.Anchored = true
    spawn.Position = Vector3.new(0, 0.4, 54)
    spawn.Neutral = true
    spawn.Transparency = 0.25
    spawn.Color = Color3.fromRGB(125, 208, 208)
    spawn.Parent = root
    label(spawn, "SpawnSign", "STEAL A DISASTER! TEST HUB", Vector3.new(0, 5, 0))

    local guide = part(
        root,
        "MapGuide",
        Vector3.new(30, 4, -44),
        Vector3.new(3, 8, 3),
        Color3.fromRGB(80, 174, 190),
        false
    )
    label(guide, "MapLabel", "5 ZONES STRAIGHT AHEAD\nRETURN LANE ON RIGHT", Vector3.new(0, 8, 0))

    -- Six temporary test bases do NOT decide the owner's seven unlabeled bays.
    local plots = {}
    for slot = 1, 6 do
        local x = (slot - 3.5) * 29
        local pad = part(
            root,
            "TestPlot" .. slot,
            Vector3.new(x, 0, 0),
            Vector3.new(24, 1, 27),
            Color3.fromRGB(108, 124, 167),
            false
        )
        label(pad, "PlotSign", "FREE TEST BASE " .. slot, Vector3.new(0, 5, -7))
        local station = part(
            root,
            "CrateOpener" .. slot,
            Vector3.new(x, 3, 6),
            Vector3.new(7, 5, 7),
            Color3.fromRGB(221, 181, 92),
            false
        )
        label(station, "OpenSign", "OPEN SECURED CRATE", Vector3.new(0, 6, 0))
        local open = prompt(station, "Open Crate", 0.35)
        open.ObjectText = "Your Base"
        table.insert(plots, { pad = pad, station = station, open = open })
    end

    local trainer = part(
        root,
        "SpeedTrainer",
        Vector3.new(0, 2, 28),
        Vector3.new(11, 4, 10),
        Color3.fromRGB(82, 160, 233),
        false
    )
    label(trainer, "TrainSign", "TRAIN SPEED POWER", Vector3.new(0, 6, 0))
    local trainPrompt = prompt(trainer, "Train +10 Speed", 0.5)
    trainPrompt.ObjectText = "Practice Treadmill"

    return {
        root = root,
        zones = zones,
        plots = plots,
        trainPrompt = trainPrompt,
        part = part,
        label = label,
        prompt = prompt,
    }
end

return World
