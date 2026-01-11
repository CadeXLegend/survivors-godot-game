class_name Damageable
extends Node

@export var target: Node
@export var health: Quantity
## Drag a class into here to define it as something that can damage the target
## Alternatively, define it programmatically like:
## damageable.damageableBy[SomeClass] = true
@export var damageableBy: Dictionary = {}

func _ready() -> void:
	health = health.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)

func try_get_damagers_2d(nodes: Array[Node2D]) -> Array[Damager]:
	var damagers: Array[Damager] = []
	damagers.assign((nodes
	.map(func(node: Node): return try_get_damager(node))
	.filter(func(damager: Damager): return damager != null)))
	return damagers

func try_get_damager(node: Node) -> Damager:
	if not _is_damageable_by(node): return null
	return _find_damager(node)

func _find_damager(node: Node) -> Damager:
	if _is_damager(node): return node
	for child in node.get_children():
		if _is_damager(child):
			return child
	return null
	#var index = node.get_children().find(func(child: Node): return _is_damager(child))
	#return node.get_child(index).get_script() as Damager if index > -1 else null

func _is_damager(node: Node) -> bool:
	return node is Damager

func _is_damageable_by(node: Node) -> bool:
	return damageableBy.has(node.get_script())
