class_name GameStateResponder
extends Node2D

@export var damageNumbers: DamageNumbers

func disable_self(ref: Node2D):
	ref.visible = false

func disable_self_and_physics(ref: Node2D):
	disable_self(ref)
	ref.set_process_mode.call_deferred(Node.PROCESS_MODE_DISABLED)

func enable_self(ref: Node2D):
	ref.visible = true

func enable_self_and_physics(ref: Node2D):
	enable_self(ref)
	ref.set_process_mode.call_deferred(Node.PROCESS_MODE_ALWAYS)

func spawn(ref: PackedScene) -> NodeBuilder:
	return NodeBuilder.new(ref.instantiate())
