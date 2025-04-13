class_name CirclingOrb
extends Node2D

@export var stats: Stats

@onready var pivot: Marker2D = %Pivot
@onready var orb1: Node2D = %Orb1
@onready var orb2: Node2D = %Orb2
@onready var orb3: Node2D = %Orb3
@onready var orb4: Node2D = %Orb4

#func _ready() -> void:
	# disable all the orbs until they're being used
	# in this case, we will keep the first orb on by
	# default, because it will always be used first
	# when this ability is chosen and active
	#orb1.process_mode = Node.PROCESS_MODE_DISABLED
	#orb2.process_mode = Node.PROCESS_MODE_DISABLED
	#orb2.visible = false
	#orb3.process_mode = Node.PROCESS_MODE_DISABLED
	#orb3.visible = false
	#orb4.process_mode = Node.PROCESS_MODE_DISABLED
	#orb4.visible = false
	
func _physics_process(delta: float) -> void:
	pivot.rotate(PI * delta * stats.movementSpeed.current)

func _on_area_2d_body_entered(body: Node2D) -> void:	
	if body is Slime:
		var collision_point = body.global_position
		var direction = global_position.direction_to(collision_point)
		var explosion_force = direction * stats.knockbackStrength.current
		body.stats.knockback.set_to(explosion_force)
		stats.damager.deal_damage(stats.damage.current, body)
