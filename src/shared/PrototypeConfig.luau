--!strict
-- STUDIO-ONLY test settings. Never use these test odds/prices for a live economy.
local PrototypeConfig = {
    Enabled = true,
    WorldName = "DisasterFiveZonePrototype",
    ZoneLength = 205,
    ZoneSpacing = 225,
    FirstZoneCenterZ = -245,
    Zones = {
        { Name = "Tornado Town", RequiredSpeed = 0 },
        { Name = "Tsunami Coast", RequiredSpeed = 40 },
        { Name = "Volcanic Ruins", RequiredSpeed = 120 },
        { Name = "Thunderstorm City", RequiredSpeed = 230 },
        { Name = "Inferno Forest", RequiredSpeed = 350 },
    },
    CaptureDistance = 22, -- Includes offset from crate center to either prompt handle.
    BaseOpenDistance = 14,
    GuardCatchRadius = 6,
    GuardSpeedBase = 14,
    GuardSpeedPerZone = 1.1,
    GuardWakeSeconds = 2.5,
    GuardReturnSpeed = 17,
    CrateRespawnSeconds = 7,
    -- Placeholder test rolls (two-stage rarity -> within-tier reveal).
    CrateTierWeights = { Common = 85, Rare = 15 },
    Rewards = {
        { Common = { "Mini Tornado", "Drizzle Cloud" }, Rare = { "Gust Sprite", "Storm Puff" } },
        { Common = { "Ripple", "Tide Bubble" }, Rare = { "Wavelet", "Deep Current" } },
        { Common = { "Pebble", "Warm Cinder" }, Rare = { "Magma Cub", "Ash Sprite" } },
        { Common = { "Spark Dot", "Rain Static" }, Rare = { "Zappy", "Thunder Puff" } },
        { Common = { "Ember", "Smoke Cloud" }, Rare = { "Flare Fox", "Wildfire Wisp" } },
    },
    Earnings = { Common = 100, Rare = 300 },
    SpeedTrainingAmount = 10,
    SpeedTrainingCooldown = 1,
    MaxSpeedPower = 500,
    WalkSpeedBase = 16,
    WalkSpeedCap = 21,
    SnatchSlowdownDelay = 2.8,
    SnatchSlowdownSeconds = 1.2,
    SnatchSlowdownWalkSpeed = 13,
}
return table.freeze(PrototypeConfig)
