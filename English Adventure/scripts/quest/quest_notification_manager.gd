class_name QuestNotificationManager
extends RefCounted
## Emits non-blocking HUD notifications for quest availability, objective milestones, and completion.


static func notify_started(quest_def: Dictionary) -> void:
	var title := LocalizationManager.pick_text(quest_def, "title")
	EventBus.toast_requested.emit("Nhiệm vụ mới: %s" % title, "quest")


static func notify_objective_updated(quest_def: Dictionary, step_def: Dictionary, obj_res: Dictionary) -> void:
	var cur := int(obj_res.get("current", 0))
	var tgt := int(obj_res.get("target", 1))
	var step_title := LocalizationManager.pick_text(step_def, "title")
	if tgt > 1:
		EventBus.toast_requested.emit("%s (%d/%d)" % [step_title, cur, tgt], "info")
	elif bool(obj_res.get("completed", false)):
		EventBus.toast_requested.emit("Hoàn thành bước: %s" % step_title, "info")


static func notify_completed(quest_def: Dictionary) -> void:
	var title := LocalizationManager.pick_text(quest_def, "title")
	EventBus.toast_requested.emit("Hoàn thành nhiệm vụ: %s!" % title, "quest")
