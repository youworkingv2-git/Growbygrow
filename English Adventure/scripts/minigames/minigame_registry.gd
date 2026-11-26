class_name MiniGameRegistry
extends RefCounted
## Data-driven Registry managing all core and extensible mini-games.
## Allows adding new mini-games via JSON/plugin registration without modifying MiniGameManager.

const REGISTRY_PATH := "res://data/minigames/minigame_registry.json"

var entries_ordered: Array[Dictionary] = []
var entries_by_id: Dictionary = {}


func reload() -> void:
	entries_ordered.clear()
	entries_by_id.clear()
	if not FileAccess.file_exists(REGISTRY_PATH):
		AppLogger.error("MiniGameRegistry", "Missing registry JSON: " + REGISTRY_PATH)
		return
	var f := FileAccess.open(REGISTRY_PATH, FileAccess.READ)
	if f == null:
		AppLogger.error("MiniGameRegistry", "Cannot open registry JSON: " + REGISTRY_PATH)
		return
	var raw := f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		AppLogger.error("MiniGameRegistry", "Invalid JSON dictionary in registry")
		return
	var doc: Dictionary = parsed
	for item_var in doc.get("minigames", []):
		if typeof(item_var) == TYPE_DICTIONARY:
			register_entry(item_var as Dictionary)


func register_entry(entry: Dictionary) -> void:
	var gid := str(entry.get("id", ""))
	if gid.is_empty():
		return
	if entries_by_id.has(gid):
		entries_by_id[gid] = entry.duplicate(true)
		for i in range(entries_ordered.size()):
			if str(entries_ordered[i].get("id", "")) == gid:
				entries_ordered[i] = entry.duplicate(true)
				break
	else:
		var copy := entry.duplicate(true)
		entries_by_id[gid] = copy
		entries_ordered.append(copy)


func get_entry(minigame_id: String) -> Dictionary:
	return (entries_by_id.get(minigame_id, {}) as Dictionary).duplicate(true)


func get_all_entries() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for e in entries_ordered:
		out.append(e.duplicate(true))
	return out


func get_playable_entries() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for e in entries_ordered:
		var st := str(e.get("availability_status", ""))
		if st.begins_with("playable"):
			out.append(e.duplicate(true))
	return out


func get_entries_by_skill(skill: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for e in entries_ordered:
		var skills: Array = e.get("learning_skills", [])
		if skills.has(skill):
			out.append(e.duplicate(true))
	return out


func is_unlocked(minigame_id: String) -> bool:
	var e := get_entry(minigame_id)
	if e.is_empty():
		return false
	var status := str(e.get("availability_status", ""))
	if status == "planned_template":
		return false
	var cond: Dictionary = e.get("unlock_conditions", {})
	return UnlockEvaluator.is_condition_met(cond, GameStateManager.to_state_dict())
