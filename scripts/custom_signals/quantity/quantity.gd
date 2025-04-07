class_name Quantity
extends Node2D

# these are arbitrary defaults to be set in the inspector
@export var minimum: float = 0
@export var maximum: float
@export var current: float = 0.0

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
func add(value: float) -> void:
	current += value
	if current > maximum:
		current = maximum
		full.emit()
	
	changed.emit()
	gained.emit()
	
func remove(value: float) -> void:
	current -= value
	changed.emit()
	lost.emit()
	
	if current <= minimum:
		current = minimum
		none_left.emit()
		
func set_to(value: float) -> void:
	if value > current:
		add(value)
	if value < current:
		remove(value)

func increase_max(value: float) -> void:
	maximum += value
	maximum_increased.emit()

func decrease_max(value: float) -> void:
	maximum -= value
	maximum_decreased.emit()
