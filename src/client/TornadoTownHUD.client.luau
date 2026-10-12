--!nonstrict
-- Temporary, code-generated UI for Studio greybox tests. Player Attributes are display-only.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
if not RunService:IsStudio() then
    return
end
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "TornadoTownPrototypeHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "StatsPanel"
panel.Size = UDim2.fromOffset(310, 142)
panel.Position = UDim2.fromOffset(12, 14)
panel.BackgroundColor3 = Color3.fromRGB(20, 27, 39)
panel.BackgroundTransparency = 0.1
panel.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(80, 144, 172)
stroke.Thickness = 1
stroke.Parent = panel

local function makeText(name, y, height, size, color)
    local txt = Instance.new("TextLabel")
    txt.Name = name
    txt.Position = UDim2.fromOffset(12, y)
    txt.Size = UDim2.new(1, -24, 0, height)
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.BackgroundTransparency = 1
    txt.TextScaled = false
    txt.TextSize = size
    txt.Font = Enum.Font.GothamBold
    txt.TextColor3 = color or Color3.new(1, 1, 1)
    txt.TextWrapped = true
    txt.Parent = panel
    return txt
end
local title = makeText("Header", 8, 22, 16, Color3.fromRGB(146, 224, 237))
title.Text = "TORNADO TOWN  |  STUDIO TEST"
local money = makeText("Money", 35, 23, 15)
local speed = makeText("Speed", 60, 23, 15)
local crate = makeText("Crate", 85, 23, 15)
local index = makeText("Index", 110, 23, 14, Color3.fromRGB(194, 216, 229))
local instructions = Instance.new("TextLabel")
instructions.Name = "Help"
instructions.Size = UDim2.new(0.8, 0, 0, 58)
instructions.Position = UDim2.new(0.1, 0, 1, -69)
instructions.BackgroundColor3 = Color3.fromRGB(20, 27, 39)
instructions.BackgroundTransparency = 0.15
instructions.TextColor3 = Color3.new(1, 1, 1)
instructions.TextSize = 14
instructions.Font = Enum.Font.Gotham
instructions.TextWrapped = true
instructions.Text = "Train at the blue stand → collect a crate in Zone 1 → escape the Warden → open at YOUR assigned base"
instructions.Parent = gui
local helpCorner = Instance.new("UICorner")
helpCorner.CornerRadius = UDim.new(0, 10)
helpCorner.Parent = instructions

local notification = Instance.new("TextLabel")
notification.Name = "Notification"
notification.AnchorPoint = Vector2.new(0.5, 0)
notification.Position = UDim2.new(0.5, 0, 0.05, 0)
notification.Size = UDim2.new(0.7, 0, 0, 56)
notification.BackgroundColor3 = Color3.fromRGB(34, 68, 83)
notification.BackgroundTransparency = 0.08
notification.TextColor3 = Color3.new(1, 1, 1)
notification.TextSize = 16
notification.Font = Enum.Font.GothamBold
notification.TextWrapped = true
notification.Visible = false
notification.Parent = gui
local notifCorner = Instance.new("UICorner")
notifCorner.CornerRadius = UDim.new(0, 12)
notifCorner.Parent = notification
local function refresh()
    money.Text = "Chaos Coins: " .. tostring(player:GetAttribute("ChaosCoins") or 0)
    speed.Text = "Speed Power: " .. tostring(player:GetAttribute("SpeedPower") or 0)
    local status = player:GetAttribute("CarryStatus") or "Empty"
    local tier = player:GetAttribute("CarryingTier") or ""
    crate.Text = "Crate: " .. (status == "Empty" and "None" or (tier .. " / " .. status))
    index.Text = "Zone 1 | Index discovered: " .. tostring(player:GetAttribute("IndexCount") or 0)
end
for _, attribute in ipairs({ "ChaosCoins", "SpeedPower", "CarryStatus", "CarryingTier", "IndexCount" }) do
    player:GetAttributeChangedSignal(attribute):Connect(refresh)
end
refresh()

local serial = 0
local remotes = ReplicatedStorage:WaitForChild("PrototypeRemotes", 12)
if remotes then
    local notify = remotes:WaitForChild("Notify", 12)
    if notify then
        notify.OnClientEvent:Connect(function(message)
            serial += 1
            local current = serial
            notification.Text = tostring(message)
            notification.Visible = true
            task.delay(5, function()
                if current == serial then
                    notification.Visible = false
                end
            end)
        end)
    end
end
