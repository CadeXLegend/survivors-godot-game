class_name GameStateResponder
extends Node2D

var current_builder: NodeBuilder = null

func disable_self(ref: Node2D):
	ref.visible = false

func disable_self_and_physics(ref: Node2D):
	disable_self(ref)
	ref.process_mode = Node.PROCESS_MODE_DISABLED

func enable_self(ref: Node2D):
	ref.visible = true

func enable_self_and_physics(ref: Node2D):
	enable_self(ref)
	ref.process_mode = Node.PROCESS_MODE_ALWAYS

func spawn(ref: PackedScene) -> NodeBuilder:
	return NodeBuilder.new(ref.instantiate())
