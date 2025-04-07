class_name CirclingOrb
extends Node2D

@onready var damager: Damager = %Damager
@onready var damage: Quantity = %Damage
@onready var movementSpeed: Quantity = %MovementSpeed
@onready var knockbackStrength: Quantity = %KnockbackStrength
@onready var pivot: Marker2D = %Pivot
@onready var orb: Node2D = %Orb

func _physics_process(delta: float) -> void:
	pivot.rotate(PI * delta * movementSpeed.current)

func _on_area_2d_body_entered(body: Node2D) -> void:	
	if body is Slime:
		var collision_point = body.global_position
		var orb_center = global_position
		var direction = orb_center.direction_to(collision_point)
		var explosion_force = direction * knockbackStrength.current
		body.knockback.set_to(explosion_force)
		damager.deal_damage(body.health, damage.current)
