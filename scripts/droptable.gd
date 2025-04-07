class_name Droptable

extends Node2D

@export var drops: Array[PackedScene]

func drop():
	for loot in drops:
		var node: Node2D = loot.instantiate()
		get_tree().current_scene.call_deferred("add_child", node)
		node.global_position = get_parent().global_position
