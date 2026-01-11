#class_name BouncerCapsule
#extends Node2D
#
#@export var stats: Stats
#@export var child: RigidBody2D
#@export var timer: Timer
#@export var damageTimer: Timer
#var direction: Vector2 = Vector2(0, 0)
#
#var isDisabled: bool = true
#var canTakeDamage: bool = true
#
#func _ready() -> void:
	#stats = stats.duplicate(true)
	#direction = Vector2(stats.movementSpeed.current, 0)
	#stats.health.none_left.connect(reset)
	#reset()
	#
#func reset():
	#stats.health.set_to(stats.health.maximum)
	#child.global_position = entity_tracker.player().global_position
	#isDisabled = true
	#game_state_responder.disable_self_and_physics(child)
	#timer.start()
#
#func _physics_process(delta: float) -> void:
	#if isDisabled:
		#return
	#
	#var point = direction * stats.movementSpeed.current * delta
	##child.angular_velocity = 45
	#child.rotate(45 * delta)
	#var collision = child.move_and_collide(point)
	##child.look_at(-point)
	#if collision:
		#if canTakeDamage:
			#stats.health.remove(1)
			#canTakeDamage = false
			#damageTimer.start()
		#choose_target()
#
#func choose_target():
	#var chosenEnemy = entity_tracker.find_nearest_enemy(self)
	#direction = child.global_position.direction_to(chosenEnemy.global_position)
#
#func _on_timer_timeout() -> void:
	#game_state_responder.enable_self_and_physics(child)
	#isDisabled = false
	#choose_target()
	#timer.stop()
#
#func _on_area_2d_body_entered(body: Node2D) -> void:
	#if body is Slime:
		#stats.damager.deal_damage(stats.damage.current, body.stats.health, body)
		#stats.xp.add(1)
#
#func _on_damage_timer_timeout() -> void:
	#canTakeDamage = true
	#damageTimer.stop()
