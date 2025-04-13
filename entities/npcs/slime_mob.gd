class_name Slime
extends CharacterBody2D

@export var stats: Stats
@export var droptable: Droptable

@onready var animationController = %Slime
@onready var player = get_tree().get_first_node_in_group("Players")
@onready var collisionBox: CollisionShape2D = %CollisionShape2D
@onready var currentScene = get_tree().current_scene

@onready var gameEventsEmitter: GameEventsEmitter = get_tree().get_first_node_in_group("GameEvents")
var gameStateResponder: GameStateResponder = GameStateResponder.new()

func _ready():
	stats = stats.duplicate(true)
	animationController.play_walk()
	gameEventsEmitter.game_paused.connect(func(): gameStateResponder.disable_self_and_physics(self))
	gameEventsEmitter.game_unpaused.connect(func(): gameStateResponder.enable_self_and_physics(self))
	stats.health.lost.connect(on_health_lost)
	stats.health.none_left.connect(on_health_none_left)

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = stats.knockback.current + (direction * stats.movementSpeed.current)
	move_and_slide()
	stats.knockback.set_to(stats.knockback.current.lerp(Vector2.ZERO, 0.1 * delta * 60))

func on_health_lost() -> void:
	animationController.play_hurt()

func on_health_none_left() -> void:
		queue_free()
		droptable.drop_at(global_position, currentScene)
