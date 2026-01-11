#class_name CirclingOrb
#extends Node2D
#
#@export var stats: Stats
#@export var pivots: Array[Marker2D]
#@export var orbs: Array[Node2D]
#
#func _ready() -> void:
	#stats = stats.duplicate(true)
	#
	## we start with only 1 orb
	## then gain more over time
	#for orb in orbs:
		#game_state_responder.disable_self_and_physics(orb)
#
	#update_orbs_amount()
	#stats.level.modified.connect(update_orbs_amount)
	#stats.xp.full.connect(on_experience_full)
	##stats.radius.modified.connect(update_orbs_radius)
#
##func update_orbs_radius():
	##orbs.all(func(orb): orb.position.x += stats.radius.current)
	#
#func _physics_process(delta: float) -> void:
	#for pivot in pivots:
		#pivot.rotate(PI * delta * stats.movementSpeed.current)
#
#func _on_area_2d_body_entered(body: Node2D) -> void:
	#if body is Slime:
		#var collision_point = body.global_position
		#var direction = global_position.direction_to(collision_point)
		#var explosion_force = direction * stats.knockbackStrength.current + body.stats.knockback.current
		#body.stats.knockback.set_to(explosion_force)
		#stats.damager.deal_damage(stats.damage.current, body.stats.health, body)
		#stats.xp.add(1)
#
#func update_orbs_amount():
	#game_state_responder.enable_self_and_physics(orbs[stats.level.current])
#
#func on_experience_full():
	#stats.level.add(1)
	#stats.xp.increase_max(stats.level.current * 2)
	#stats.xp.remove(stats.xp.maximum)
