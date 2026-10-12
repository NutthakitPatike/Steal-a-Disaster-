--!strict
-- Non-sensitive, server-validated prototype tuning. No paid content or production data.
local PrototypeConfig = {
    Enabled = true,
    WorldName = "TornadoTownPrototype",
    ZoneName = "Tornado Town",
    ZoneId = 1,
    SafeExitZ = -140,
    ZoneMinZ = -338,
    MaxPlayers = 6,
    CaptureDistance = 15,
    BaseOpenDistance = 14,
    GuardCatchRadius = 6,
    GuardSpeed = 19,
    GuardWakeSeconds = 2.0,
    GuardReturnSpeed = 18,
    CrateRespawnSeconds = 6,
    CrateTierWeights = { Common = 85, Rare = 15 },
    Rewards = {
        Common = { "Mini Tornado", "Drizzle Cloud" },
        Rare = { "Gust Sprite", "Storm Puff" },
    },
    Earnings = { Common = 100, Rare = 300 },
    SpeedTrainingAmount = 10,
    SpeedTrainingCooldown = 1,
    MaxSpeedPower = 500,
    WalkSpeedBase = 16,
    WalkSpeedCap = 20,
    SnatchSlowdownDelay = 2.8,
    SnatchSlowdownSeconds = 1.2,
    SnatchSlowdownWalkSpeed = 13,
}
return table.freeze(PrototypeConfig)
