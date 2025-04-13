extends Node2D

@onready var gameEventsEmitter: GameEventsEmitter = get_tree().get_first_node_in_group("GameEvents")
@onready var abilitiesDroptable: Droptable = get_tree().get_first_node_in_group("GameDroptables")
@onready var player: Player = get_tree().get_first_node_in_group("Players")

var gameStateResponder: GameStateResponder = GameStateResponder.new()

func _ready():
	gameEventsEmitter.game_paused.connect(func(): gameStateResponder.enable_self_and_physics(self))
	gameEventsEmitter.game_unpaused.connect(func(): gameStateResponder.disable_self_and_physics(self))

func _on_option_1_body_entered(body: Node2D) -> void:
	abilitiesDroptable.drop_chosen_onto(player, 0)
	gameEventsEmitter.unpause_game()

func _on_option_2_body_entered(body: Node2D) -> void:
	abilitiesDroptable.drop_chosen_onto(player, 0)
	gameEventsEmitter.unpause_game()


func _on_option_3_body_entered(body: Node2D) -> void:
	abilitiesDroptable.drop_chosen_onto(player, 0)
	gameEventsEmitter.unpause_game()
