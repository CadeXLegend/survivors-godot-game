extends AnimatedSprite2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if(body is Player):
		queue_free()
		body.xp.add(25)
