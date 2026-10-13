--!strict
-- P1-02: public protocol and authored-world identifiers (not economy or loot balance).
local Definitions = {}

Definitions.ProtocolVersion = 1
Definitions.WorldContractVersion = 1
Definitions.MaxRequestBytes = 2048
Definitions.MaxRequestDepth = 3
Definitions.MaxRequestNodes = 32
Definitions.MaxIdBytes = 64

Definitions.ZoneIds = table.freeze({
    "tornado_town",
    "tsunami_coast",
    "volcanic_ruins",
    "thunderstorm_city",
    "inferno_forest",
})
Definitions.BaseCount = 7

Definitions.WorldTags = table.freeze({
    Base = "DisasterBase",
    ZoneEntry = "DisasterZoneEntry",
    ZoneExit = "DisasterZoneExit",
    CrateNode = "DisasterCrateNode",
})

-- Only Snapshot is wired in P1-02. Later gameplay actions must have explicit
-- server-side validators/handlers before they become exposed to clients.
Definitions.Actions = table.freeze({ Snapshot = "Snapshot" })
Definitions.Codes = table.freeze({
    InvalidRequest = "InvalidRequest",
    UnsupportedProtocol = "UnsupportedProtocol",
    UnknownAction = "UnknownAction",
    RateLimited = "RateLimited",
    NotReady = "NotReady",
    InternalError = "InternalError",
})

function Definitions.IsZoneId(value: unknown): boolean
    if type(value) ~= "string" then
        return false
    end
    for _, zoneId in ipairs(Definitions.ZoneIds) do
        if zoneId == value then
            return true
        end
    end
    return false
end

return table.freeze(Definitions)
