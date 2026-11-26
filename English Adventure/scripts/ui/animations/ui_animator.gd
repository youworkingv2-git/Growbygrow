class_name UIAnimator
extends RefCounted
## Smooth UI animation utilities respecting SettingsManager.reduced_motion.


static func is_reduced() -> bool:
	return SettingsManager.reduced_motion


static func attach_button_feedback(btn: Button) -> void:
	if btn == null or btn.has_meta("ui_anim_attached"):
		return
	btn.set_meta("ui_anim_attached", true)
	btn.pivot_offset = btn.size * 0.5
	btn.resized.connect(func() -> void: btn.pivot_offset = btn.size * 0.5)
	btn.mouse_entered.connect(func() -> void:
		if btn.disabled or is_reduced():
			return
		var tw := btn.create_tween()
		tw.tween_property(btn, "scale", Vector2(1.03, 1.03), 0.08)
	)
	btn.mouse_exited.connect(func() -> void:
		if is_reduced():
			btn.scale = Vector2.ONE
			return
		var tw := btn.create_tween()
		tw.tween_property(btn, "scale", Vector2.ONE, 0.08)
	)
	btn.button_down.connect(func() -> void:
		if btn.disabled:
			return
		AudioManager.play_sfx("button_click")
		if is_reduced():
			return
		var tw := btn.create_tween()
		tw.tween_property(btn, "scale", Vector2(0.96, 0.96), 0.05)
	)
	btn.button_up.connect(func() -> void:
		if is_reduced():
			btn.scale = Vector2.ONE
			return
		var tw := btn.create_tween()
		tw.tween_property(btn, "scale", Vector2.ONE, 0.08)
	)


static func animate_popup_open(panel: Control) -> void:
	if panel == null:
		return
	panel.visible = true
	if is_reduced():
		panel.modulate.a = 1.0
		panel.scale = Vector2.ONE
		return
	panel.pivot_offset = panel.size * 0.5
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.92, 0.92)
	var tw := panel.create_tween().set_parallel(true)
	tw.tween_property(panel, "modulate:a", 1.0, 0.16)
	tw.tween_property(panel, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


static func animate_popup_close(panel: Control, on_finished: Callable = Callable()) -> void:
	if panel == null:
		return
	if is_reduced():
		panel.visible = false
		if on_finished.is_valid():
			on_finished.call()
		return
	panel.pivot_offset = panel.size * 0.5
	var tw := panel.create_tween().set_parallel(true)
	tw.tween_property(panel, "modulate:a", 0.0, 0.12)
	tw.tween_property(panel, "scale", Vector2(0.94, 0.94), 0.12)
	tw.finished.connect(func() -> void:
		panel.visible = false
		panel.modulate.a = 1.0
		panel.scale = Vector2.ONE
		if on_finished.is_valid():
			on_finished.call()
	)


static func animate_reward_pop(target: Control) -> void:
	if target == null or is_reduced():
		return
	target.pivot_offset = target.size * 0.5
	target.scale = Vector2(0.78, 0.78)
	var tw := target.create_tween()
	tw.tween_property(target, "scale", Vector2(1.08, 1.08), 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(target, "scale", Vector2.ONE, 0.12)


static func animate_pulse_once(target: Control) -> void:
	if target == null or is_reduced():
		return
	target.pivot_offset = target.size * 0.5
	var tw := target.create_tween()
	tw.tween_property(target, "scale", Vector2(1.06, 1.06), 0.11)
	tw.tween_property(target, "scale", Vector2.ONE, 0.13)
