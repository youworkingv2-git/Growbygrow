class_name InventoryManager
extends RefCounted
## Manages Player Inventory items, rich metadata, acquisition source,
## usage conditions (e.g. Golden Key only at Shadow Gate), and item activation.


static func get_enriched_items() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for item_id_var in GameStateManager.inventory.keys():
		var iid := str(item_id_var)
		var owned: Dictionary = GameStateManager.inventory[iid]
		var qty := int(owned.get("quantity", 0))
		if qty <= 0:
			continue
		var def: Dictionary = DataRepository.get_item_def(iid)
		var entry := {
			"id": iid,
			"name_vi": str(owned.get("name_vi", def.get("name_vi", iid))),
			"name_en": str(owned.get("name_en", def.get("name_en", iid))),
			"description_vi": str(def.get("description_vi", "Vật phẩm thám hiểm thu thập trên Đảo Chữ Cái.")),
			"item_type": str(def.get("item_type", owned.get("item_type", "collectible"))),
			"rarity": str(def.get("rarity", owned.get("rarity", "common"))),
			"icon_path": str(def.get("icon_path", _fallback_icon_path(iid))),
			"usable": bool(def.get("usable", false)),
			"acquisition_source_vi": str(def.get("acquisition_source_vi", owned.get("acquisition_source_vi", "Đảo Chữ Cái"))),
			"usage_conditions": (def.get("usage_conditions", {}) as Dictionary).duplicate(true),
			"use_effect": (def.get("use_effect", {}) as Dictionary).duplicate(true),
			"quantity": qty
		}
		out.append(entry)
	return out


static func can_use_item(item_id: String) -> Dictionary:
	var owned: Dictionary = GameStateManager.inventory.get(item_id, {})
	if int(owned.get("quantity", 0)) <= 0:
		return { "ok": false, "reason_vi": "Bạn không có vật phẩm này trong túi." }
	var def: Dictionary = DataRepository.get_item_def(item_id)
	if not bool(def.get("usable", false)):
		return { "ok": false, "reason_vi": "Vật phẩm này tự động kích hoạt khi hoàn thành điều kiện nhiệm vụ." }
	var cond: Dictionary = def.get("usage_conditions", {})
	var ctype := str(cond.get("type", "always"))
	match ctype:
		"always":
			return { "ok": true, "reason_vi": "" }
		"area_only":
			var req_area := str(cond.get("area_id", ""))
			if GameStateManager.current_area_id != req_area:
				return {
					"ok": false,
					"reason_vi": str(cond.get("reason_vi", "Chưa đứng đúng khu vực yêu cầu để sử dụng vật phẩm này!"))
				}
			return { "ok": true, "reason_vi": "" }
		_:
			return { "ok": false, "reason_vi": "Chưa đủ điều kiện để sử dụng vật phẩm này." }


static func use_item(item_id: String) -> Dictionary:
	var check := can_use_item(item_id)
	if not bool(check.get("ok", false)):
		var reason := str(check.get("reason_vi", "Không thể sử dụng lúc này."))
		EventBus.toast_requested.emit(reason, "warning")
		return { "used": false, "message_vi": reason }

	var def: Dictionary = DataRepository.get_item_def(item_id)
	var effect: Dictionary = def.get("use_effect", {})
	var etype := str(effect.get("type", "buddy_cheer"))
	var msg := str(effect.get("message_vi", "Đã kích hoạt vật phẩm!"))

	if etype == "set_flag":
		var flag_name := str(effect.get("flag", ""))
		if not flag_name.is_empty():
			GameStateManager.set_flag(flag_name, true)
	EventBus.buddy_state_changed.emit("celebrating", msg)
	EventBus.toast_requested.emit(msg, "info")
	EventBus.inventory_item_used.emit(item_id, { "area_id": GameStateManager.current_area_id })
	GameStateManager.save_now("use_item_" + item_id)
	return { "used": true, "message_vi": msg }


static func _fallback_icon_path(item_id: String) -> String:
	if item_id.contains("crystal"):
		return "res://assets/icons/crystal_icon.svg"
	if item_id.contains("letter"):
		return "res://assets/environments/alphabet_island/lost_letter_glow.svg"
	return "res://assets/icons/backpack_icon.svg"
