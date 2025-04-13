class_name GameEventsEmitter
extends Node2D

signal game_paused
signal game_unpaused

func pause_game():
		game_paused.emit()
		get_tree().paused = true
		PhysicsServer2D.set_active(true)

func unpause_game():
		get_tree().paused = false
		game_unpaused.emit()
