class_name QuestObjectiveManager
extends RefCounted
## Evaluates all 12 Prompt 06 Quest Objective types with support for
## sequential, parallel, optional, repeatable, and hidden objectives.


static func init_objectives_state(quest_def: Dictionary) -> Dictionary:
	var objs := {}
	for step_var in quest_def.get("steps", []):
		if typeof(step_var) != TYPE_DICTIONARY:
			continue
		var st: Dictionary = step_var
		var sid := str(st.get("id", ""))
		if sid.is_empty():
			continue
		objs[sid] = {
			"current": 0,
			"target": maxi(1, int(st.get("required_count", 1))),
			"completed": false,
			"seen_items": []
		}
	return objs


static func get_eligible_indices(steps: Array, obj_map: Dictionary) -> Array[int]:
	var eligible: Array[int] = []
	var found_first_seq_block := false
	for i in range(steps.size()):
		if typeof(steps[i]) != TYPE_DICTIONARY:
			continue
		var st: Dictionary = steps[i]
		var sid := str(st.get("id", ""))
		var entry: Dictionary = obj_map.get(sid, {})
		var is_done := bool(entry.get("completed", false))
		var is_optional := bool(st.get("optional", false))
		var is_repeatable := bool(st.get("repeatable", false))
		var mode := str(st.get("mode", "sequential"))

		if is_optional:
			if not is_done or is_repeatable:
				eligible.append(i)
			continue

		if is_done and not is_repeatable:
			continue

		if not found_first_seq_block:
			found_first_seq_block = true
			eligible.append(i)
			if mode == "parallel":
				# Also unlock consecutive parallel steps right after i
				for j in range(i + 1, steps.size()):
					if typeof(steps[j]) != TYPE_DICTIONARY:
						continue
					var nxt: Dictionary = steps[j]
					if bool(nxt.get("optional", false)):
						continue
					if str(nxt.get("mode", "sequential")) == "parallel":
						var ns_id := str(nxt.get("id", ""))
						var n_done := bool((obj_map.get(ns_id, {}) as Dictionary).get("completed", false))
						if not n_done or bool(nxt.get("repeatable", false)):
							eligible.append(j)
					else:
						break
			break
	return eligible


static func process_event_on_quest(
	quest_def: Dictionary,
	progress: Dictionary,
	event_type: String,
	payload: Dictionary
) -> Dictionary:
	var steps: Array = quest_def.get("steps", [])
	var obj_map: Dictionary = progress.get("objectives", {})
	if obj_map.is_empty():
		obj_map = init_objectives_state(quest_def)
		progress["objectives"] = obj_map

	var eligible := get_eligible_indices(steps, obj_map)
	var updated_any := false
	var last_updated_step := {}

	for idx in eligible:
		var st: Dictionary = steps[idx]
		var sid := str(st.get("id", ""))
		var st_type := str(st.get("type", ""))
		var entry: Dictionary = obj_map.get(sid, { "current": 0, "target": maxi(1, int(st.get("required_count", 1))), "completed": false, "seen_items": [] })
		var target_n := int(entry.get("target", maxi(1, int(st.get("required_count", 1)))))
		var cur_n := int(entry.get("current", 0))
		var matched := false
		var unique_token := ""

		match st_type:
			"talk_to_npc", "return_to_npc":
				if event_type in ["talk_to_npc", "return_to_npc"] and str(st.get("target_id", "")) == str(payload.get("target_id", "")):
					matched = true
			"visit_area", "discover_location":
				if event_type in ["visit_area", "discover_location"] and str(st.get("target_id", "")) == str(payload.get("target_id", "")):
					matched = true
			"interact_object":
				if event_type == "interact_object" and str(st.get("target_id", "")) == str(payload.get("target_id", "")):
					matched = true
			"collect_tag":
				if event_type == "collect_tag" and str(st.get("target_tag", "")) == str(payload.get("tag", "")):
					unique_token = str(payload.get("target_id", ""))
					matched = true
			"collect_item":
				if event_type == "collect_item" and str(st.get("target_id", "")) == str(payload.get("target_id", "")):
					matched = true
			"complete_minigame", "minigame_completed":
				if event_type in ["complete_minigame", "minigame_completed"] and str(st.get("target_id", "")) == str(payload.get("target_id", "")):
					matched = true
			"learn_vocabulary":
				if event_type == "learn_vocabulary" and bool(payload.get("is_correct", false)):
					var kid := str(payload.get("knowledge_id", payload.get("target_id", "")))
					var req_id := str(st.get("target_id", "any"))
					if req_id == "any" or req_id == kid:
						unique_token = kid if not kid.is_empty() else str(Time.get_ticks_msec())
						matched = true
			"answer_questions_correctly":
				if event_type in ["answer_questions_correctly", "learn_vocabulary"] and bool(payload.get("is_correct", false)):
					matched = true
			"complete_learning_activity":
				if event_type == "complete_learning_activity":
					var req_act := str(st.get("target_id", "any"))
					if req_act == "any" or req_act == str(payload.get("target_id", "")):
						matched = true
			"reach_learning_mastery":
				if event_type in ["reach_learning_mastery", "learn_vocabulary"]:
					var req_m := str(st.get("target_id", "any"))
					var m_score := float(payload.get("mastery_score", 0.0))
					if m_score >= float(st.get("min_mastery", 70.0)) and (req_m == "any" or req_m == str(payload.get("knowledge_id", ""))):
						unique_token = str(payload.get("knowledge_id", ""))
						matched = true
			"open_new_area":
				if event_type == "open_new_area" and str(st.get("target_id", "")) == str(payload.get("target_id", "")):
					matched = true
			"defeat_boss", "seal_challenge":
				if event_type in ["defeat_boss", "seal_challenge"] and str(st.get("target_id", "")) == str(payload.get("target_id", "")):
					matched = true

		if matched:
			var seen: Array = entry.get("seen_items", [])
			if not unique_token.is_empty():
				if seen.has(unique_token):
					continue
				seen.append(unique_token)
				entry["seen_items"] = seen
			var inc := int(payload.get("increment", 1))
			cur_n = mini(target_n, cur_n + inc)
			entry["current"] = cur_n
			if cur_n >= target_n:
				entry["completed"] = true
			obj_map[sid] = entry
			progress["has_progress"] = true
			updated_any = true
			last_updated_step = {
				"objective_id": sid,
				"current": cur_n,
				"target": target_n,
				"completed": bool(entry["completed"])
			}

	progress["objectives"] = obj_map
	var first_incomplete := compute_first_incomplete_index(steps, obj_map)
	progress["step_index"] = first_incomplete
	var all_required_done := are_all_required_completed(steps, obj_map)

	return {
		"updated": updated_any,
		"all_required_completed": all_required_done,
		"step_index": first_incomplete,
		"last_objective": last_updated_step
	}


static func compute_first_incomplete_index(steps: Array, obj_map: Dictionary) -> int:
	for i in range(steps.size()):
		if typeof(steps[i]) != TYPE_DICTIONARY:
			continue
		var st: Dictionary = steps[i]
		if bool(st.get("optional", false)):
			continue
		var sid := str(st.get("id", ""))
		var entry: Dictionary = obj_map.get(sid, {})
		if not bool(entry.get("completed", false)):
			return i
	return steps.size()


static func are_all_required_completed(steps: Array, obj_map: Dictionary) -> bool:
	for step_var in steps:
		if typeof(step_var) != TYPE_DICTIONARY:
			continue
		var st: Dictionary = step_var
		if bool(st.get("optional", false)):
			continue
		var sid := str(st.get("id", ""))
		var entry: Dictionary = obj_map.get(sid, {})
		if not bool(entry.get("completed", false)):
			return false
	return true
