--!strict
-- All geometry is generated from primitive Roblox Parts: no third-party assets.
-- These are five original, lightweight test environments along ONE physical road.
local ZoneMap = {}

local THEMES = {
    {
        floor = Color3.fromRGB(99, 166, 121),
        path = Color3.fromRGB(176, 185, 166),
        accent = Color3.fromRGB(100, 204, 207),
        sky = Color3.fromRGB(199, 232, 239),
    },
    {
        floor = Color3.fromRGB(207, 192, 154),
        path = Color3.fromRGB(155, 197, 203),
        accent = Color3.fromRGB(57, 166, 217),
        sky = Color3.fromRGB(108, 188, 227),
    },
    {
        floor = Color3.fromRGB(102, 90, 94),
        path = Color3.fromRGB(154, 128, 125),
        accent = Color3.fromRGB(244, 124, 70),
        sky = Color3.fromRGB(239, 162, 97),
    },
    {
        floor = Color3.fromRGB(90, 99, 143),
        path = Color3.fromRGB(156, 164, 193),
        accent = Color3.fromRGB(182, 143, 244),
        sky = Color3.fromRGB(154, 184, 235),
    },
    {
        floor = Color3.fromRGB(108, 94, 65),
        path = Color3.fromRGB(151, 145, 112),
        accent = Color3.fromRGB(249, 139, 70),
        sky = Color3.fromRGB(223, 180, 115),
    },
}

local function style(obj: Part, material: Enum.Material, transparency: number?)
    obj.Material = material
    obj.Transparency = transparency or 0
    return obj
end

function ZoneMap.create(root: Folder, part, label, config)
    local zones = {}
    for i, definition in ipairs(config.Zones) do
        local centerZ = config.FirstZoneCenterZ - (i - 1) * config.ZoneSpacing
        local theme = THEMES[i]
        local zoneFolder = Instance.new("Folder")
        zoneFolder.Name = ("Zone%02d_%s"):format(i, definition.Name:gsub("%s+", ""))
        zoneFolder.Parent = root

        local function block(name, x, y, z, sx, sy, sz, color, collide)
            return part(
                zoneFolder,
                name,
                Vector3.new(x, y, centerZ + z),
                Vector3.new(sx, sy, sz),
                color,
                collide
            )
        end

        block("Ground", 0, -1, 0, 120, 2, config.ZoneLength, theme.floor)
        block("MainRoad", 0, 0.05, 0, 25, 0.1, config.ZoneLength, theme.path, false)
        -- Safe shoulder remains passable on the return trip, without teleporting.
        block("ReturnShoulder", 46, 0.05, 0, 12, 0.1, config.ZoneLength, theme.sky, false)
        block("WestRim", -61, 3, 0, 2, 6, config.ZoneLength, theme.accent)
        block("EastRim", 61, 3, 0, 2, 6, config.ZoneLength, theme.accent)

        local startZ = centerZ + config.ZoneLength / 2 + 1
        local gate = part(
            zoneFolder,
            "SafeExit_" .. i,
            Vector3.new(0, 0.2, startZ),
            Vector3.new(48, 0.35, 4),
            Color3.fromRGB(112, 233, 163),
            false
        )
        style(gate, Enum.Material.Neon)
        label(gate, "ExitLabel", ("ZONE %d SAFE EXIT"):format(i), Vector3.new(0, 6, 0))

        local intro = block("ZoneEntrySign", -24, 5, 83, 3, 10, 3, theme.accent, false)
        label(
            intro,
            "Name",
            ("ZONE %d - %s\nSpeed %d+"):format(i, definition.Name, definition.RequiredSpeed),
            Vector3.new(0, 10, 0)
        )

        -- The physical exit to the next Zone is always straight ahead.
        if i > 1 then
            local centerBetween = centerZ + config.ZoneSpacing / 2
            part(
                root,
                ("Link_%d_%d"):format(i - 1, i),
                Vector3.new(0, -1, centerBetween),
                Vector3.new(34, 2, config.ZoneSpacing - config.ZoneLength + 4),
                Color3.fromRGB(122, 138, 151)
            )
            part(
                root,
                ("ReturnLink_%d_%d"):format(i - 1, i),
                Vector3.new(46, -0.9, centerBetween),
                Vector3.new(12, 2, config.ZoneSpacing - config.ZoneLength + 4),
                theme.sky
            )
        end

        -- A few original shapes per theme; no imported copies of the reference.
        if i == 1 then
            for j = 1, 4 do
                local z = 60 - j * 35
                local house = block(
                    "LittleHouse" .. j,
                    if j % 2 == 0 then 34 else -36,
                    7,
                    z,
                    17,
                    14,
                    16,
                    Color3.fromRGB(235, 194 + j * 5, 162),
                    false
                )
                local roof = block(
                    "HouseRoof" .. j,
                    house.Position.X,
                    15.5,
                    z,
                    20,
                    3,
                    19,
                    Color3.fromRGB(137, 111, 139),
                    false
                )
                roof.Material = Enum.Material.Slate
            end
            local spiral = block(
                "TornadoSculpture",
                -46,
                14,
                -75,
                8,
                28,
                8,
                Color3.fromRGB(170, 229, 221),
                false
            )
            spiral.Shape = Enum.PartType.Cylinder
            style(spiral, Enum.Material.ForceField, 0.3)
        elseif i == 2 then
            for j = 1, 4 do
                local water = block(
                    "WaterStrip" .. j,
                    if j % 2 == 0 then 35 else -35,
                    0.15,
                    66 - j * 42,
                    29,
                    0.25,
                    29,
                    theme.accent,
                    false
                )
                style(water, Enum.Material.Glass, 0.45)
            end
            block("WaveWallSculpture", -43, 9, -74, 10, 18, 37, Color3.fromRGB(76, 179, 225), false)
            block("Lighthouse", 46, 22, 58, 12, 44, 12, Color3.fromRGB(234, 232, 225), false)
            block("LighthouseBeacon", 46, 46, 58, 16, 4, 16, theme.accent, false)
        elseif i == 3 then
            for j = 1, 5 do
                local x = if j % 2 == 0 then 36 else -39
                block(
                    "Basalt" .. j,
                    x,
                    5,
                    80 - j * 33,
                    14,
                    10,
                    11,
                    Color3.fromRGB(65, 62, 68),
                    false
                )
            end
            local lava =
                block("LavaRiverSculpture", -48, 0.15, -36, 17, 0.25, 112, theme.accent, false)
            style(lava, Enum.Material.Neon)
            block("VolcanoCone", 44, 20, -61, 28, 40, 28, Color3.fromRGB(73, 69, 71), false)
            style(
                block("VolcanoGlow", 44, 41, -61, 19, 3, 19, theme.accent, false),
                Enum.Material.Neon
            )
        elseif i == 4 then
            for j = 1, 4 do
                local x = if j % 2 == 0 then 38 else -39
                block(
                    "StormBuilding" .. j,
                    x,
                    12 + j * 3,
                    69 - j * 34,
                    18,
                    24 + j * 6,
                    18,
                    Color3.fromRGB(61, 69, 102),
                    false
                )
                style(
                    block(
                        "ElectricSign" .. j,
                        x,
                        25 + j * 3,
                        69 - j * 34,
                        15,
                        2,
                        3,
                        theme.accent,
                        false
                    ),
                    Enum.Material.Neon
                )
            end
        elseif i == 5 then
            for j = 1, 9 do
                local x = if j % 2 == 0 then 38 else -39
                local z = 92 - j * 20
                block("TreeTrunk" .. j, x, 10, z, 5, 20, 5, Color3.fromRGB(99, 71, 55), false)
                local crown = block(
                    "BurningCanopy" .. j,
                    x,
                    23,
                    z,
                    17,
                    17,
                    17,
                    if j % 3 == 0
                        then Color3.fromRGB(239, 130, 75)
                        else Color3.fromRGB(112, 117, 68),
                    false
                )
                crown.Shape = Enum.PartType.Ball
                if j % 3 == 0 then
                    style(crown, Enum.Material.Neon, 0.15)
                end
            end
        end

        local warden =
            block("Warden_" .. i, 0, 4, -20, 8, 8, 8, Color3.fromRGB(198, 75 + i * 9, 91), false)
        warden.Shape = Enum.PartType.Ball
        label(warden, "WardenSign", ("WARDEN - ZONE %d"):format(i), Vector3.new(0, 7, 0))

        local nodes = {
            Vector3.new(-30, 3.2, centerZ - 57),
            Vector3.new(29, 3.2, centerZ - 73),
        }
        for j, location in ipairs(nodes) do
            local pad = part(
                zoneFolder,
                "CrateSpawn" .. j,
                location - Vector3.new(0, 2.9, 0),
                Vector3.new(13, 0.3, 13),
                theme.accent,
                false
            )
            style(pad, Enum.Material.Neon, 0.2)
        end
        zones[i] = {
            id = i,
            name = definition.Name,
            folder = zoneFolder,
            nodes = nodes,
            centerZ = centerZ,
            safeExitZ = startZ + 1,
            warden = warden,
            guardOrigin = warden.Position,
        }
    end
    return zones
end

return ZoneMap
