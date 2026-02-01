class_name NodeBuilder

var node: Node3D

func _init(ref: Node3D):
	node = ref

func at(position: Vector3) -> NodeBuilder:
	node.global_position = position
	return self

func at_3d(position: Vector3) -> NodeBuilder:
	node.position = position
	return self

func with_scale(scale: Vector3) -> NodeBuilder:
	node.scale = scale
	return self
	
func with_rotation(rotation: Vector3) -> NodeBuilder:
	node.global_rotation = rotation
	return self

func as_child_of(parent: Node) -> NodeBuilder:
	parent.add_child.call_deferred(node)
	return self

func in_group(group: String) -> NodeBuilder:
	node.add_to_group(group)
	return self

func align_to_surface(hex_data: HexData, space_state: PhysicsDirectSpaceState3D) -> NodeBuilder:
	var ray_start := hex_data.center + Vector3.UP * 10.0
	var ray_end := hex_data.center + Vector3.DOWN * 10.0
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	var result := space_state.intersect_ray(query)

	if not result.is_empty():
		node.global_position = result.position + Vector3.UP * 0.5
		node.basis.y = result.normal.normalized()
		node.basis.x = -node.basis.z.cross(result.normal).normalized()
		node.basis = node.basis.orthonormalized()
		var new_transform = Transform3D(node.basis, node.transform.origin)
		node.global_transform = new_transform
	return self

func create() -> Node3D:
	return node
