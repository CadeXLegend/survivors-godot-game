class_name Damager
extends Resource

signal pre_damage_step
signal post_damage_step

# deal damage to a target where
# target is a given quantity observable
func deal_damage(amount: float, receiver: Node2D) -> void:
	pre_damage_step.emit()
	receiver.stats.health.remove(amount)
	game_state_responder.damageNumbers.display_number(
		amount, 
		receiver.global_position, 
		receiver)
	post_damage_step.emit()
