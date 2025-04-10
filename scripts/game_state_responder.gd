class_name GameStateResponder
extends Node2D

func disable_self(ref: Node2D):
	ref.visible = false

func disable_self_and_physics(ref: Node2D):
	disable_self(ref)
	ref.process_mode = Node.PROCESS_MODE_DISABLED
