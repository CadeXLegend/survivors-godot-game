extends Area2D

@onready var marker: Marker2D = %ShootingPoint
@export var bullet: PackedScene
var enemiesInRange = []

func _physics_process(_delta: float) -> void:
	enemiesInRange = get_overlapping_bodies()

	if enemiesInRange.size() > 0:
		var targetEnemy = enemiesInRange[0]
		look_at(targetEnemy.global_position)

func shoot():
	game_state_responder.spawn(bullet) \
						.as_child_of(marker) \
						.at(marker.global_position) \
						.with_rotation(marker.global_rotation) \
						.create()

func _on_timer_timeout() -> void:
	if enemiesInRange.size() > 0:
		shoot()
