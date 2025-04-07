extends Node2D

@onready var spawnPath: PathFollow2D = %OutOfViewSpawnPath
@onready var mob = preload("res://entities/npcs/SlimeMob.tscn")

func spawn_mob():
	var node = mob.instantiate()
	spawnPath.progress_ratio = randf()
	node.global_position = spawnPath.global_position
	get_parent().add_child(node)

func _on_timer_timeout() -> void:
	spawn_mob()
