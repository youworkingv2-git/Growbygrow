extends Node
## Loads and indexes all data-driven JSON files for Worlds, Areas, Characters, NPCs, Dialogues, Quests, and Objects.

var worlds: Array[Dictionary] = []
var areas_by_id: Dictionary = {}
var areas_ordered: Array[Dictionary] = []
var playable_characters: Array[Dictionary] = []
var buddy_config: Dictionary = {}
var npcs_by_id: Dictionary = {}
var dialogues_by_id: Dictionary = {}
var quests_by_id: Dictionary = {}
var quests_ordered: Array[Dictionary] = []
var objects_by_id: Dictionary = {}


func _ready() -> void:
	reload_all()


func reload_all() -> void:
	worlds.clear()
	areas_by_id.clear()
	areas_ordered.clear()
	playable_characters.clear()
	buddy_config.clear()
	npcs_by_id.clear()
	dialogues_by_id.clear()
	quests_by_id.clear()
	quests_ordered.clear()
	objects_by_id.clear()

	_load_worlds()
	_load_areas()
	_load_characters()
	_load_npcs()
	_load_dialogues()
	_load_quests()
	_load_objects()
	AppLogger.info("DataRepository", "Loaded %d areas, %d NPCs, %d quests, %d objects" % [
		areas_ordered.size(), npcs_by_id.size(), quests_ordered.size(), objects_by_id.size()
	])


func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		AppLogger.error("DataRepository", "Missing JSON data file: " + path)
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		AppLogger.error("DataRepository", "Cannot open JSON file: " + path)
		return {}
	var text := f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		AppLogger.error("DataRepository", "Invalid JSON root dictionary in: " + path)
		return {}
	return parsed


func _load_worlds() -> void:
	var doc := _read_json("res://data/worlds/worlds.json")
	for w in doc.get("worlds", []):
		if typeof(w) == TYPE_DICTIONARY:
			worlds.append(w)


func _load_areas() -> void:
	var doc := _read_json("res://data/areas/alphabet_island_areas.json")
	for a in doc.get("areas", []):
		if typeof(a) == TYPE_DICTIONARY and a.has("id"):
			areas_by_id[str(a["id"])] = a
			areas_ordered.append(a)
	areas_ordered.sort_custom(func(x: Dictionary, y: Dictionary) -> bool:
		return int(x.get("order_index", 0)) < int(y.get("order_index", 0))
	)


func _load_characters() -> void:
	var doc := _read_json("res://data/characters/playable_characters.json")
	for c in doc.get("characters", []):
		if typeof(c) == TYPE_DICTIONARY:
			playable_characters.append(c)
	if typeof(doc.get("buddy", {})) == TYPE_DICTIONARY:
		buddy_config = doc.get("buddy", {})


func _load_npcs() -> void:
	var doc := _read_json("res://data/npcs/alphabet_island_npcs.json")
	for npc in doc.get("npcs", []):
		if typeof(npc) == TYPE_DICTIONARY and npc.has("id"):
			npcs_by_id[str(npc["id"])] = npc


func _load_dialogues() -> void:
	var doc := _read_json("res://data/dialogue/alphabet_island_dialogues.json")
	var dlg_map: Variant = doc.get("dialogues", {})
	if typeof(dlg_map) == TYPE_DICTIONARY:
		for key in dlg_map.keys():
			dialogues_by_id[str(key)] = dlg_map[key]


func _load_quests() -> void:
	var doc := _read_json("res://data/quests/world_01_quests.json")
	for q in doc.get("quests", []):
		if typeof(q) == TYPE_DICTIONARY and q.has("id"):
			quests_by_id[str(q["id"])] = q
			quests_ordered.append(q)
	quests_ordered.sort_custom(func(x: Dictionary, y: Dictionary) -> bool:
		return int(x.get("order_index", 0)) < int(y.get("order_index", 0))
	)


func _load_objects() -> void:
	var doc := _read_json("res://data/interactions/alphabet_island_objects.json")
	for obj in doc.get("objects", []):
		if typeof(obj) == TYPE_DICTIONARY and obj.has("id"):
			objects_by_id[str(obj["id"])] = obj


func get_area(area_id: String) -> Dictionary:
	return areas_by_id.get(area_id, {})


func get_npcs_for_area(area_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for npc in npcs_by_id.values():
		if str(npc.get("area_id", "")) == area_id:
			result.append(npc)
	return result


func get_objects_for_area(area_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for obj in objects_by_id.values():
		if str(obj.get("area_id", "")) == area_id:
			result.append(obj)
	return result


func get_character_config(gender_id: String) -> Dictionary:
	for c in playable_characters:
		if str(c.get("id", "")) == gender_id:
			return c
	return playable_characters[0] if not playable_characters.is_empty() else {}
