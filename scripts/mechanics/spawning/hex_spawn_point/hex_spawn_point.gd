class_name HexSpawnPoint
extends Node

@export var entity: PackedScene
@export var spawn_on_init: bool
@export var use_traversal: bool
@export var hexGridTraversal: HexGridTraversal

func inject(hex_data: HexData, grid: HexagonalRidgeHexGrid, coord_system: HexTileCoordSystem = %HexTileCoordSystem, highlight_system: HighlightHexesOnGrid = %HighlightHexesOnGrid):
	if spawn_on_init:
		_spawn(hex_data, grid, coord_system, highlight_system)

func _spawn(hex_data: HexData, grid: HexagonalRidgeHexGrid, coord_system: HexTileCoordSystem = %HexTileCoordSystem, highlight_system: HighlightHexesOnGrid = %HighlightHexesOnGrid) -> Node:
	var node = HexUtils.place_on_hex(hex_data, entity, grid)
	if use_traversal:
		hexGridTraversal.inject(node, hex_data, coord_system, highlight_system)
	return node
