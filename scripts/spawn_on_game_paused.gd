extends Node2D

@export var droptable: Droptable
@onready var currentScene = get_tree().current_scene

func _ready():
	game_events_emitter.game_paused.connect(func(): droptable.drop_at(
		entity_tracker.player().global_position, currentScene))
