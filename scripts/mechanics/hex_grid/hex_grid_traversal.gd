class_name HexGridTraversal
extends Node

@export var hexTileCoordSystem: HexTileCoordSystem
@export var highlightSystem: HighlightHexesOnGrid
@export var node_to_move: Node3D
@export var move_speed: Quantity
@export var move_points: Quantity
@export var show_highlights_on_ready: bool
@export var show_highlight_on_init: bool

@export var default_move_flags: HexData.MovementFlags = HexData.MovementFlags.ALL
@export var traversable_types: Array[HexData.TerrainType] = [
	HexData.TerrainType.PLAIN,
	HexData.TerrainType.HILL,
]

@export var terrain_move_costs: Dictionary = {
	HexData.TerrainType.PLAIN: 0.0,
	HexData.TerrainType.HILL: 0.0,
	HexData.TerrainType.MOUNTAIN: 999.0,
	HexData.TerrainType.WATER: 999.0,
}

@export var move_east_binding: InputActionBinding
@export var move_ne_binding: InputActionBinding
@export var move_nw_binding: InputActionBinding
@export var move_west_binding: InputActionBinding
@export var move_sw_binding: InputActionBinding
@export var move_se_binding: InputActionBinding

var current_hex: HexData
var is_moving: bool = false
var injected: bool = false

signal hex_changed(new_hex: HexData)
signal movement_completed()

func _ready() -> void:
	_setup_input_bindings()
	move_points.modified.connect(_on_move_points_modified)
	move_points.none_left.connect(_on_move_points_depleted)
	if show_highlights_on_ready:
		hexTileCoordSystem.generation_complete.connect(highlight_move_range)

func _setup_input_bindings() -> void:
	var bindings = [
		move_east_binding, move_ne_binding, move_nw_binding,
		move_west_binding, move_sw_binding, move_se_binding
	]
	
	var directions = [
		HexData.HexDirection.EAST, HexData.HexDirection.NE, 
		HexData.HexDirection.NW, HexData.HexDirection.WEST,
		HexData.HexDirection.SW, HexData.HexDirection.SE
	]
	
	for i in range(bindings.size()):
		if bindings[i]:
			bindings[i].onActionBegin.connect(try_move.bind(directions[i]))

func _input(event):
	if not injected: return

	if event.is_action("select"):
		var clicked_hex = highlightSystem.get_current_hover_hex_data()
		if clicked_hex and clicked_hex != current_hex:
			move_to_hex_pathfinding(clicked_hex)

func inject(node: Node3D, hex: HexData, coord_system: HexTileCoordSystem, highlight_system: HighlightHexesOnGrid):
	hexTileCoordSystem = coord_system
	highlightSystem = highlight_system
	node_to_move = node
	current_hex = hex
	injected = true
	if show_highlight_on_init:
		highlight_move_range()

func snap_to_hex(hex_data: HexData) -> void:
	if hex_data == null:
		return
		
	current_hex = hex_data
	var target_pos = _get_hex_world_position(hex_data)
	node_to_move.global_position = target_pos
	is_moving = false
	highlight_move_range()

func try_move(direction: HexData.HexDirection) -> bool:
	if is_moving or current_hex == null or move_points.current <= 0:
		return false
		
	if not _direction_allowed(direction):
		return false
		
	if not current_hex.has_neighbour(direction):
		return false
		
	var target_hex = current_hex.get_neighbour(direction)
	var move_cost = _get_terrain_move_cost(target_hex)
	
	if move_points.current < move_cost:
		return false
		
	_move_to_hex(target_hex, move_cost)
	return true

func move_to_hex(target_hex: HexData, path_cost: float = -1.0) -> bool:
	if is_moving or current_hex == null or target_hex == null or move_points.current <= 0:
		return false
		
	var cost = path_cost if path_cost >= 0 else _get_terrain_move_cost(target_hex)
	if move_points.current < cost:
		return false
		
	_move_to_hex(target_hex, cost)
	return true

func highlight_move_range() -> void:
	if current_hex == null or highlightSystem == null:
		return

	highlightSystem.highlight_movement_range(
		current_hex,
		move_points.maximum,
		default_move_flags,
		traversable_types,
		func(hex: HexData): return _get_terrain_move_cost(hex) <= move_points.current
	)

func get_move_range() -> Array[HexData]:
	if current_hex == null:
		return []
	return _get_reachable_hexes(current_hex)

func can_act() -> bool:
	return not is_moving and move_points.current > 0

func get_remaining_move_points() -> float:
	return move_points.current if move_points else 0.0

func _on_move_points_modified() -> void:
	highlight_move_range()
	print("Move points updated: ", move_points.current, "/", move_points.maximum)

func _on_move_points_depleted() -> void:
	print("No move points remaining!")
	highlight_move_range()

func _move_to_hex(target_hex: HexData, cost: float) -> void:
	is_moving = true
	move_points.remove(cost)
	
	var ray_start := target_hex.center + Vector3.UP * 10.0
	var ray_end := target_hex.center + Vector3.DOWN * 10.0
	var query := PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	var result := node_to_move.get_world_3d().direct_space_state.intersect_ray(query)

	if result.is_empty():
		_complete_move(target_hex)
		return

	var target_pos = result.position + Vector3.UP * 0.5
	var tween := create_tween()
	var duration := node_to_move.global_position.distance_to(target_pos) / move_speed.current
	tween.tween_property(node_to_move, "global_position", target_pos, duration)
	tween.tween_callback(_complete_move.bind(target_hex))

func _complete_move(new_hex: HexData) -> void:
	current_hex = new_hex
	is_moving = false
	hex_changed.emit(current_hex)
	movement_completed.emit()
	highlight_move_range()

func _get_hex_world_position(hex_data: HexData) -> Vector3:
	return hex_data.center + Vector3.UP * hex_data.y_offset

func _get_terrain_move_cost(hex_data: HexData) -> float:
	if hex_data == null:
		return move_points.maximum + 1
	return terrain_move_costs.get(hex_data.terrain_type, 1.0)

func _direction_allowed(direction: HexData.HexDirection) -> bool:
	var flag = 1 << direction
	return default_move_flags & flag != 0

func _get_reachable_hexes(start_hex: HexData, max_points: float = -1.0) -> Array[HexData]:
	if start_hex == null:
		return []

	var available_points = move_points.current if max_points < 0 else max_points
	if available_points <= 0:
		return [start_hex]

	var result: Array[HexData] = [start_hex]
	var frontier: Array[HexData] = [start_hex]
	var visited: Dictionary = {start_hex: 0.0}

	while not frontier.is_empty():
		var current = frontier.pop_front()
		var cost_so_far = visited[current]

		if cost_so_far >= available_points:
			continue

		for dir_idx in range(6):
			if not _direction_allowed(dir_idx):
				continue

			if current.has_neighbour(dir_idx):
				var neighbour = current.get_neighbour(dir_idx)
				if neighbour == null or neighbour in visited:
					continue

				var move_cost = _get_terrain_move_cost(neighbour)
				var new_cost = cost_so_far + move_cost

				if new_cost > available_points:
					continue

				visited[neighbour] = new_cost
				frontier.append(neighbour)
				result.append(neighbour)

	return result

func move_to_hex_pathfinding(target_hex: HexData) -> bool:
	if is_moving or current_hex == null or target_hex == null or move_points.current <= 0:
		return false
	
	var path: Array[HexData] = _find_path_to_hex(target_hex)
	if path.is_empty() or path.size() < 2:
		return false
	
	var total_cost: float = 0.0
	for i in range(1, path.size()):
		total_cost += _get_terrain_move_cost(path[i])
	
	if move_points.current < total_cost:
		return false

	_move_along_path(path, total_cost)
	return true

func _move_along_path(path: Array[HexData], total_cost: float) -> void:
	is_moving = true
	move_points.remove(total_cost)
	
	var path_index: int = 1
	_move_to_next_in_path(path, path_index)

func _move_to_next_in_path(path: Array[HexData], path_index: int) -> void:
	if path_index >= path.size():
		_complete_path_movement(path[-1])
		return
	
	var next_hex = path[path_index]
	var cost = _get_terrain_move_cost(next_hex)
	
	var space_state = node_to_move.get_world_3d().direct_space_state
	var ray_start = next_hex.center + Vector3.UP * 10.0
	var ray_end = next_hex.center + Vector3.DOWN * 10.0
	var query := PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	var result := space_state.intersect_ray(query)

	if result.is_empty():
		_move_to_next_in_path(path, path_index + 1)
		return

	move_points.remove(cost)

	var target_pos = result.position + Vector3.UP * 0.5
	var tween := create_tween()
	var duration := node_to_move.global_position.distance_to(target_pos) / move_speed.current
	tween.tween_property(node_to_move, "global_position", target_pos, duration)
	tween.tween_callback(_move_to_next_in_path.bind(path, path_index + 1))

func _complete_path_movement(final_hex: HexData) -> void:
	current_hex = final_hex
	is_moving = false
	hex_changed.emit(current_hex)
	movement_completed.emit()
	highlight_move_range()

func _find_path_to_hex(target_hex: HexData) -> Array[HexData]:
	if not target_hex in get_move_range():
		return []
	
	var frontier: Array[HexData] = [current_hex]
	var came_from: Dictionary = {current_hex: null}
	var visited: Dictionary = {current_hex: 0.0}
	
	while not frontier.is_empty():
		var current = frontier.pop_front()
		if current == target_hex:
			var path: Array[HexData] = []
			var at = target_hex
			while at != null:
				path.push_front(at)
				at = came_from.get(at)
			return path
		
		var cost_so_far = visited[current]
		if cost_so_far >= move_points.current:
			continue
			
		for dir_idx in range(6):
			if not _direction_allowed(dir_idx) or not current.has_neighbour(dir_idx):
				continue
				
			var neighbour = current.get_neighbour(dir_idx)
			if neighbour in visited:
				continue
				
			var move_cost = _get_terrain_move_cost(neighbour)
			var new_cost = cost_so_far + move_cost
			if new_cost > move_points.current:
				continue
				
			visited[neighbour] = new_cost
			came_from[neighbour] = current
			frontier.append(neighbour)
	
	return []
