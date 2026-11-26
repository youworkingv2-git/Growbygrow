extends Control
## Responsive touch/mouse Virtual Joystick emitting a normalized movement Vector2.

signal vector_changed(vec: Vector2)

@export var max_radius: float = 48.0

var _dragging: bool = false
var _touch_index: int = -1
var _output: Vector2 = Vector2.ZERO

@onready var knob: Control = $Knob


func _ready() -> void:
	_reset_knob()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		if st.pressed and _touch_index == -1:
			_touch_index = st.index
			_dragging = true
			_update_stick(st.position)
		elif not st.pressed and st.index == _touch_index:
			_touch_index = -1
			_dragging = false
			_reset_knob()
	elif event is InputEventScreenDrag:
		var sd := event as InputEventScreenDrag
		if _dragging and sd.index == _touch_index:
			_update_stick(sd.position)
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_dragging = true
				_update_stick(mb.position)
			else:
				_dragging = false
				_reset_knob()
	elif event is InputEventMouseMotion and _dragging:
		var mm := event as InputEventMouseMotion
		_update_stick(mm.position)


func _update_stick(local_pos: Vector2) -> void:
	var center := size * 0.5
	var delta := local_pos - center
	if delta.length() > max_radius:
		delta = delta.normalized() * max_radius
	knob.position = center + delta - knob.size * 0.5
	_output = delta / max_radius
	vector_changed.emit(_output)


func _reset_knob() -> void:
	var center := size * 0.5
	if knob != null:
		knob.position = center - knob.size * 0.5
	_output = Vector2.ZERO
	vector_changed.emit(_output)
