class_name InputActionBinding
extends Resource

@export var input: StringName

signal onActionBegin
signal onActionEnd

func run(action: Callable, optionalRunConditions: Array[Callable] = []):
	if !_doOptionalRunConditionsPass(optionalRunConditions): return
	onActionBegin.emit()
	action.call()
	onActionEnd.emit()

func _doOptionalRunConditionsPass(optionalRunConditions: Array[Callable] = []) -> bool:
	if optionalRunConditions.is_empty(): return true
	
	return (optionalRunConditions
				.map(func(condition): return condition.call())
				.any(func(result): return result is bool and result))
