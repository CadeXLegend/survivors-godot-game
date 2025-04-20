class_name Quantity
extends Resource

# these are arbitrary defaults to be set in the inspector
@export var minimum: float = 0.0
@export var maximum: float = 0.0
@export var current: float = 0.0
# an optional parameter that allows for the overflow diff from maximum
# to be stored and used later, very useful!
var overflow: float = 0.0

# these are the core events correlated to any given quantity
signal gained
signal lost
signal modified
signal none_left
signal full
signal maximum_increased
signal maximum_decreased
signal overflow_cleared
signal overflow_added

# these are the core functions used to control the quantity
# which then also correlate to the emitting of related events
func add(value: float, storeOverflow: bool = false) -> void:
	if value <= 0:
		return

	var tenative_value = current + value
	
	if tenative_value == maximum:
		current = tenative_value
		full.emit()

	if tenative_value > maximum:
		if storeOverflow:
			overflow = tenative_value - maximum
			overflow_added.emit()
		tenative_value = maximum
		full.emit()

	current = tenative_value
	modified.emit()
	gained.emit()

func remove(value: float) -> void:
	if value <= 0:
		return

	current -= value
	modified.emit()
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

func add_from_overflow() -> void:
	if overflow <= 0:
		return

	if overflow <= maximum:
		add(overflow)
		clear_overflow()
	if overflow > maximum:
		add(overflow, true)

func clear_overflow() -> void:
	overflow = 0
	overflow_cleared.emit()
