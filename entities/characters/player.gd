class_name Player
extends CharacterBody2D

@export var directions: Array = ["move_left", "move_right", "move_up", "move_down"]
@export var damageRate: float = 5.0

@onready var health: Quantity = %Health
@onready var movementSpeed: Quantity = %MovementSpeed
@onready var xp: Quantity = %Experience
@onready var animationController = %HappyBoo
@onready var hitbox = %Hitbox
@onready var healthBar = %HealthBar

var level: int = 0

func _on_ready():
	healthBar.min_value = health.minimum
	healthBar.max_value = health.maximum

func _physics_process(delta: float) -> void:
	if health.current <= health.minimum:
		return
	
	var movementDirection = Input.get_vector(directions[0], directions[1], directions[2], directions[3])
	velocity = movementDirection * movementSpeed.current
	move_and_slide()
	
	if velocity.length() > 0:
		animationController.scale.x = 1 if velocity.x > 0 else -1
		animationController.play_walk_animation()
	else:
		animationController.play_idle_animation()
		
	var overlappingMobs = hitbox.get_overlapping_bodies()
	var amountOfMobsHittingPlayer: int = overlappingMobs.size() if overlappingMobs else 0
	
	if amountOfMobsHittingPlayer > 0:
		health.remove(damageRate * amountOfMobsHittingPlayer * delta)

func _on_experience_full() -> void:
	level += 1
	movementSpeed.add(200)
	xp.remove(xp.maximum)
	xp.increase_max(level * 100 * 1.25)

func _on_health_none_left() -> void:
	animationController.play_death_animation()

func _on_health_changed() -> void:
	healthBar.value = health.current
