"use strict";
// Source-level checks. These do not execute Roblox physics or substitute for Studio Playtests.
const { test } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const read = (name) => fs.readFileSync(path.join(__dirname, "..", name), "utf8");
const server = read("src/server/TornadoTownPrototype.server.luau");
const world = read("src/server/PrototypeWorld.luau");
const map = read("src/server/ZoneMap.luau");
const config = read("src/shared/PrototypeConfig.luau");
const client = read("src/client/TornadoTownHUD.client.luau");

test("only Studio and memory-only server state", () => {
  assert.match(server, /not RunService:IsStudio\(\)/);
  assert.match(client, /not RunService:IsStudio\(\)/);
  assert.doesNotMatch(server + world + map + client + config, /DataStoreService|SetAsync|UpdateAsync|GetAsync|InsertService/);
});
test("five distinct Zones with increasing test requirements", () => {
  const zones = [...config.matchAll(/\{ Name = "([^"]+)", RequiredSpeed = (\d+) \}/g)];
  assert.deepEqual(zones.map(x => x[1]), [
    "Tornado Town", "Tsunami Coast", "Volcanic Ruins", "Thunderstorm City", "Inferno Forest",
  ]);
  assert.deepEqual(zones.map(x => Number(x[2])), [0, 40, 120, 230, 350]);
  assert.match(map, /for i, definition in ipairs\(config.Zones\) do/);
  assert.match(world, /ZoneMap.create\(root, part, label, Config\)/);
});
test("one physical line and connected entry/return floors", () => {
  const length = Number(config.match(/ZoneLength = (\d+)/)[1]);
  const spacing = Number(config.match(/ZoneSpacing = (\d+)/)[1]);
  assert.equal(spacing - length, 20);
  assert.match(map, /config.ZoneSpacing - config.ZoneLength \+ 4/); // bridge overlaps both zone floors
  assert.match(world, /"MainApproach"/);
  assert.match(world, /"ReturnApproach"/);
  assert.match(map, /"ReturnShoulder"/);
  assert.match(map, /"ReturnLink_/);
});
test("server controls every zone crate claim, tier reveal and base ownership", () => {
  assert.match(server, /activeCrates\[zoneId\] = nil/);
  assert.match(server, /crate.claimed = true/);
  assert.match(server, /profile.speedPower < Config.Zones\[zoneId\].RequiredSpeed/);
  assert.match(server, /profile.plotSlot ~= slot/);
  assert.match(server, /occupiedPlots\[slot\] ~= player.UserId/);
  assert.match(server, /carry.status ~= "Secured"/);
  assert.match(server, /profile.carry = nil/);
  assert.match(server, /Config.Rewards\[carry.zoneId\]\[carry.tier\]/);
  assert.doesNotMatch(client, /FireServer\(/);
});
test("five zone-specific Wardens, capture choices and no live admin system", () => {
  assert.match(map, /local warden\s*=\s*block\("Warden_" \.\. i/);
  assert.match(server, /for zoneId, zone in ipairs\(world.zones\) do/);
  assert.match(server, /name = "Stabilize",\s*seconds = 2.0/);
  assert.match(server, /name = "Snatch",\s*seconds = 0.0/);
  assert.match(server, /carry.method == "Snatch"/);
  assert.doesNotMatch(server, /Config.Rewards\[carry.method\]/);
  assert.doesNotMatch(server, /MessagingService|PublishAsync/);
});
test("no reference-game 3D models or published assets are embedded", () => {
  assert.doesNotMatch(map, /rbxassetid:|InsertService|AssetService:Load/);
});
