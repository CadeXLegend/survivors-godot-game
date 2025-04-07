class_name Damager
extends Node2D

signal pre_damage_step
signal post_damage_step

# deal damage to a target where
# target is a given quantity observable
func deal_damage(target: Quantity, amount: float) -> void:
	pre_damage_step.emit()
	target.remove(amount)
	post_damage_step.emit()
