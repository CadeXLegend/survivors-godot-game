extends Node2D

@export var droptable: Droptable
@onready var player: Player = get_tree().get_first_node_in_group("Players")
@onready var currentScene = get_tree().current_scene

func _ready():
	game_events_emitter.game_paused.connect(func(): droptable.drop_at(player.global_position, currentScene))
