class_name DamageOnBodyEntered2D
extends Node

@export var area2d: Area2D
@export var damager: Damager

func _physics_process(delta: float) -> void:
	var nodes = area2d.get_overlapping_bodies()
	if nodes.size() <= 0: return
	
	var damageables = damager.try_get_damageables(nodes)
	print(damageables)
	if damageables.size() <= 0: return
	print(damageables)
	_execute_damage_step(damageables)


func _execute_damage_step(damageables: Array[Damageable]) -> void:
	for damageable in damageables:
		damager.deal_damage(damager.damage.current, damageable.health, damageable.target)
	if not is_queued_for_deletion():
		queue_free()
