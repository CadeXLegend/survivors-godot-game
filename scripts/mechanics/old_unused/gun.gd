extends Area2D

@onready var marker: Marker2D = %ShootingPoint
@export var bullet: PackedScene

func _physics_process(_delta: float) -> void:
	if entity_tracker.player().stats.health.current <= entity_tracker.player().stats.health.minimum:
		return
	
	look_at(get_global_mouse_position())

func shoot():
	game_state_responder.spawn(bullet) \
						.as_child_of(marker) \
						.at(marker.global_position) \
						.with_rotation(marker.global_rotation) \
						.create()

func _on_timer_timeout() -> void:
	shoot()
