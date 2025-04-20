class_name InfiniteTilingSet
extends Node2D

func _ready() -> void:
	global_position = entity_tracker.player().global_position

func _physics_process(delta: float) -> void:
	if entity_tracker.player().global_position.distance_squared_to(global_position) > 200000:
		global_position = global_position.slerp(entity_tracker.player().global_position, delta * 6)
