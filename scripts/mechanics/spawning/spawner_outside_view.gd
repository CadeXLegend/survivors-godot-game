extends Node2D

@onready var spawnPath: PathFollow2D = %OutOfViewSpawnPath
@export var mob: PackedScene
@onready var currentScene = get_tree().current_scene

func spawn_mob():
	spawnPath.progress_ratio = randf()
	game_state_responder.spawn(mob).at(spawnPath.global_position).as_child_of(currentScene).create()

func _on_timer_timeout() -> void:
	spawn_mob()
