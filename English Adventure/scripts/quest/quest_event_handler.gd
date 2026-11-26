class_name QuestEventHandler
extends RefCounted
## Deduplicates and translates EventBus events into QuestObjectiveManager updates.

var _recent_event_keys: Array[String] = []


func is_duplicate_event(dedup_key: String) -> bool:
	if dedup_key.is_empty():
		return false
	if _recent_event_keys.has(dedup_key):
		return true
	_recent_event_keys.append(dedup_key)
	if _recent_event_keys.size() > 64:
		_recent_event_keys.remove_at(0)
	return false
