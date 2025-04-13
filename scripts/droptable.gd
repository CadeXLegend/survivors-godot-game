class_name Droptable
extends Node2D

@export var drops: Array[PackedScene]
@onready var currentScene = get_tree().current_scene

func drop_at(target: Vector2):
	for loot in drops:
		game_state_responder.spawn(loot).as_child_of(currentScene).at(target).create()

func drop_onto(target: Node2D):
	for loot in drops:
		game_state_responder.spawn(loot).as_child_of(target).create()

func drop_chosen_onto(target: Node2D, chosen: int):
		game_state_responder.spawn(drops[chosen]).as_child_of(target).create()

func drop_chosen_at(target: Vector2, chosen: int):
		game_state_responder.spawn(drops[chosen]).as_child_of(currentScene).at(target).create()
