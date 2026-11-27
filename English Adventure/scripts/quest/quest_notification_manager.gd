class_name QuestNotificationManager
extends RefCounted
## Emits non-blocking HUD notifications for quest availability, objective milestones, and completion.


static func notify_started(_quest_def: Dictionary) -> void:
	# UIManager already displays quest_started notifications via EventBus.quest_started.
	pass


static func notify_objective_updated(quest_def: Dictionary, step_def: Dictionary, obj_res: Dictionary) -> void:
	var cur := int(obj_res.get("current", 0))
	var tgt := int(obj_res.get("target", 1))
	var step_title := LocalizationManager.pick_text(step_def, "title")
	if tgt > 1:
		EventBus.toast_requested.emit("%s (%d/%d)" % [step_title, cur, tgt], "info")
	elif bool(obj_res.get("completed", false)):
		EventBus.toast_requested.emit("Hoàn thành bước: %s" % step_title, "info")


static func notify_completed(_quest_def: Dictionary) -> void:
	# UIManager already displays quest_completed notifications via EventBus.quest_completed.
	pass
