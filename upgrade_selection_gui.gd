extends Node2D

@export var skills_tree: Skill_Tree
@export var options: Array[OptionGUI]

var chosenSkills: Array[Skill]

var current_option: int = 0

var rng = RandomNumberGenerator.new()

func _ready():
	game_events_emitter.game_unpaused.connect(func(): queue_free())
	chosenSkills = [
		skills_tree.skills.pick_random(), 
		skills_tree.skills.pick_random(), 
		skills_tree.skills.pick_random()
	]
	for i in 3:
		options[i].update_text(chosenSkills[i].name, chosenSkills[i].description)
	
func _physics_process(_delta: float) -> void:
	if current_option > 0:
		choose_option()

func choose_option():
	if Input.is_action_pressed("interact"):
		var entity = chosenSkills[current_option - 1].entity
		game_state_responder.spawn(entity).as_child_of(entity_tracker.player()).create()
		game_events_emitter.unpause_game()

func _on_option_1_body_entered(_body: Node2D) -> void:
	current_option = 1
	choose_option()

func _on_option_2_body_entered(_body: Node2D) -> void:
	current_option = 2
	choose_option()

func _on_option_3_body_entered(_body: Node2D) -> void:
	current_option = 3
	choose_option()

func _on_option_1_body_exited(_body: Node2D) -> void:
	current_option = 0

func _on_option_2_body_exited(_body: Node2D) -> void:
	current_option = 0

func _on_option_3_body_exited(_body: Node2D) -> void:
	current_option = 0
