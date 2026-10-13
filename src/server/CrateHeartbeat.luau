--!strict
-- P1-04 opt-in bounded server heartbeat. Does not spawn crates, expose remotes,
-- or start until Start() is called by an approved server integration.
local RunService = game:GetService("RunService")
local CrateHeartbeat = {}
CrateHeartbeat.__index = CrateHeartbeat

local INTERVAL = 0.1

function CrateHeartbeat.new(crates: any, clock: () -> number)
    assert(RunService:IsServer(), "ServerOnly")
    assert(
        type(crates) == "table"
            and type(crates.Heartbeat) == "function"
            and type(clock) == "function",
        "Crates service and server clock required"
    )
    return setmetatable({
        crates = crates,
        clock = clock,
        lastStep = nil,
        running = false,
        generation = 0,
    }, CrateHeartbeat)
end

function CrateHeartbeat:Step(): (boolean, string?)
    local now = self.clock()
    if type(now) ~= "number" or now ~= now or now == math.huge or now < 0 or now >= 9999999000 then
        return false, "InvalidTime"
    end
    if self.lastStep then
        if now < self.lastStep then
            return false, "ClockRegressed"
        end
        if now - self.lastStep < INTERVAL then
            return true, nil
        end
    end
    self.lastStep = now
    return self.crates:Heartbeat()
end

function CrateHeartbeat:Start(): boolean
    if self.running then
        return false
    end
    self.running = true
    self.generation += 1
    local ownGeneration = self.generation
    task.spawn(function()
        while self.running and self.generation == ownGeneration do
            local ok, issue = self:Step()
            if not ok then
                warn(("[Crates] server sampling failed: %s"):format(tostring(issue)))
                self:Stop()
                break
            end
            task.wait(INTERVAL)
        end
    end)
    return true
end

function CrateHeartbeat:Stop()
    self.running = false
    self.generation += 1
end

return table.freeze(CrateHeartbeat)
