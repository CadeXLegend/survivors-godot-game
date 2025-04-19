extends AnimatedSprite2D

@export var speedOverDistance: float = 0.1

var isMagnetised: bool = false

func _ready() -> void:
	game_events_emitter.game_paused.connect(func(): game_state_responder.disable_self_and_physics(self))
	game_events_emitter.game_unpaused.connect(func(): game_state_responder.enable_self_and_physics(self))
	game_events_emitter.magnet_picked_up.connect(magnetise)
	play("default")

func _physics_process(delta: float) -> void:
	if !isMagnetised:
		return
	
	speedOverDistance += 0.1
	global_position = global_position.lerp(entity_tracker.player.global_position, 1 * delta * speedOverDistance)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		queue_free()
		body.stats.xp.add(25)

func magnetise():
	isMagnetised = true
