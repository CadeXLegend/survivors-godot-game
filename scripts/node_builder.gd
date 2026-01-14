class_name NodeBuilder

var node: Node

func _init(ref: Node):
	node = ref

func at(position: Vector2) -> NodeBuilder:
	node.global_position = position
	return self

func at_3d(position: Vector3) -> NodeBuilder:
	node.position = position
	return self

func with_scale(scale: Vector3) -> NodeBuilder:
	node.scale = scale
	return self
	
func with_rotation(rotation: float) -> NodeBuilder:
	node.global_rotation = rotation
	return self

func as_child_of(parent: Node) -> NodeBuilder:
	parent.add_child.call_deferred(node)
	return self

func in_group(group: String) -> NodeBuilder:
	node.add_to_group(group)
	return self

func create() -> Node:
	return node
