extends Node2D
class_name BuddyController
## Companion Dragon (Buddy) that follows the player and expresses emotional states.

const STATE_TEXTURES := {
	"idle": "res://assets/characters/buddy_dragon/buddy_idle.svg",
	"happy": "res://assets/characters/buddy_dragon/buddy_happy.svg",
	"sad": "res://assets/characters/buddy_dragon/buddy_sad.svg",
	"surprised": "res://assets/characters/buddy_dragon/buddy_surprised.svg",
	"thinking": "res://assets/characters/buddy_dragon/buddy_thinking.svg",
	"talking": "res://assets/characters/buddy_dragon/buddy_talking.svg",
	"celebrating": "res://assets/characters/buddy_dragon/buddy_celebrating.svg"
}

@export var follow_offset: Vector2 = Vector2(-56, -24)
@export var follow_speed: float = 5.5

var current_state: String = "idle"
var target_player: Node2D = null
var _float_time: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	set_buddy_state("idle")
	EventBus.buddy_state_changed.connect(set_buddy_state)
	EventBus.quest_completed.connect(_on_quest_completed)
	EventBus.dialogue_started.connect(func(_id): set_buddy_state("talking"))
	EventBus.dialogue_ended.connect(func(_id, _evt): set_buddy_state("idle"))

func _process(delta: float) -> void:
	if target_player == null:
		target_player = get_tree().get_first_node_in_group("player") as Node2D
	if target_player != null:
		var target_pos := target_player.global_position + follow_offset
		global_position = global_position.lerp(target_pos, delta * follow_speed)
		if sprite != null:
			sprite.flip_h = target_player.global_position.x < global_position.x

	_float_time += delta * 3.5
	if sprite != null:
		sprite.position.y = sin(_float_time) * 6.0

func set_buddy_state(state_name: String) -> void:
	if not STATE_TEXTURES.has(state_name):
		state_name = "idle"
	current_state = state_name
	if sprite != null and ResourceLoader.exists(STATE_TEXTURES[state_name]):
		sprite.texture = load(STATE_TEXTURES[state_name])

func _on_quest_completed(_quest_id: String, _reward: Dictionary) -> void:
	set_buddy_state("celebrating")
