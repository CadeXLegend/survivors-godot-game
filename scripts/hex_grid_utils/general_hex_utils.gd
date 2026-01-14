class_name HexUtils

static func get_hex_center(mesh: HexMesh, grid: Node) -> Vector3:
	var vertices = mesh.get_vertices()
	var center = Vector3.ZERO
	for v in vertices:
		center += v
	return center / vertices.size() + grid.global_position

static func place_on_hex(hex_mesh: HexMesh, packed_scene: PackedScene, grid: Node):
	if packed_scene == null:
		return
	#var spawnable := packed_scene.instantiate() as Node3D
	var center := get_hex_center(hex_mesh, grid)
	center.y = get_hex_surface_y(hex_mesh, grid)
	var object = game_state_responder.spawn(packed_scene).as_child_of(grid).at_3d(center).create()
	#if scaleObjectToHex:
		#object.scale = Vector3(0.01, 0.01, 0.01)
		#object.scale = get_object_to_hex_scale(hex_mesh, object, grid)

static func get_object_to_hex_scale(hex_mesh: HexMesh, object: Node, grid: Node, target_scale: float = 0.5) -> Vector3:
	# find largest dimension of model
	var max_size = 0.0
	for mesh_instance in object.find_children("*:*", "MeshInstance3D"):
		var aabb = mesh_instance.mesh.get_aabb()
		max_size = max(max_size, aabb.size.max())
	
	return Vector3.ONE * (target_scale / max_size * 0.1)

static func get_hex_surface_y(mesh: HexMesh, grid: Node) -> float:
	var vertices = mesh.get_vertices()
	var surface_ys = []
	
	# Filter to "surface" vertices (top layer, not sides)
	for v in vertices:
		if v.y > -0.1:  # Ignore bottom/side vertices
			surface_ys.append(v.y)
	
	if surface_ys.is_empty():
		return 0.1  # Safe fallback
	
	# Average of surface vertices + small offset
	var avg_surface_y = 0.0
	for y in surface_ys:
		avg_surface_y += y
	avg_surface_y /= surface_ys.size()
	
	return avg_surface_y + grid.global_position.y + 0.2  # Higher offset for buildings


static func is_ridge_tile(mesh: HexMesh) -> bool:
	var vertices = mesh.get_vertices()
	var avg_y = 0.0
	var max_y = -INF
	var min_y = INF

	for v in vertices:
		avg_y += v.y
		max_y = max(max_y, v.y)
		min_y = min(min_y, v.y)
	
	avg_y /= vertices.size()
	
	var peak_ratio = (max_y - avg_y) / max(0.01, avg_y)
	var height_range = max_y - min_y
	
	# not quite perfected yet, nearly there
	# there's only a small handful of false positive tiles
	return peak_ratio > 1.4 or height_range > 0.2

static func is_flat_tile(mesh: HexMesh) -> bool:
	return not is_ridge_tile(mesh)
