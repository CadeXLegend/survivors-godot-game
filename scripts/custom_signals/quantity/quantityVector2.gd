class_name QuantityVector2
extends Node2D

# these are arbitrary defaults to be set in the inspector
@export var minimum: Vector2 = Vector2.ZERO
@export var maximum: Vector2
@export var current: Vector2 = Vector2.ZERO

# these are the core events correlated to any given quantity
signal gained
signal lost
signal changed
signal none_left
signal full
signal maximum_increased
signal maximum_decreased

# these are the core functions used to control the quantity
# which then also correlate to the emitting of related events
func add(value: Vector2) -> void:
	current += value
	if current.length_squared() > maximum.length_squared():
		current = maximum
		full.emit()
	
	changed.emit()
	gained.emit()
	
func remove(value: Vector2) -> void:
	current -= value
	changed.emit()
	lost.emit()
	
	if current.length_squared() <= minimum.length_squared():
		current = minimum
		none_left.emit()
		
func set_to(value: Vector2) -> void:
	if value.length_squared() > current.length_squared():
		add(value)
	if value.length_squared() < current.length_squared():
		remove(value)

func increase_max(value: Vector2) -> void:
	maximum += value
	maximum_increased.emit()

func decrease_max(value: Vector2) -> void:
	maximum -= value
	maximum_decreased.emit()
