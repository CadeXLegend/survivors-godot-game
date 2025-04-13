extends Node2D

@onready var gameEventsEmitter: GameEventsEmitter = get_tree().get_first_node_in_group("GameEvents")
@onready var abilitiesDroptable: Droptable = get_tree().get_first_node_in_group("GameDroptables")
@onready var player: Player = get_tree().get_first_node_in_group("Players")

var gameStateResponder: GameStateResponder = GameStateResponder.new()
var inOption1: bool = false
var inOption2: bool = false
var inOption3: bool = false

func _ready():
	gameEventsEmitter.game_unpaused.connect(func(): queue_free())
	
func _physics_process(_delta: float) -> void:
	if inOption1 || inOption2 || inOption3:
		choose_option()

func choose_option():
	if Input.is_action_pressed("interact"):
		abilitiesDroptable.drop_chosen_onto(player, 0)
		gameEventsEmitter.unpause_game()

func _on_option_1_body_entered(body: Node2D) -> void:
	inOption1 = true
	choose_option()

func _on_option_2_body_entered(body: Node2D) -> void:
	inOption2 = true
	choose_option()

func _on_option_3_body_entered(body: Node2D) -> void:
	inOption3 = true
	choose_option()

func _on_option_1_body_exited(body: Node2D) -> void:
	inOption1 = false

func _on_option_2_body_exited(body: Node2D) -> void:
	inOption2 = false

func _on_option_3_body_exited(body: Node2D) -> void:
	inOption3 = false
