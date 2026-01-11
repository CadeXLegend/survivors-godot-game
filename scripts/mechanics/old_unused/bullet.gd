#extends Area2D
#
#@export var maxTravelDistance: float = 1200.0
##@export var moveSpeed: 
#
#var travelledDistance: float = 0.0
#
#func _physics_process(delta: float) -> void:
	#var direction = Vector2.RIGHT.rotated(rotation)
	#position += direction * stats.movementSpeed.current * delta
	#
	#travelledDistance += stats.movementSpeed.current * delta
	#
	#if travelledDistance > maxTravelDistance:
		#if not is_queued_for_deletion():
			#queue_free()
#
#
#func _on_body_entered(body: Node2D) -> void:
	#queue_free()
#
	#if body is Slime:
		#stats.damager.deal_damage(stats.damage.current, body.stats.health, body)
