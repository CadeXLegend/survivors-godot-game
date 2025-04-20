class_name PlayerAnimationController
extends Node2D

@export var animation_player: AnimatedSprite2D

func play_idle_animation():
	animation_player.play("idle")

func play_walk_animation():
	animation_player.play("run")

func play_hit_animation():
	animation_player.play("hit")

func play_death_animation():
	animation_player.play("death")
