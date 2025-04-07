extends Node2D


func play_idle_animation():
	%AnimationPlayer.play("idle")

func play_walk_animation():
	%AnimationPlayer.play("run")

func play_hit_animation():
	%AnimationPlayer.play("hit")

func play_death_animation():
	%AnimationPlayer.play("death")
