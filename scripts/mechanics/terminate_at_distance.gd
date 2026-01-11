class_name TerminateAtDistance
extends Node

@export var target: Node
@export var distance: Quantity

func _ready() -> void:
	distance.full.connect(func(): if not target.is_queued_for_deletion(): target.queue_free())
	distance.full.connect(func(): distance.set_to(0))
