class_name NodeBuilder

var node: Node2D

func _init(ref: Node2D):
	node = ref

func at(position: Vector2) -> NodeBuilder:
	node.global_position = position
	return self
	
func with_rotation(rotation: float) -> NodeBuilder:
	node.global_rotation = rotation
	return self

func as_child_of(parent: Node2D) -> NodeBuilder:
	parent.call_deferred("add_child", node)
	return self

func in_group(group: String) -> NodeBuilder:
	node.add_to_group(group)
	return self

func create() -> Node2D:
	return node
