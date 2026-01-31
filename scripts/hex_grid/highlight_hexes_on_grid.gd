@tool 
extends HexagonalRidgeHexGrid
class_name HighlightHexesOnGrid

@export var camera: Camera3D
@export var coord_system: HexTileCoordSystem
@export var highlight_height: float = 0.1
@export var search_radius_tolerance: float = 1.2
@export var plain_color: Color = Color("ffc60023")
@export var hill_color: Color = Color("00ff0020")
@export var mountain_color: Color = Color("ff000037")
@export var water_color: Color = Color("0000ff37")

var _highlight_overlays: Dictionary = {}  # HexData -> MeshInstance3D
var _materials: Dictionary = {}           # TerrainType -> Material
var _hover_overlay: MeshInstance3D

var _currently_hovered_hex: HexData = null

signal hex_hovered(hex_data: HexData)

func _ready():
	_materials[HexData.TerrainType.PLAIN] = _create_material(plain_color)
	_materials[HexData.TerrainType.HILL] = _create_material(hill_color)
	_materials[HexData.TerrainType.MOUNTAIN] = _create_material(mountain_color)
	_materials[HexData.TerrainType.WATER] = _create_material(water_color)
	coord_system.generation_complete.connect(_create_overlays)
	coord_system.generation_complete.connect(_create_hover_overlay)

func _create_material(color: Color) -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return mat

func _create_overlays():
	for hex_data in coord_system.get_hexes_data():
		var overlay = MeshInstance3D.new()
		var hex_shape = HexMesh.new()
		var mat = _materials[hex_data.terrain_type]
		var pos = hex_data.center + Vector3.UP * (hex_data.y_offset + highlight_height)

		hex_shape.diameter = coord_system.hexGrid._diameter
		overlay.mesh = hex_shape
		overlay.position = pos
		overlay.visible = false
		overlay.material_override = mat

		add_child(overlay)
		_highlight_overlays[hex_data] = overlay

func _create_hover_overlay():
	_hover_overlay = MeshInstance3D.new()
	var hex_shape = HexMesh.new()
	var mat = StandardMaterial3D.new()
	hex_shape.diameter = coord_system.hexGrid._diameter * 0.95
	_hover_overlay.mesh = hex_shape
	mat.albedo_color = Color(0.152, 0.152, 0.152, 0.409)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	#mat.emission_enabled = true
	#mat.emission = Color(1, 1, 1, 0.3)
	_hover_overlay.material_override = mat
	_hover_overlay.visible = false
	add_child(_hover_overlay)

func _input(event):
	if event is InputEventMouseMotion and camera:
		_handle_raycast_hover(event.position)

func _handle_raycast_hover(mouse_pos: Vector2):
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)

	if result:
		var world_pos = result.position
		var closest_hex_data = _find_closest_hex_data(world_pos)
		if closest_hex_data != _get_current_hover():
			_set_hover(closest_hex_data)

func _find_closest_hex_data(world_pos: Vector3) -> HexData:
	var closest: HexData = null
	var closest_dist = INF

	for hex_data in coord_system.get_hexes_data():
		var dist = hex_data.center.distance_to(world_pos)
		if dist < closest_dist and dist < coord_system.hexGrid._diameter * search_radius_tolerance:
			closest_dist = dist
			closest = hex_data

	return closest

func _get_current_hover() -> HexData:
	for hex_data in _highlight_overlays:
		if _highlight_overlays[hex_data].visible:
			return hex_data
	return null

func _set_hover(hex_data: HexData):
	if hex_data:
		_currently_hovered_hex = hex_data
		_update_hover_overlay()
		hex_hovered.emit(hex_data)

func _clear_hover():
	for overlay in _highlight_overlays.values():
		overlay.visible = false

func _update_hover_overlay():
	if _currently_hovered_hex:
		var pos = _currently_hovered_hex.center + Vector3.UP * (_currently_hovered_hex.y_offset + 0.08)
		_hover_overlay.position = pos
		_hover_overlay.visible = true
	else:
		_hover_overlay.visible = false

func _highlight_hex(hex_data: HexData):
	if hex_data in _highlight_overlays:
		_highlight_overlays[hex_data].visible = true

func _get_reachable_hexes(
	start_hex: HexData, 
	max_distance: int, 
	valid_directions: HexData.MovementFlags,
	traversable_types: Array[HexData.TerrainType],
	cost_validator: Callable
) -> Array[HexData]:
	if max_distance <= 0 or start_hex == null:
		return []

	var result: Array[HexData] = [start_hex]
	var frontier: Array[HexData] = [start_hex]
	var visited: Dictionary = {start_hex: 0}

	while not frontier.is_empty():
		var current: HexData = frontier.pop_front()
		var dist = visited[current]

		if dist >= max_distance:
			continue

		for dir_idx in range(6):
			if not _is_valid_direction(dir_idx, valid_directions):
				continue

			if current.has_neighbour(dir_idx):
				var neighbour = current.get_neighbour(dir_idx)
				if neighbour == null or neighbour in visited:
					continue

				if not _is_traversable(neighbour, traversable_types):
					continue

				if not cost_validator.call(neighbour):
					continue

				visited[neighbour] = dist + 1
				frontier.append(neighbour)
				result.append(neighbour)

	return result

func _is_valid_direction(dir: int, valid_directions: HexData.MovementFlags) -> bool:
	var direction_flag = 1 << dir  # EAST=1, NE=2, NW=4, etc
	return valid_directions & direction_flag != 0

func _is_traversable(hex_data: HexData, traversable_types: Array[HexData.TerrainType]) -> bool:
	return traversable_types.has(hex_data.terrain_type)

func clear_highlights():
	for overlay in _highlight_overlays.values():
		overlay.visible = false

func get_current_hover_hex_data() -> HexData:
	return _currently_hovered_hex

func highlight_single_hex(hex_data: HexData):
	clear_highlights()
	_highlight_hex(hex_data)

func highlight_movement_range(
	start_hex: HexData,
	max_distance: int,
	valid_directions: HexData.MovementFlags = HexData.MovementFlags.ALL,
	traversable_types: Array[HexData.TerrainType] = [
		HexData.TerrainType.PLAIN, 
		HexData.TerrainType.HILL,
	],
	cost_validator: Callable = func(_hex: HexData): return true
):
	clear_highlights()
	var reachable = _get_reachable_hexes(
		start_hex, 
		max_distance, 
		valid_directions, 
		traversable_types, 
		cost_validator)
	for hex_data in reachable:
		_highlight_hex(hex_data)
