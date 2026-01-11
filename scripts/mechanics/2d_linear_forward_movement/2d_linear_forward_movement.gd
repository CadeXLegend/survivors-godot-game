class_name LinearForwardMovement2D
extends Node

@export var movementSpeed: Quantity
@export var withCleanup: bool = false
@export var terminateAtDistance: TerminateAtDistance
@export var damager: Damager

@export var area2d: Area2D

func _physics_process(delta: float) -> void:
	if withCleanup:
		if area2d.get_overlapping_bodies().size() > 0 and not area2d.is_queued_for_deletion():
			area2d.queue_free()
	
	var direction = Vector2.RIGHT.rotated(area2d.rotation)
	area2d.position += direction * movementSpeed.current * delta
	terminateAtDistance.distance.add(movementSpeed.current * delta)
