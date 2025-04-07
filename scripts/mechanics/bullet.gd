extends Area2D

@export var movementSpeed: int = 800
@export var maxTravelDistance: float = 1200.0

var travelledDistance: float = 0.0

func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * movementSpeed * delta
	
	travelledDistance += movementSpeed * delta
	
	if travelledDistance > maxTravelDistance:
		if not is_queued_for_deletion():
			queue_free()


func _on_body_entered(body: Node2D) -> void:
	queue_free()

	if body.has_method("take_damage"):
		body.take_damage(1)
