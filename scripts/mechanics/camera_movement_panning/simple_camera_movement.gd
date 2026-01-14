class_name SimpleCameraMovement
extends Node

@export var node: Node
@export var actions: Actions
@export var movementSpeed: Quantity
var acceleration: float = 0.0

var optionalRunConditions: Array[Callable]
var action: InputActionBinding

func _physics_process(_delta: float) -> void:
	_implementation(_delta)

func _implementation(_delta: float):
	if Input.is_key_pressed(KEY_SHIFT):
		acceleration = movementSpeed.current * 0.06
	else:
		acceleration = 0.0
	
	var left = actions.directions[actions.Direction.LEFT].input
	var right = actions.directions[actions.Direction.RIGHT].input
	var up = actions.directions[actions.Direction.UP].input
	var down = actions.directions[actions.Direction.DOWN].input
	var inputVectors: Vector2 = Input.get_vector(left, right, up, down)
	if inputVectors.x == 0:
		inputVectors.x = node.position.x
	else:
		inputVectors.x += node.position.x
	if inputVectors.y == 0:
		inputVectors.y = node.position.z
	else:
		inputVectors.y += node.position.z
	
	var y = node.position.y
	
	if Input.is_key_pressed(KEY_Q):
		y = node.position.y - 1
	if Input.is_key_pressed(KEY_E):
		y = node.position.y + 1
	
	var movementDirection: Vector3 = Vector3(inputVectors.x, y, inputVectors.y)
	node.position = lerp(node.position, movementDirection, _delta * movementSpeed.current + acceleration)
