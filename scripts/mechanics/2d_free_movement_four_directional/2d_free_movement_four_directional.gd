class_name FreeMovementFourDirectional2D
extends Node

@export var actions: Actions
@export var movementSpeed: Quantity
@export var body: CharacterBody2D

const walk = actions.Movement.WALK

var optionalRunConditions: Array[Callable]

var isInputBeingPressed: bool = false
var isVelocityAboveZero: bool = false

var action: InputActionBinding

func _ready() -> void:
	action = actions.movements[walk]

func _physics_process(_delta: float) -> void:
	# run the action with the implementation
	# and any supplied optional conditions that
	# may stop the action from running if true
	# for example: player hp <= 0, stunned, etc
	action.run(_implementation, optionalRunConditions)

func _implementation():
	var left = actions.directions[actions.Direction.LEFT].input
	var right = actions.directions[actions.Direction.RIGHT].input
	var up = actions.directions[actions.Direction.UP].input
	var down = actions.directions[actions.Direction.DOWN].input
	var movementDirection: Vector2 = Input.get_vector(left, right, up, down)
	isInputBeingPressed = movementDirection != Vector2.ZERO
	var velocity = movementDirection * movementSpeed.current
	isVelocityAboveZero = velocity.length() > 0
	body.velocity = velocity
	body.move_and_slide()
