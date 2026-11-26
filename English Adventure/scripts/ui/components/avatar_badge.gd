class_name AvatarBadge
extends RefCounted
## Shared helper for populating Character Avatar and NPC Avatar widgets cleanly.

const PORTRAIT_MAP := {
	"boy": "res://assets/characters/player/boy/boy_adventurer.svg",
	"girl": "res://assets/characters/player/girl/girl_adventurer.svg",
	"buddy": "res://assets/characters/buddy/buddy_dragon.svg",
	"professor_owl": "res://assets/characters/npcs/professor_owl.svg",
	"lily": "res://assets/characters/npcs/lily.svg",
	"rocky": "res://assets/characters/npcs/rocky.svg",
	"crystal_guardian": "res://assets/characters/npcs/crystal_guardian.svg"
}


static func get_character_texture(gender: String) -> Texture2D:
	var cfg := DataRepository.get_character_config(gender)
	var path := str(cfg.get("sprite_path", PORTRAIT_MAP.get(gender, PORTRAIT_MAP["boy"])))
	if ResourceLoader.exists(path):
		return load(path)
	return load(PORTRAIT_MAP["boy"])


static func get_npc_texture(npc_id: String) -> Texture2D:
	if npc_id == "buddy":
		return load(PORTRAIT_MAP["buddy"])
	var npc_cfg: Dictionary = DataRepository.npcs_by_id.get(npc_id, {})
	var path := str(npc_cfg.get("sprite_path", PORTRAIT_MAP.get(npc_id, PORTRAIT_MAP["buddy"])))
	if ResourceLoader.exists(path):
		return load(path)
	return load(PORTRAIT_MAP["buddy"])
