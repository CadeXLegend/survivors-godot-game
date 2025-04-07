extends Area2D

@onready var marker: Marker2D = %ShootingPoint
@onready var bullet = preload("res://scripts/mechanics/Bullet.tscn")
var enemiesInRange = []

func _physics_process(_delta: float) -> void:
	enemiesInRange = get_overlapping_bodies()
	
	if enemiesInRange.size() > 0:
		var targetEnemy: CharacterBody2D = enemiesInRange[0]
		look_at(targetEnemy.global_position)

func shoot():
	var newBullet = bullet.instantiate()
	newBullet.global_position = marker.global_position
	newBullet.global_rotation = marker.global_rotation
	marker.add_child(newBullet)


func _on_timer_timeout() -> void:
	if enemiesInRange.size() > 0:
		shoot()
