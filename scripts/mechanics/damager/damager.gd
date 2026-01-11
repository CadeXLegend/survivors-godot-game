class_name Damager
extends Node

@export var damage: Quantity
@export var useDamageNumbers: bool = true

signal pre_damage_step
signal post_damage_step

func deal_damage(amount: float, stat: Quantity, target: Node) -> void:
	pre_damage_step.emit()
	stat.remove(amount)
	if useDamageNumbers:
		game_state_responder.damageNumbers.display_number(
			amount, 
			target.global_position, 
			target)
	post_damage_step.emit()

func try_get_damageable(node: Node) -> Damageable:
	if not _is_damageable(node): return null
	return _find_damageable(node)

func _find_damageable(node: Node) -> Damageable:
	print("searching...")
	if _is_damageable(node): return node.get_script() as Damageable
	for child in node.get_children():
		if _is_damageable(child):
			print("yeah we found it")
			return child.get_script() as Damageable
	return null
	#var index = node.get_children().find(func(child: Node): return _is_damageable(child))
	#return node.get_child(index).get_script() as Damageable if index > -1 else null

func _is_damageable(node: Node) -> bool:
	return node.get_script() is Damageable
