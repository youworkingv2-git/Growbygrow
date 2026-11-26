class_name QuestInstance
extends RefCounted
## Runtime view of a single Quest including status, objectives progress, and rewards.

var quest_id: String = ""
var definition: Dictionary = {}
var status: String = "locked" # locked | available | accepted | in_progress | completed | claimed
var current_step_index: int = 0
var objectives_state: Dictionary = {}


func _init(qid: String, def: Dictionary, st: String, step_idx: int, obj_state: Dictionary) -> void:
	quest_id = qid
	definition = def
	status = st
	current_step_index = step_idx
	objectives_state = obj_state
