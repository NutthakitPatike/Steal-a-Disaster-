--!nonstrict
-- Prototype only: memory-only rewards, no production DataStore writes, no monetization.
-- All crate claims, guard catches, base ownership and grants are handled on the server.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PrototypeConfig"))
local World = require(script.Parent:WaitForChild("PrototypeWorld"))

-- Never spawn prototype terrain or mutate state in a published/live server.
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
local nextCrateId = 0
local activeCrate = nil
local spawnCrate

local function notify(player, message)
    if player.Parent == Players then
        notifyEvent:FireClient(player, message)
    end
end

local function characterRoot(player)
    local character = player.Character
    local human = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not human or human.Health <= 0 or not root then
        return nil, nil
    end
    return root, human
end

local function within(player, position, radius)
    local root = characterRoot(player)
    return root ~= nil and (root.Position - position).Magnitude <= radius
end

local function updateValues(player, profile)
    player:SetAttribute("ChaosCoins", profile.coins)
    player:SetAttribute("SpeedPower", profile.speedPower)
    player:SetAttribute("HighestZone", 1)
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
    visual.Color = if tier == "Rare" then Color3.fromRGB(218, 150, 255) else Color3.fromRGB(120, 213, 228)
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

local function takeCrate(player, instanceId, method)
    local profile = profiles[player]
    local crate = activeCrate
    if not profile or profile.carry or not crate or crate.id ~= instanceId or crate.claimed then
        return
    end
    if not within(player, crate.position, Config.CaptureDistance) then
        return
    end
    -- No yield between claim check and assignment: simultaneous prompt triggers cannot both win.
    crate.claimed = true
    activeCrate = nil
    crate.model:Destroy()

    local visual = equipVisual(player, crate.tier)
    if not visual then
        notify(player, "Capture failed because your character is unavailable.")
        task.delay(Config.CrateRespawnSeconds, spawnCrate)
        return
    end
    profile.carry = {
        id = instanceId,
        tier = crate.tier,
        method = method,
        status = "Escaping",
        capturedAt = os.clock(),
        visual = visual,
        slowApplied = false,
    }
    updateCarry(player, profile)
    notify(player, crate.tier .. " Crate taken with " .. method .. "! Escape the Warden to the green line.")
    if method == "Snatch" then
        notify(player, "UNSTABLE: a short slowdown is coming. Choose your escape path!")
    end
    task.delay(Config.CrateRespawnSeconds, spawnCrate)
end

function spawnCrate()
    if activeCrate ~= nil or world.root.Parent == nil then
        return
    end
    nextCrateId += 1
    local id = nextCrateId
    local tier = chooseTier()
    local position = world.nodes[rng:NextInteger(1, #world.nodes)]
    local model = Instance.new("Model")
    model.Name = "Crate_" .. id
    model.Parent = world.root
    local core = world.part(model, tier .. " Containment Crate", position, Vector3.new(5, 5, 5),
        if tier == "Rare" then Color3.fromRGB(166, 110, 240) else Color3.fromRGB(100, 190, 218), false)
    core.Material = Enum.Material.Neon
    world.label(core, "TierSign", tier:upper() .. " CRATE", Vector3.new(0, 6, 0))
    for _, option in ipairs({
        { name = "Stabilize", seconds = 2.0, deltaX = -7, color = Color3.fromRGB(75, 186, 160) },
        { name = "Snatch", seconds = 0.0, deltaX = 7, color = Color3.fromRGB(239, 169, 87) },
    }) do
        local button = world.part(model, option.name .. "Handle",
            position + Vector3.new(option.deltaX, -1, 0), Vector3.new(4, 3, 4), option.color, false)
        local prompt = world.prompt(button, option.name, option.seconds)
        prompt.Triggered:Connect(function(player)
            takeCrate(player, id, option.name)
        end)
        world.label(button, option.name .. "Sign", option.name, Vector3.new(0, 4.5, 0))
    end
    activeCrate = { id = id, tier = tier, model = model, position = position, claimed = false }
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
        notify(player, "First escape with a crate, then open it at your own base.")
        return
    end
    -- Consume first; never yield between validation and grant.
    profile.carry = nil
    if carry.visual then carry.visual:Destroy() end
    updateCarry(player, profile)
    local pool = Config.Rewards[carry.tier]
    assert(pool and #pool > 0, "Crate tier has no server reward pool")
    local disaster = pool[rng:NextInteger(1, #pool)]
    profile.inventory[disaster] = (profile.inventory[disaster] or 0) + 1
    profile.index[disaster] = true
    profile.coins += Config.Earnings[carry.tier]
    local discovered = 0
    for _ in pairs(profile.index) do discovered += 1 end
    player:SetAttribute("IndexCount", discovered)
    updateValues(player, profile)
    notify(player, "REVEALED " .. carry.tier .. " / " .. disaster
        .. " | +" .. Config.Earnings[carry.tier] .. " Chaos Coins. Rewards are memory-only in this test.")
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
    profile.speedPower = math.min(Config.MaxSpeedPower, profile.speedPower + Config.SpeedTrainingAmount)
    updateValues(player, profile)
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
        player:Kick("All temporary prototype test bases are occupied.")
        return
    end
    occupiedPlots[slot] = player.UserId
    local profile = {
        coins = 0, speedPower = 0, inventory = {}, index = {},
        carry = nil, slowUntil = 0, lastTrain = -100, plotSlot = slot,
    }
    profiles[player] = profile
    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    stats.Parent = player
    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Parent = stats
    local speed = Instance.new("IntValue")
    speed.Name = "Speed"
    speed.Parent = stats
    player:SetAttribute("IndexCount", 0)
    updateValues(player, profile)
    updateCarry(player, profile)
    local gui = world.plots[slot].pad:FindFirstChild("PlotSign")
    if gui and gui:FindFirstChildOfClass("TextLabel") then
        gui:FindFirstChildOfClass("TextLabel").Text = "BASE: " .. player.DisplayName
    end
    player.CharacterAdded:Connect(function(character)
        clearCarry(player, profile, nil)
        local human = character:WaitForChild("Humanoid", 10)
        if human then
            human.WalkSpeed = Config.WalkSpeedBase
            human.Died:Connect(function()
                clearCarry(player, profile, "You dropped the unsecured crate on respawn.")
            end)
        end
        task.delay(1.5, function()
            notify(player, "Your test base is " .. slot .. ". Train, enter Zone 1, escape, then open your crate there.")
        end)
    end)
    if player.Character then
        local human = player.Character:FindFirstChildOfClass("Humanoid")
        if human then human.WalkSpeed = Config.WalkSpeedBase end
    end
end

local function removePlayer(player)
    local profile = profiles[player]
    if not profile then return end
    clearCarry(player, profile, nil)
    occupiedPlots[profile.plotSlot] = nil
    local gui = world.plots[profile.plotSlot].pad:FindFirstChild("PlotSign")
    if gui and gui:FindFirstChildOfClass("TextLabel") then
        gui:FindFirstChildOfClass("TextLabel").Text = "FREE TEST BASE " .. profile.plotSlot
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
for _, player in Players:GetPlayers() do assignPlayer(player) end

spawnCrate()
RunService.Heartbeat:Connect(function(delta)
    local targetRoot = nil
    local targetPlayer = nil
    local best = math.huge
    local now = os.clock()
    for player, profile in pairs(profiles) do
        local root, human = characterRoot(player)
        local carry = profile.carry
        if root and human then
            if carry and carry.status == "Escaping" and root.Position.Z >= Config.SafeExitZ then
                carry.status = "Secured"
                profile.slowUntil = 0
                updateCarry(player, profile)
                notify(player, "SAFE! Deliver the secured crate to YOUR test base and open it.")
            end
            if carry and carry.status == "Escaping" then
                if carry.method == "Snatch" and not carry.slowApplied
                    and now - carry.capturedAt >= Config.SnatchSlowdownDelay then
                    carry.slowApplied = true
                    profile.slowUntil = now + Config.SnatchSlowdownSeconds
                    notify(player, "CRATE BURST! Brief slowdown — keep running.")
                end
                if now - carry.capturedAt >= Config.GuardWakeSeconds then
                    local distance = (root.Position - world.warden.Position).Magnitude
                    if distance < best then
                        best = distance
                        targetRoot = root
                        targetPlayer = player
                    end
                end
            end
            local wanted = math.min(Config.WalkSpeedCap,
                Config.WalkSpeedBase + math.floor(profile.speedPower / 100))
            if now < profile.slowUntil then
                wanted = Config.SnatchSlowdownWalkSpeed
            end
            if human.WalkSpeed ~= wanted then
                human.WalkSpeed = wanted
            end
        end
    end
    local guardPos = world.warden.Position
    local destination = if targetRoot then Vector3.new(targetRoot.Position.X, guardPos.Y, targetRoot.Position.Z)
        else world.guardOrigin
    local direction = destination - guardPos
    local speed = if targetRoot then Config.GuardSpeed else Config.GuardReturnSpeed
    if direction.Magnitude > 0.05 then
        world.warden.Position = guardPos + direction.Unit * math.min(direction.Magnitude, speed * math.min(delta, 0.1))
    end
    if targetPlayer and targetRoot and (world.warden.Position - targetRoot.Position).Magnitude <= Config.GuardCatchRadius then
        local p = profiles[targetPlayer]
        if p and p.carry and p.carry.status == "Escaping" then
            clearCarry(targetPlayer, p, "WARDEN CAUGHT YOU. Unsecured crate lost; existing rewards kept.")
        end
    end
end)
print("[Tornado Town] Memory-only greybox server prototype started; no DataStore is accessed.")
