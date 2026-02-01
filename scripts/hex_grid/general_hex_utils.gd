class_name HexUtils

static var directions: Array[Vector3] = [
	Vector3( 1.0, 0,  0),     #  0° East
	Vector3( 0.5, 0,  0.866), # 60° North-East
	Vector3(-0.5, 0,  0.866), # 120°North-West
	Vector3(-1.0, 0,  0),     # 180°West
	Vector3(-0.5, 0, -0.866), # 240°South-West
	Vector3( 0.5, 0, -0.866)  # 300°South-East
]


static func place_on_hex(hex_data: HexData, packed_scene: PackedScene, grid: HexagonalRidgeHexGrid) -> Node:
	if packed_scene == null or hex_data == null:
		return null

	var center := hex_data.center
	center.y = hex_data.y_offset
	var object = game_state_responder \
					.spawn(packed_scene) \
					.as_child_of(grid) \
					.at_3d(center) \
					.align_to_surface(hex_data, grid.get_world_3d().direct_space_state) \
					.create()
	return object

static func get_object_to_hex_scale(hex_data: HexData, object: Node, grid: HexagonalRidgeHexGrid, target_scale: float = 0.5) -> Vector3:
	var hex_diameter = grid._diameter
	var max_size = 0.0
	
	for mesh_instance in object.find_children("*:*", "MeshInstance3D"):
		var aabb = mesh_instance.mesh.get_aabb()
		max_size = max(max_size, aabb.size.max())

	return Vector3.ONE * (target_scale * hex_diameter / max_size)

static func calculate_hex_data(hexGrid: HexagonalRidgeHexGrid) -> Array[HexData]:
	var hexes_data: Array[HexData] = []
	var hex_meshes: Array = hexGrid.get_hex_meshes()
	hexes_data.resize(hex_meshes.size())
	for i in range(hex_meshes.size()):
		var hex_mesh = hex_meshes[i]
		var center: Vector3 = HexUtils._get_hex_center(hex_mesh, hexGrid)
		var y_offset: float = HexUtils._get_mesh_y(hex_mesh)
		var terrain_type = _categorize_terrain(hex_mesh, center, hexGrid)
		
		var hex_data := HexData.new()
		hex_data.center = center
		hex_data.y_offset = y_offset
		hex_data.mesh = hex_mesh
		hex_data.terrain_type = terrain_type
		hexes_data[i] = hex_data
	
	_calculate_neighbours(hexes_data, hexGrid)
	return hexes_data

static func _categorize_terrain(mesh: HexMesh, center: Vector3, grid: HexagonalRidgeHexGrid) -> HexData.TerrainType:
		var vertices = mesh.get_vertices()
		var lowest = vertices[0]
		var highest = vertices[0]
		for v in vertices:
			if v.y < lowest.y:
				lowest = v
			if v.y > highest.y:
				highest = v

		var d = (lowest.y + highest.y) * 10
		if d < 0.4:
			return HexData.TerrainType.WATER
		elif d < 1.8:
			return HexData.TerrainType.PLAIN
		elif d < 3.9:
			return HexData.TerrainType.HILL
		else:
			return HexData.TerrainType.MOUNTAIN

static func _calculate_neighbours(hexes_data: Array[HexData], hexGrid: HexagonalRidgeHexGrid) -> void:
	for i in range(hexes_data.size()):
		var hex_data: HexData = hexes_data[i]
		hex_data.neighbours.clear()
		hex_data.neighbours.resize(6)
		hex_data.neighbour_directions.clear()
		hex_data.neighbour_directions.resize(6)

		for j in range(6):
			var expected_dist: float = hexGrid._diameter * 0.5
			var target_pos: Vector3 = hex_data.center + directions[j] * expected_dist

			var closest: HexData = _find_closest_hex(target_pos, hexes_data, hex_data, hexGrid)
			if closest != null:
				var actual_dist: float = hex_data.center.distance_to(closest.center)
				hex_data.neighbours[j] = closest
				hex_data.neighbour_directions[j] = true
			else:
				hex_data.neighbours[j] = null
				hex_data.neighbour_directions[j] = false

static func _find_closest_hex(target_pos: Vector3, hexes_data: Array[HexData], exclude_hex: HexData, hexGrid: HexagonalRidgeHexGrid) -> HexData:
	var closest: HexData = null
	var closest_dist: float = INF
	var max_search_dist: float = hexGrid._diameter + hexGrid._diameter * 0.5

	for hex_data in hexes_data:
		if hex_data == exclude_hex:
			continue

		var dist: float = hex_data.center.distance_to(target_pos)
		if dist < closest_dist and dist < max_search_dist:
			closest_dist = dist
			closest = hex_data

	return closest if closest_dist < hexGrid._diameter * 0.6 else null

static func _get_hex_center(mesh: HexMesh, grid: Node) -> Vector3:
	var vertices = mesh.get_vertices()
	var center = Vector3.ZERO
	for v in vertices:
		center += v
	return center / vertices.size() + grid.global_position

static func _get_mesh_y(mesh: HexMesh) -> float:
	var vertices = mesh.get_vertices()
	var surface_ys = []

	for v in vertices:
		if v.y > -0.1:
			surface_ys.append(v.y)

	if surface_ys.is_empty():
		return 0.1

	var avg_surface_y = 0.0
	for y in surface_ys:
		avg_surface_y += y
	return avg_surface_y / surface_ys.size()
