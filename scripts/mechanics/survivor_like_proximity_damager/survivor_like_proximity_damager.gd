class_name SurvivorLikeProximityDamager
extends Node

@export var hitbox: Area2D
@export var recipientNode: Node2D
@export var damageable: Damageable

func _physics_process(_delta: float) -> void:
	var nodes = hitbox.get_overlapping_bodies().filter(func(node: Node2D): return node.is_in_group("Mobs"))
	if nodes.size() == 0: return
	_execute_damage_step(nodes)

func _execute_damage_step(nodes: Array[Node2D]) -> void:
	var damagers = damageable.try_get_damagers_2d(nodes)
	for damager in damagers:
		damager.deal_damage(damager.damage.current, damageable.health, recipientNode)
