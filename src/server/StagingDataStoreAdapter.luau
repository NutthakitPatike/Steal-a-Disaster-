--!strict
-- Opt-in staging DataStore adapter. This module never opens a data store
-- when required; Create must be called in a separately approved experience.
local StagingDataStoreAdapter = {}
local PROTECTED_GAME_ID = 10770595743 -- audited main universe for Steal A Disaster!
local STORE_PREFIX = "SAD_P1_STAGING_"

function StagingDataStoreAdapter.ValidateConfig(options: any, currentGameId: number, currentPlaceId: number): (boolean, string?)
    if type(options) ~= "table" or options.enabled ~= true
        or options.confirmedIsolatedStaging ~= true then
        return false, "ExplicitStagingApprovalRequired"
    end
    if type(currentGameId) ~= "number" or currentGameId <= 0
        or currentGameId == PROTECTED_GAME_ID then
        return false, "ProtectedOrUnknownUniverse"
    end
    if type(options.gameId) ~= "number" or type(options.placeId) ~= "number"
        or options.gameId ~= currentGameId or options.placeId ~= currentPlaceId then
        return false, "WrongStagingExperience"
    end
    local namespace = options.namespace
    if type(namespace) ~= "string" or #namespace < 8 or #namespace > 32
        or not namespace:match("^[%w_]+$") then
        return false, "InvalidNamespace"
    end
    return true, nil
end

function StagingDataStoreAdapter.Create(options: any)
    local RunService = game:GetService("RunService")
    if not RunService:IsServer() then
        return nil, "ServerOnly"
    end
    local allowed, reason = StagingDataStoreAdapter.ValidateConfig(options, game.GameId, game.PlaceId)
    if not allowed then
        return nil, reason
    end
    local DataStoreService = game:GetService("DataStoreService")
    local store = DataStoreService:GetDataStore(STORE_PREFIX .. options.namespace)
    local adapter = {}
    function adapter:UpdateAsync(key: string, transform: (any) -> any)
        assert(type(key) == "string" and key:match("^PlayerV1_%d+$"), "InvalidProfileKey")
        assert(type(transform) == "function", "TransformRequired")
        -- The transform is pure and may be retried by Roblox.
        return store:UpdateAsync(key, transform)
    end
    return adapter, nil
end

return table.freeze(StagingDataStoreAdapter)
