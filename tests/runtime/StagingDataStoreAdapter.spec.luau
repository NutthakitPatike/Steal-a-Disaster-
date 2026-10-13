--!strict
-- Guard tests only; deliberately never call Create or open any Roblox DataStore.
return function(): number
    local Adapter = require(game.ServerScriptService.Server.StagingDataStoreAdapter)
    local passed = 0
    local function reject(config, gameId, placeId, expected)
        local ok, code = Adapter.ValidateConfig(config, gameId, placeId)
        assert(not ok and code == expected, tostring(code) .. " should be " .. expected)
        passed += 1
    end
    local config = {
        enabled = true,
        confirmedIsolatedStaging = true,
        gameId = 99992221,
        placeId = 99992222,
        namespace = "qa_october_2026",
    }
    reject(nil, 99992221, 99992222, "ExplicitStagingApprovalRequired")
    local incomplete = table.clone(config)
    incomplete.enabled = false
    reject(incomplete, 99992221, 99992222, "ExplicitStagingApprovalRequired")
    incomplete = table.clone(config)
    incomplete.confirmedIsolatedStaging = false
    reject(incomplete, 99992221, 99992222, "ExplicitStagingApprovalRequired")
    reject(config, 10770595743, 89467184271147, "ProtectedOrUnknownUniverse")
    reject(config, 0, 0, "ProtectedOrUnknownUniverse")
    reject(config, 5555, 99992222, "WrongStagingExperience")
    reject(config, 99992221, 5555, "WrongStagingExperience")
    incomplete = table.clone(config)
    incomplete.namespace = "bad-name"
    reject(incomplete, 99992221, 99992222, "InvalidNamespace")
    incomplete = table.clone(config)
    incomplete.namespace = "short"
    reject(incomplete, 99992221, 99992222, "InvalidNamespace")
    local ok, err = Adapter.ValidateConfig(config, 99992221, 99992222)
    assert(ok and err == nil, tostring(err))
    passed += 1
    return passed
end
