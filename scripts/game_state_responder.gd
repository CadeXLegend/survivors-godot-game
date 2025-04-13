class_name GameStateResponder
extends Node2D

func disable_self(ref: Node2D):
	ref.visible = false

func disable_self_and_physics(ref: Node2D):
	disable_self(ref)
	ref.process_mode = Node.PROCESS_MODE_DISABLED

func enable_self(ref: Node2D):
	ref.visible = true

func enable_self_and_physics(ref: Node2D):
	enable_self(ref)
	ref.process_mode = Node.PROCESS_MODE_INHERIT

func spawn(ref: PackedScene) -> Node2D:
	var node: Node2D = ref.instantiate()
	get_tree().current_scene.call_deferred("add_child", node)
	node.global_position = get_parent().global_position
	return node
	
func spawn_onto(ref: PackedScene, target: Node2D) -> Node2D:
	var node = ref.instantiate()
	target.call_deferred("add_child", node)
	node.global_position = target.global_position
	return node

func spawn_in_group(ref: PackedScene, group: String) -> Node2D:
	var node = spawn(ref)
	node.add_to_group(group)
	return node
	
func spawn_onto_in_group(ref: PackedScene, target: Node2D, group: String) -> Node2D:
	var node = spawn_onto(ref, target)
	node.add_to_group(group)
	return node
