extends Area2D

@export var damager: Damager

func _on_body_entered(node: Node2D) -> void:
	var damageable = damager.try_get_damageable(node)
	if damageable == null: return
	_execute_damage_step(damageable, node)

func _execute_damage_step(damageable: Damageable, node: Node2D) -> void:
	damager.deal_damage(damager.damage.current, damageable.health, node)
	queue_free()
