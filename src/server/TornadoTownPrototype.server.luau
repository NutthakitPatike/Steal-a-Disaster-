--!nonstrict
-- Studio-only, no persistent DataStore writes or live publishing.
-- One reusable, server-owned crate/chase/open loop across five original Zone scenes.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PrototypeConfig"))
local World = require(script.Parent:WaitForChild("PrototypeWorld"))

if not Config.Enabled or not RunService:IsStudio() then
    return
end

local remotes = Instance.new("Folder")
remotes.Name = "PrototypeRemotes"
remotes.Parent = ReplicatedStorage
local notifyEvent = Instance.new("RemoteEvent")
notifyEvent.Name = "Notify"
notifyEvent.Parent = remotes

local world = World.create(Config.WorldName)
local rng = Random.new()
local profiles = {}
local occupiedPlots = {}
local activeCrates = {}
local nextCrateId = 0
local spawnCrate

local function notify(player, message)
    if player.Parent == Players then
        notifyEvent:FireClient(player, message)
    end
end

local function characterRoot(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not root then
        return nil, nil
    end
    return root, humanoid
end

local function within(player, position, radius)
    local root = characterRoot(player)
    return root ~= nil and (root.Position - position).Magnitude <= radius
end

local function unlockedZone(speedPower)
    local highest = 1
    for zoneId, definition in ipairs(Config.Zones) do
        if speedPower >= definition.RequiredSpeed then
            highest = zoneId
        end
    end
    return highest
end

local function updateValues(player, profile)
    player:SetAttribute("ChaosCoins", profile.coins)
    player:SetAttribute("SpeedPower", profile.speedPower)
    player:SetAttribute("HighestZone", unlockedZone(profile.speedPower))
    local stats = player:FindFirstChild("leaderstats")
    if stats then
        stats.Coins.Value = profile.coins
        stats.Speed.Value = profile.speedPower
    end
end

local function updateCarry(player, profile)
    local carry = profile.carry
    player:SetAttribute("CarryStatus", carry and carry.status or "Empty")
    player:SetAttribute("CarryingTier", carry and carry.tier or "")
    player:SetAttribute("CarryingZone", carry and carry.zoneId or 0)
end

local function clearCarry(player, profile, message)
    local carry = profile.carry
    if not carry then
        return
    end
    profile.carry = nil
    profile.slowUntil = 0
    if carry.visual then
        carry.visual:Destroy()
    end
    updateCarry(player, profile)
    if message then
        notify(player, message)
    end
end

local function equipVisual(player, tier)
    local root = characterRoot(player)
    if not root then
        return nil
    end
    local visual = Instance.new("Part")
    visual.Name = "CarriedContainmentCrate"
    visual.Size = Vector3.new(3.4, 3.4, 3.4)
    visual.Color = if tier == "Rare"
        then Color3.fromRGB(218, 150, 255)
        else Color3.fromRGB(120, 213, 228)
    visual.Material = Enum.Material.Neon
    visual.CanCollide = false
    visual.CanQuery = false
    visual.CanTouch = false
    visual.Massless = true
    visual.CFrame = root.CFrame * CFrame.new(0, 1, -2.5)
    visual.Parent = player.Character
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = root
    weld.Part1 = visual
    weld.Parent = visual
    return visual
end

local function chooseTier()
    local total = 0
    for _, weight in pairs(Config.CrateTierWeights) do
        total += weight
    end
    local roll = rng:NextNumber(0, total)
    local cumulative = 0
    for _, tier in ipairs({ "Common", "Rare" }) do
        cumulative += Config.CrateTierWeights[tier] or 0
        if roll <= cumulative then
            return tier
        end
    end
    return "Common"
end

local function takeCrate(player, zoneId, instanceId, method)
    local profile = profiles[player]
    local crate = activeCrates[zoneId]
    if not profile or profile.carry or not crate or crate.id ~= instanceId or crate.claimed then
        return
    end
    if not within(player, crate.position, Config.CaptureDistance) then
        return
    end
    if profile.speedPower < Config.Zones[zoneId].RequiredSpeed then
        notify(
            player,
            ("Zone %d needs %d Speed Power. Train first."):format(
                zoneId,
                Config.Zones[zoneId].RequiredSpeed
            )
        )
        return
    end

    -- No yield until after the ownership claim and carry assignment.
    crate.claimed = true
    activeCrates[zoneId] = nil
    crate.model:Destroy()
    local visual = equipVisual(player, crate.tier)
    if not visual then
        task.delay(Config.CrateRespawnSeconds, function()
            spawnCrate(zoneId)
        end)
        return
    end
    profile.carry = {
        id = instanceId,
        tier = crate.tier,
        zoneId = zoneId,
        method = method,
        status = "Escaping",
        capturedAt = os.clock(),
        visual = visual,
        slowApplied = false,
    }
    updateCarry(player, profile)
    notify(
        player,
        ("ZONE %d %s crate! %s: run to the green exit."):format(zoneId, crate.tier, method)
    )
    if method == "Snatch" then
        notify(player, "UNSTABLE: a brief slowdown is coming!")
    end
    task.delay(Config.CrateRespawnSeconds, function()
        spawnCrate(zoneId)
    end)
end

function spawnCrate(zoneId)
    if activeCrates[zoneId] or not world.root.Parent then
        return
    end
    local zone = world.zones[zoneId]
    if not zone then
        return
    end
    nextCrateId += 1
    local id = nextCrateId
    local tier = chooseTier()
    local position = zone.nodes[rng:NextInteger(1, #zone.nodes)]
    local model = Instance.new("Model")
    model.Name = "Zone" .. zoneId .. "_Crate_" .. id
    model.Parent = zone.folder
    local core = world.part(
        model,
        tier .. " Containment Crate",
        position,
        Vector3.new(5, 5, 5),
        if tier == "Rare" then Color3.fromRGB(166, 110, 240) else Color3.fromRGB(100, 190, 218),
        false
    )
    core.Material = Enum.Material.Neon
    world.label(core, "TierSign", tier:upper() .. " CRATE - ZONE " .. zoneId, Vector3.new(0, 6, 0))
    for _, option in ipairs({
        { name = "Stabilize", seconds = 2.0, deltaX = -7, color = Color3.fromRGB(75, 186, 160) },
        { name = "Snatch", seconds = 0.0, deltaX = 7, color = Color3.fromRGB(239, 169, 87) },
    }) do
        local button = world.part(
            model,
            option.name .. "Handle",
            position + Vector3.new(option.deltaX, -1, 0),
            Vector3.new(4, 3, 4),
            option.color,
            false
        )
        local prompt = world.prompt(button, option.name, option.seconds)
        prompt.Triggered:Connect(function(player)
            takeCrate(player, zoneId, id, option.name)
        end)
        world.label(button, option.name .. "Sign", option.name, Vector3.new(0, 4.5, 0))
    end
    activeCrates[zoneId] =
        { id = id, tier = tier, model = model, position = position, claimed = false }
end

local function openAtBase(player, slot)
    local profile = profiles[player]
    if not profile or profile.plotSlot ~= slot or occupiedPlots[slot] ~= player.UserId then
        return
    end
    if not within(player, world.plots[slot].station.Position, Config.BaseOpenDistance) then
        return
    end
    local carry = profile.carry
    if not carry or carry.status ~= "Secured" then
        notify(player, "Escape with a crate, then open it at YOUR base.")
        return
    end

    -- Consume before the grant; one valid open even under rapid prompts.
    profile.carry = nil
    if carry.visual then
        carry.visual:Destroy()
    end
    updateCarry(player, profile)
    local pool = Config.Rewards[carry.zoneId][carry.tier]
    assert(pool and #pool > 0, "Zone crate tier has no reward pool")
    local disaster = pool[rng:NextInteger(1, #pool)]
    profile.inventory[disaster] = (profile.inventory[disaster] or 0) + 1
    profile.index[carry.zoneId .. ":" .. disaster] = true
    profile.coins += Config.Earnings[carry.tier]
    local discovered = 0
    for _ in pairs(profile.index) do
        discovered += 1
    end
    player:SetAttribute("IndexCount", discovered)
    updateValues(player, profile)
    notify(
        player,
        ("ZONE %d REVEAL: %s %s | +%d Coins (memory-only)"):format(
            carry.zoneId,
            carry.tier,
            disaster,
            Config.Earnings[carry.tier]
        )
    )
end

local function train(player)
    local profile = profiles[player]
    if not profile or not within(player, world.trainPrompt.Parent.Position, 15) then
        return
    end
    local now = os.clock()
    if now - profile.lastTrain < Config.SpeedTrainingCooldown then
        return
    end
    profile.lastTrain = now
    local previous = unlockedZone(profile.speedPower)
    profile.speedPower =
        math.min(Config.MaxSpeedPower, profile.speedPower + Config.SpeedTrainingAmount)
    updateValues(player, profile)
    if unlockedZone(profile.speedPower) > previous then
        notify(player, "NEW ZONE UNLOCKED: " .. Config.Zones[unlockedZone(profile.speedPower)].Name)
    end
end

local function assignPlayer(player)
    local slot
    for i = 1, #world.plots do
        if occupiedPlots[i] == nil then
            slot = i
            break
        end
    end
    if not slot then
        player:Kick("All temporary prototype bases are occupied.")
        return
    end
    occupiedPlots[slot] = player.UserId
    local profile = {
        coins = 0,
        speedPower = 0,
        inventory = {},
        index = {},
        carry = nil,
        slowUntil = 0,
        lastTrain = -100,
        plotSlot = slot,
    }
    profiles[player] = profile
    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    stats.Parent = player
    for _, name in ipairs({ "Coins", "Speed" }) do
        local value = Instance.new("IntValue")
        value.Name = name
        value.Parent = stats
    end
    player:SetAttribute("IndexCount", 0)
    updateValues(player, profile)
    updateCarry(player, profile)
    local gui = world.plots[slot].pad:FindFirstChild("PlotSign")
    local text = gui and gui:FindFirstChildOfClass("TextLabel")
    if text then
        text.Text = "BASE: " .. player.DisplayName
    end
    player.CharacterAdded:Connect(function(character)
        clearCarry(player, profile, nil)
        local human = character:WaitForChild("Humanoid", 10)
        if human then
            human.WalkSpeed = Config.WalkSpeedBase
            human.Died:Connect(function()
                clearCarry(player, profile, "Crate dropped on death.")
            end)
        end
        task.delay(1.5, function()
            notify(
                player,
                "Base " .. slot .. ": train, travel the long road and carry a crate home."
            )
        end)
    end)
end

local function removePlayer(player)
    local profile = profiles[player]
    if not profile then
        return
    end
    clearCarry(player, profile, nil)
    occupiedPlots[profile.plotSlot] = nil
    local gui = world.plots[profile.plotSlot].pad:FindFirstChild("PlotSign")
    local text = gui and gui:FindFirstChildOfClass("TextLabel")
    if text then
        text.Text = "FREE TEST BASE " .. profile.plotSlot
    end
    profiles[player] = nil
end

for slot, plot in ipairs(world.plots) do
    plot.open.Triggered:Connect(function(player)
        openAtBase(player, slot)
    end)
end
world.trainPrompt.Triggered:Connect(train)
Players.PlayerAdded:Connect(assignPlayer)
Players.PlayerRemoving:Connect(removePlayer)
for _, player in Players:GetPlayers() do
    assignPlayer(player)
end
for zoneId in ipairs(world.zones) do
    spawnCrate(zoneId)
end

RunService.Heartbeat:Connect(function(delta)
    local now = os.clock()
    local targets = {}
    local distances = {}
    for player, profile in pairs(profiles) do
        local root, human = characterRoot(player)
        local carry = profile.carry
        if root and human then
            if carry and carry.status == "Escaping" then
                local zone = world.zones[carry.zoneId]
                if root.Position.Z >= zone.safeExitZ then
                    carry.status = "Secured"
                    profile.slowUntil = 0
                    updateCarry(player, profile)
                    notify(player, "SAFE! Follow the pale return lane back to YOUR base.")
                elseif now - carry.capturedAt >= Config.GuardWakeSeconds then
                    local distance = (root.Position - zone.warden.Position).Magnitude
                    if not distances[carry.zoneId] or distance < distances[carry.zoneId] then
                        distances[carry.zoneId] = distance
                        targets[carry.zoneId] = { player = player, root = root }
                    end
                end
                if
                    carry.status == "Escaping"
                    and carry.method == "Snatch"
                    and not carry.slowApplied
                    and now - carry.capturedAt >= Config.SnatchSlowdownDelay
                then
                    carry.slowApplied = true
                    profile.slowUntil = now + Config.SnatchSlowdownSeconds
                    notify(player, "CRATE BURST! Brief slowdown — keep moving.")
                end
            end
            local speed = math.min(
                Config.WalkSpeedCap,
                Config.WalkSpeedBase + math.floor(profile.speedPower / 100)
            )
            if carry and carry.status == "Secured" then
                speed = 30 -- Test-only return pacing: keep physical travel, not instant teleport.
            elseif now < profile.slowUntil then
                speed = Config.SnatchSlowdownWalkSpeed
            end
            if human.WalkSpeed ~= speed then
                human.WalkSpeed = speed
            end
        end
    end

    for zoneId, zone in ipairs(world.zones) do
        local target = targets[zoneId]
        local position = zone.warden.Position
        local destination = if target
            then Vector3.new(target.root.Position.X, position.Y, target.root.Position.Z)
            else zone.guardOrigin
        local direction = destination - position
        local speed = if target
            then (Config.GuardSpeedBase + (zoneId - 1) * Config.GuardSpeedPerZone)
            else Config.GuardReturnSpeed
        if direction.Magnitude > 0.05 then
            zone.warden.Position = position
                + direction.Unit * math.min(direction.Magnitude, speed * math.min(delta, 0.1))
        end
        if
            target
            and (zone.warden.Position - target.root.Position).Magnitude
                <= Config.GuardCatchRadius
        then
            local profile = profiles[target.player]
            if
                profile
                and profile.carry
                and profile.carry.status == "Escaping"
                and profile.carry.zoneId == zoneId
            then
                clearCarry(target.player, profile, "WARDEN CAUGHT YOU: unsecured crate lost.")
            end
        end
    end
end)
print("[Steal a Disaster] Five-zone Studio-only original map initialized (no DataStore).")
