extends Node
## Shared Interaction Manager.
## Tracks nearby interactables and dispatches unified interaction triggers.

var current_interactables: Array[Node] = []
var active_target: Node = null

func register_nearby(node: Node) -> void:
	if not (node in current_interactables):
		current_interactables.append(node)
	_update_active_target()

func unregister_nearby(node: Node) -> void:
	current_interactables.erase(node)
	if active_target == node:
		active_target = null
		EventBus.interactable_left.emit(node)
	_update_active_target()

func _update_active_target() -> void:
	# Clean up freed nodes
	current_interactables = current_interactables.filter(func(n): return is_instance_valid(n))
	if current_interactables.is_empty():
		active_target = null
		return
	active_target = current_interactables[-1]
	EventBus.interactable_nearby.emit(active_target)

func trigger_current() -> void:
	if DialogueManager.is_active:
		return
	if is_instance_valid(active_target) and active_target.has_method("interact"):
		active_target.interact()
