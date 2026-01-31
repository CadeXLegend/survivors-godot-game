class_name HexSpawnPoint
extends Node

@export var entity: PackedScene

func spawn(hex_data: HexData, grid: HexagonalRidgeHexGrid) -> Node:
	return HexUtils.place_on_hex(hex_data, entity, grid)
