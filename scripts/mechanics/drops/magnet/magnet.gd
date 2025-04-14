extends AnimatedSprite2D

func _ready() -> void:
	game_events_emitter.game_paused.connect(func(): game_state_responder.disable_self_and_physics(self))
	game_events_emitter.game_unpaused.connect(func(): game_state_responder.enable_self_and_physics(self))
	play("default")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		queue_free()
		game_events_emitter.emit_magnet_picked_up()
