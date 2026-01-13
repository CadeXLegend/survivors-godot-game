#class_name Summoned_Skeleton
#extends CharacterBody2D
#
##@onready var health: Quantity = %Health
##@onready var movementSpeed: Quantity = %MovementSpeed
#@onready var animationController = %AnimationController
#@onready var enemyDetector = %EnemyDetector
#
#var target: CharacterBody2D
#var closestEnemy
#
#var maxHitTimer: float = 0.2
#var hitTimer: float = maxHitTimer
#
#signal is_ready
#
#func _ready() -> void:
	#is_ready.emit()
#
#func _physics_process(delta: float) -> void:
	#hitTimer += delta
		#
	#if !is_instance_valid(target):
		#target = entity_tracker.player
	#
	#if target == entity_tracker.player:
		#var distance_from_player = global_position.distance_to(entity_tracker.player.global_position)
		#if distance_from_player < 90.0:
			#return
	#
	#var direction: Vector2 = global_position.direction_to(target.global_position)
	#animationController.scale.x = -1 if direction.x > position.x else 1
	##velocity = direction * movementSpeed.current
	#move_and_slide()
#
#func _find_nearest(targets: Array) -> CharacterBody2D:
	#var nearest = null
	#var min_distance = INF
	#for body in targets:
		#var distance = global_position.distance_to(body.global_position)
		#if distance < min_distance:
			#min_distance = distance
			#nearest = body
	#return nearest
#
#func _on_personal_space_body_entered(body: Node2D) -> void:
	#if is_instance_valid(body) and body.has_method("take_damage"):
		#if hitTimer <= maxHitTimer:
			#return
		#hitTimer = 0
		#body.take_damage(2)
		#animationController.play("default")
		##health.remove(1)
#
#func _on_enemy_detector_body_entered(body: Node2D) -> void:
	#var enemiesInRange = enemyDetector.get_overlapping_bodies().filter(
		#func(body): return is_instance_valid(body) and body.is_inside_tree()
	#)
#
	#if !is_instance_valid(target) || !target.is_inside_tree():
		#target = null
	#
	#if enemiesInRange.size() > 0:
		#target = _find_nearest(enemiesInRange)
	#else:
		#target = entity_tracker.player
#
#func _on_health_none_left() -> void:
	#queue_free()
