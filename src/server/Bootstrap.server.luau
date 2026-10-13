--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

print(("[Server] %s prototype %s ready"):format(Config.WorkingTitle, Config.PrototypeVersion))

-- P1-02 staging only: expose a validated, read-only protocol boundary.
-- Production economy/inventory must not start until P1-03 data ownership exists.
if game:GetService("RunService"):IsStudio() then
    local RemoteRouter = require(script.Parent:WaitForChild("RemoteRouter"))
    RemoteRouter.Start()
end
