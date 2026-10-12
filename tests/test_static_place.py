"""Structural verification of saved Roblox Studio map assets (not a playtest)."""
from pathlib import Path
import xml.etree.ElementTree as ET

repo = Path(__file__).resolve().parents[1]
place_path = repo / "studio/places/StealADisaster_EggLayout_Static.rbxlx"
model_path = repo / "studio/exports/StealADisaster_EggLayout_Map.rbxmx"

def name(obj):
    return obj.findtext("Properties/string[@name='Name']")

def check(root, label):
    roots = [x for x in root.findall(".//Item") if name(x) == "DisasterFiveZonePrototype"]
    assert len(roots) == 1, (label, "expected one permanent map root", len(roots))
    scene = roots[0]
    models = [x for x in scene.findall("./Item") if x.get("class") == "Model"]
    zone_models = [x for x in models if (name(x) or "").startswith("Zone")]
    assert len(zone_models) == 5, (label, "zone count", len(zone_models))
    expected = ["TornadoTown", "TsunamiCoast", "VolcanicRuins", "ThunderstormCity", "InfernoForest"]
    assert [name(x) for x in zone_models] == [
        f"Zone{i:02d}_{value}" for i, value in enumerate(expected, 1)
    ], (label, "zone order")
    hub = next(x for x in models if name(x) == "Hub_Original")
    bases = [x for x in hub.findall("./Item") if (name(x) or "").startswith("TestBase_")]
    assert len(bases) == 7, (label, "base count", len(bases))
    for i in range(1, 8):
        base = next(x for x in bases if name(x) == f"TestBase_{i:02d}")
        children = [name(x) for x in base.findall(".//Item")]
        assert f"TestPlot{i}" in children, (label, "missing base pad", i)
        assert f"CrateOpener{i}" in children, (label, "missing base opener", i)
        assert any(x.startswith("Fence_") for x in children), (label, "missing plot fence", i)
    part_count = sum(x.get("class") == "Part" for x in scene.iter("Item"))
    assert part_count >= 1800, (label, "missing editable parts", part_count)
    for i, zone in enumerate(zone_models, 1):
        names = {name(x) for x in zone.iter("Item")}
        required = {f"CrateSpawn{j}" for j in (1, 2)} | {f"Warden_{i}", f"SafeExit_{i}"}
        assert required.issubset(names), (label, "missing zone gameplay markers", i, required - names)
        assert sum(n.startswith("Tile_") for n in names if n) >= 200, (label, "missing biome tiles", i)
    print(f"{label}: 5 Zones, 7 fenced plots, {part_count} editable Parts: PASS")
    return scene

def main():
    root_place = ET.parse(place_path).getroot()
    root_model = ET.parse(model_path).getroot()
    assert root_place.tag == root_model.tag == "roblox"
    assert any(x.get("class") == "Workspace" for x in root_place.findall("./Item"))
    check(root_place, "Place")
    check(root_model, "Map model")
    assert any(x.get("class") == "Script" for x in root_place.iter("Item")), "Missing game scripts in Place"
    assert not any(x.get("class") in {"Script", "LocalScript"} for x in root_model.iter("Item")), "Map export should contain geometry, not scripts"
    print("All structural map checks PASS (runtime movement/physics untested).")

if __name__ == "__main__":
    main()
