class_name MiniGameFactory
extends RefCounted
## Instantiates the concrete MiniGameController UI for any registered playable mini-game.
## New mini-games can register scripts here without changing MiniGameManager.

const CONTROLLERS := {
	"listen_and_find": "res://scripts/minigames/games/game_listen_and_find.gd",
	"word_builder": "res://scripts/minigames/games/game_word_builder.gd",
	"word_matching": "res://scripts/minigames/games/game_word_matching.gd",
	"sentence_builder": "res://scripts/minigames/games/game_sentence_builder.gd",
	"sound_detective": "res://scripts/minigames/games/game_sound_detective.gd",
	"speaking_hero": "res://scripts/minigames/games/game_speaking_hero.gd",
	"memory_quest": "res://scripts/minigames/games/game_memory_quest.gd",
	"dialogue_adventure": "res://scripts/minigames/games/game_dialogue_adventure.gd"
}


static func create_controller(minigame_id: String) -> MiniGameController:
	var script_path := str(CONTROLLERS.get(minigame_id, ""))
	if script_path.is_empty() or not ResourceLoader.exists(script_path):
		AppLogger.warn("MiniGameFactory", "No controller script found for: " + minigame_id)
		return null
	var scr: Variant = load(script_path)
	if scr is GDScript:
		var inst: Variant = (scr as GDScript).new()
		if inst is MiniGameController:
			return inst as MiniGameController
	return null
