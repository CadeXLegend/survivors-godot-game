class_name Slime
extends CharacterBody2D

@onready var knockback: QuantityVector2 = %Knockback
@onready var movementSpeed: Quantity = %MovementSpeed
@onready var health: Quantity = %Health
@onready var droptable: Droptable = %Droptable

@onready var animationController = %Slime
@onready var player = get_tree().get_first_node_in_group("Players")
@onready var collisionBox: CollisionShape2D = %CollisionShape2D

@onready var gameEventsEmitter: GameEventsEmitter = get_tree().get_first_node_in_group("GameEvents")
var gameStateResponder: GameStateResponder = GameStateResponder.new()

func _ready():
	animationController.play_walk()
	gameEventsEmitter.game_paused.connect(func(): gameStateResponder.disable_self_and_physics(self))
	gameEventsEmitter.game_unpaused.connect(func(): gameStateResponder.enable_self_and_physics(self))

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = knockback.current + (direction * movementSpeed.current)
	move_and_slide()
	knockback.current = knockback.current.lerp(Vector2.ZERO, 0.1 * delta * 60)

func take_damage(amount: int):
	health.remove(amount)

func _on_health_lost() -> void:
	animationController.play_hurt()

func _on_health_none_left() -> void:
		queue_free()
		droptable.drop_at(global_position)
