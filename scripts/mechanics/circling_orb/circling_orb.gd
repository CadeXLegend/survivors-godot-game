class_name CirclingOrb
extends Node2D

@export var stats: Stats

#@export var orbCurve: Curve

@onready var pivot: Marker2D = %Pivot
@onready var orb1: Node2D = %Orb1
@onready var orb2: Node2D = %Orb2
@onready var orb3: Node2D = %Orb3
@onready var orb4: Node2D = %Orb4

func _ready() -> void:
	# we start with only 1 orb
	# then gain more over time
	game_state_responder.disable_self_and_physics(orb2)
	game_state_responder.disable_self_and_physics(orb3)
	game_state_responder.disable_self_and_physics(orb4)
	stats.radius.modified.connect(update_orbs_radius)

func update_orbs_amount():
	if stats.orbsCount.current == 2:
		game_state_responder.enable_self_and_physics(orb2)
	if stats.orbsCount.current == 3:
		game_state_responder.enable_self_and_physics(orb3)
	if stats.orbsCount.current == 4:
		game_state_responder.enable_self_and_physics(orb4)

func update_orbs_radius():
	orb1.position.x = stats.radius.current
	orb2.position.x = -stats.radius.current
	orb3.position.y = stats.radius.current
	orb4.position.y = -stats.radius.current
	
func _physics_process(delta: float) -> void:
	pivot.rotate(PI * delta * stats.movementSpeed.current)

func _on_area_2d_body_entered(body: Node2D) -> void:	
	if body is Slime:
		var collision_point = body.global_position
		var direction = global_position.direction_to(collision_point)
		var explosion_force = direction * stats.knockbackStrength.current + body.stats.knockback.current
		body.stats.knockback.set_to(explosion_force)
		stats.damager.deal_damage(stats.damage.current, body)
