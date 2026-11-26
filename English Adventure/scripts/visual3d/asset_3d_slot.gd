class_name Asset3DSlot
extends Node3D
## Asset-swap wrapper for 3D entities & props:
## Loads official GLB/glTF model when present at `override_model_path`;
## otherwise instantiates the stylized 3D placeholder rig/prop cleanly.

@export var asset_id: String = ""
@export var override_model_path: String = ""
@export var is_placeholder: bool = true

var _content: Node3D = null


func attach_or_placeholder(placeholder_node: Node3D) -> Node3D:
	set_visual_node(placeholder_node, true)
	return _content


func set_visual_node(node: Node3D, placeholder_flag: bool = true) -> void:
	clear_visual()
	if not override_model_path.is_empty() and ResourceLoader.exists(override_model_path):
		var packed := load(override_model_path) as PackedScene
		if packed != null:
			var inst := packed.instantiate()
			if inst is Node3D:
				_content = inst as Node3D
				is_placeholder = false
				add_child(_content)
				return
	_content = node
	is_placeholder = placeholder_flag
	if _content != null:
		add_child(_content)


func get_visual_node() -> Node3D:
	return _content


func clear_visual() -> void:
	if _content != null and is_instance_valid(_content):
		_content.queue_free()
		_content = null
