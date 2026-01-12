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

func try_get_damageables(nodes: Array[Node2D]) -> Array[Damageable]:
	var damageables: Array[Damageable] = []
	damageables.assign((nodes
	.map(func(node: Node): return try_get_damageable(node))
	.filter(func(damageable: Damageable): return damageable != null)))
	return damageables

func try_get_damageable(node: Node) -> Damageable:
	if _is_damageable(node): return node as Damageable
	for child in node.get_children():
		if _is_damageable(child):
			return child as Damageable
	return null

func _is_damageable(node: Node) -> bool:
	return node is Damageable
