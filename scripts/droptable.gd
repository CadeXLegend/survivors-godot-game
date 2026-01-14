class_name Droptable
extends Resource

@export var drops: Array[PackedScene]

func drop(parent: Node):
	for loot in drops:
		game_state_responder.spawn(loot).as_child_of(parent).create()

func drop_at(position: Vector2, parent: Node):
	for loot in drops:
		game_state_responder.spawn(loot).as_child_of(parent).at(position).create()

func drop_at_3d(position: Vector3, parent: Node):
	for loot in drops:
		game_state_responder.spawn(loot).as_child_of(parent).at_3d(position).create()

func drop_chosen(chosen: int, parent: Node):
		game_state_responder.spawn(drops[chosen]).as_child_of(parent).create()

func drop_chosen_at(position: Vector2, chosen: int, parent: Node):
		game_state_responder.spawn(drops[chosen]).as_child_of(parent).at(position).create()

func drop_chosen_at_3d(position: Vector3, chosen: int, parent: Node):
		game_state_responder.spawn(drops[chosen]).as_child_of(parent).at_3d(position).create()
