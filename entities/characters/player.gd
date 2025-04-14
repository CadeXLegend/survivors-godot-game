class_name Player
extends CharacterBody2D

@export var directions: Array = ["move_left", "move_right", "move_up", "move_down"]
@export var damageRate: float = 5.0

@export var stats: Stats

@onready var animationController: Node2D = %HappyBoo
@onready var hitbox: Area2D = %Hitbox
@onready var healthBar: ProgressBar = %HealthBar
@onready var xpBar: ProgressBar = %XPBar
@onready var levelLabel: Label = %LevelLabel

func _ready():
	stats = stats.duplicate(true)
	stats.health.none_left.connect(on_health_none_left)
	stats.health.modified.connect(on_health_changed)
	stats.xp.full.connect(on_experience_full)
	stats.xp.maximum_increased.connect(func(): xpBar.max_value = stats.xp.maximum)
	stats.xp.modified.connect(update_xp_bar)
	stats.level.modified.connect(func(): levelLabel.text = str(stats.level.current as int))
	xpBar.value = stats.xp.current
	xpBar.min_value = stats.xp.minimum
	xpBar.max_value = stats.xp.maximum
	healthBar.min_value = stats.health.minimum
	healthBar.max_value = stats.health.maximum
	stats.health.maximum_decreased.connect(func(): healthBar.max_value = stats.health.maximum)
	stats.health.maximum_increased.connect(func(): healthBar.max_value = stats.health.maximum)
	game_events_emitter.game_unpaused.connect(on_unpause_after_lvl_up)

func _physics_process(delta: float) -> void:
	if stats.health.current <= stats.health.minimum:
		return
	
	var movementDirection = Input.get_vector(directions[0], directions[1], directions[2], directions[3])
	velocity = movementDirection * stats.movementSpeed.current
	move_and_slide()
	
	if velocity.length() > 0 and movementDirection != Vector2.ZERO:
		animationController.scale.x = 1 if velocity.x > 0 else -1
		animationController.play_walk_animation()
	else:
		animationController.play_idle_animation()
		
	var overlappingMobs = hitbox.get_overlapping_bodies()
	var amountOfMobsHittingPlayer: int = overlappingMobs.size() if overlappingMobs else 0
	
	if amountOfMobsHittingPlayer > 0:
		stats.damager.deal_damage(damageRate * amountOfMobsHittingPlayer, self)

func on_experience_full() -> void:
	stats.level.add(1)
	stats.health.set_to(stats.health.maximum)
	game_events_emitter.pause_game()

func on_unpause_after_lvl_up():
	stats.xp.increase_max(stats.level.current * 100 * 1.25)
	stats.xp.remove(stats.xp.maximum)

func on_health_none_left() -> void:
	animationController.play_death_animation()
	await get_tree().create_timer(1).timeout
	get_tree().reload_current_scene()

func on_health_changed() -> void:
	healthBar.value = stats.health.current
	
func update_xp_bar():
	xpBar.value = stats.xp.current
