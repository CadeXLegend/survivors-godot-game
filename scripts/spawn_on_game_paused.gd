extends Node2D

@onready var droptable: Droptable = %Droptable
@export var gameEventsEmitter: GameEventsEmitter
@onready var player: Player = get_tree().get_first_node_in_group("Players")

func _ready():
	gameEventsEmitter.game_paused.connect(func(): droptable.drop_at(player.global_position))
