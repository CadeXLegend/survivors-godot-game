class_name Player
extends CharacterBody2D

@export var stats: Stats

@export var animationController: PlayerAnimationController
@export var healthBar: ProgressBar
@export var xpBar: ProgressBar
@export var levelLabel: Label

@export var movementMechanic: FreeMovementFourDirectional2D
@export var damageable: Damageable

func _ready():
	# to migrate all this out to other scripts
	# it doesn't make sense nor need to be here anymore
	# eventually this script won't even exist I guess?
	stats = stats.duplicate(true)
	damageable.health.none_left.connect(_on_health_none_left)
	damageable.health.modified.connect(_on_health_changed)
	stats.xp.full.connect(_on_experience_full)
	stats.xp.maximum_increased.connect(func(): xpBar.max_value = stats.xp.maximum)
	stats.xp.modified.connect(_on_xp_modified)
	stats.level.modified.connect(func(): levelLabel.text = str(stats.level.current as int))
	xpBar.value = stats.xp.current
	xpBar.min_value = stats.xp.minimum
	xpBar.max_value = stats.xp.maximum
	healthBar.min_value = damageable.health.minimum
	healthBar.max_value = damageable.health.maximum
	healthBar.value = damageable.health.current
	damageable.health.maximum_decreased.connect(func(): healthBar.max_value = damageable.health.maximum)
	damageable.health.maximum_increased.connect(func(): healthBar.max_value = damageable.health.maximum)
	game_events_emitter.game_unpaused.connect(_on_unpause_after_lvl_up)
	movementMechanic.action.onActionEnd.connect(_on_movement_ended)
	movementMechanic.optionalRunConditions = [_is_health_above_min]

func _is_health_above_min() -> bool: return damageable.health.at_minimum

func _on_movement_ended():
	if movementMechanic.isVelocityAboveZero and movementMechanic.isInputBeingPressed:
		animationController.scale.x = 1 if velocity.x > 0 else -1
		animationController.play_walk_animation()
	else:
		animationController.play_idle_animation()

func _on_experience_full() -> void:
	stats.level.add(1)
	damageable.health.set_to(damageable.health.maximum)
	game_events_emitter.pause_game()

func _on_unpause_after_lvl_up():
	stats.xp.remove(stats.xp.maximum)
	stats.xp.increase_max(stats.level.current * 100 * 1.25)
	stats.xp.add_from_overflow()

func _on_health_none_left() -> void:
	await get_tree().create_timer(0.1).timeout
	animationController.play_death_animation()
	await get_tree().create_timer(1.5).timeout
	get_tree().call_deferred("reload_current_scene")

func _on_health_changed() -> void:
	healthBar.value = damageable.health.current
	
func _on_xp_modified():
	xpBar.value = stats.xp.current
