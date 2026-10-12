--!strict
-- Disposable Studio-friendly greybox created at runtime; no permanent Workspace edit.
local World = {}
local function part(parent: Instance, name: string, position: Vector3, size: Vector3, color: Color3, collides: boolean?): Part
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
    gui.Size = UDim2.fromOffset(230, 55)
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
local function prompt(partOwner: BasePart, action: string, hold: number): ProximityPrompt
    local p = Instance.new("ProximityPrompt")
    p.Name = action .. "Prompt"
    p.ActionText = action
    p.ObjectText = "Containment Crate"
    p.KeyboardKeyCode = Enum.KeyCode.E
    p.HoldDuration = hold
    p.MaxActivationDistance = 12
    p.RequiresLineOfSight = false
    p.Parent = partOwner
    return p
end
function World.create(name: string)
    assert(workspace:FindFirstChild(name) == nil, "Prototype workspace already exists")
    local root = Instance.new("Folder")
    root.Name = name
    root.Parent = workspace

    part(root, "HubFloor", Vector3.new(0, -1, 9), Vector3.new(188, 2, 140), Color3.fromRGB(88, 109, 132))
    part(root, "ApproachLane", Vector3.new(0, -1, -96), Vector3.new(44, 2, 112), Color3.fromRGB(125, 129, 132))
    part(root, "Zone1Floor", Vector3.new(0, -1, -247), Vector3.new(118, 2, 190), Color3.fromRGB(91, 151, 116))
    part(root, "Zone1BackStop", Vector3.new(0, 13, -344), Vector3.new(118, 26, 3), Color3.fromRGB(71, 118, 93))
    part(root, "Zone1LeftWall", Vector3.new(-61, 9, -246), Vector3.new(3, 18, 193), Color3.fromRGB(64, 113, 78))
    part(root, "Zone1RightWall", Vector3.new(61, 9, -246), Vector3.new(3, 18, 193), Color3.fromRGB(64, 113, 78))

    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "PrototypeSpawn"
    spawn.Size = Vector3.new(12, 1, 12)
    spawn.Anchored = true
    spawn.Position = Vector3.new(0, 0.4, 54)
    spawn.Neutral = true
    spawn.Transparency = 0.25
    spawn.Color = Color3.fromRGB(125, 208, 208)
    spawn.Parent = root
    label(spawn, "SpawnSign", "TORNADO TOWN TEST HUB", Vector3.new(0, 5, 0))

    local gate = part(root, "SafeExit", Vector3.new(0, 0.3, -139), Vector3.new(50, 0.65, 6), Color3.fromRGB(102, 242, 170), false)
    gate.Material = Enum.Material.Neon
    label(gate, "SafeSign", "SAFE EXIT - RETURN TO YOUR BASE", Vector3.new(0, 7, 0))
    local info = part(root, "ZoneSign", Vector3.new(0, 5, -165), Vector3.new(2, 10, 2), Color3.fromRGB(44, 107, 123), false)
    label(info, "ZoneTitle", "ZONE 1: TORNADO TOWN", Vector3.new(0, 9, 0))

    part(root, "CoverLeft", Vector3.new(-35, 5, -230), Vector3.new(16, 10, 12), Color3.fromRGB(148, 165, 185))
    part(root, "CoverRight", Vector3.new(37, 5, -256), Vector3.new(15, 10, 14), Color3.fromRGB(148, 165, 185))

    local warden = part(root, "Warden", Vector3.new(0, 4, -286), Vector3.new(8, 8, 8), Color3.fromRGB(201, 83, 95), false)
    warden.Shape = Enum.PartType.Ball
    label(warden, "WardenSign", "WARDEN - AVOID!", Vector3.new(0, 7, 0))

    local nodes = { Vector3.new(-33, 3.2, -310), Vector3.new(33, 3.2, -310) }
    for i, position in ipairs(nodes) do
        local mark = part(root, "CrateSpawn" .. i, position - Vector3.new(0, 2.9, 0), Vector3.new(12, 0.3, 12), Color3.fromRGB(148, 204, 214), false)
        mark.Material = Enum.Material.Neon
    end

    local plots = {}
    for slot = 1, 6 do
        local x = (slot - 3.5) * 29
        local pad = part(root, "TestPlot" .. slot, Vector3.new(x, 0, 0), Vector3.new(24, 1, 27), Color3.fromRGB(105, 115, 166), false)
        label(pad, "PlotSign", "FREE TEST BASE " .. slot, Vector3.new(0, 5, -7))
        local station = part(root, "CrateOpener" .. slot, Vector3.new(x, 3, 6), Vector3.new(7, 5, 7), Color3.fromRGB(221, 181, 92), false)
        label(station, "OpenSign", "OPEN SECURED CRATE", Vector3.new(0, 6, 0))
        local open = prompt(station, "Open Crate", 0.35)
        open.ObjectText = "Your Base"
        table.insert(plots, { pad = pad, station = station, open = open })
    end

    local trainer = part(root, "SpeedTrainer", Vector3.new(0, 2, 28), Vector3.new(11, 4, 10), Color3.fromRGB(82, 160, 233), false)
    label(trainer, "TrainSign", "TRAIN SPEED POWER", Vector3.new(0, 6, 0))
    local trainPrompt = prompt(trainer, "Train +10 Speed", 0.5)
    trainPrompt.ObjectText = "Practice Treadmill"

    return {
        root = root,
        warden = warden,
        guardOrigin = warden.Position,
        nodes = nodes,
        plots = plots,
        trainPrompt = trainPrompt,
        part = part,
        label = label,
        prompt = prompt,
    }
end
return World
