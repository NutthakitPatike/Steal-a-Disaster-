--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

print(("[Client] %s prototype %s ready"):format(Config.WorkingTitle, Config.PrototypeVersion))
