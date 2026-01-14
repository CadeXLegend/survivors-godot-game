class_name PopulateHexes
extends Node

@export var grid: HexagonalRidgeHexGrid
@export var flora: Spawnables
@export var fauna: Spawnables
@export var amountOfFloraToSpawn: int
@export var amountOfFaunaToSpawn: int

func _ready() -> void:
	populate_at_random(amountOfFloraToSpawn, flora)
	populate_at_random(amountOfFaunaToSpawn, fauna)

func populate_at_random(count: int, spawnables: Spawnables):
	var available = grid.get_hex_meshes().duplicate()
	available.shuffle()
	
	var flat_tiles = []
	for hex_mesh in available:
		if HexUtils.is_flat_tile(hex_mesh):
			flat_tiles.append(hex_mesh)
	
	for i in min(count, flat_tiles.size()):
		var spawn_index = randi_range(0, spawnables.table.drops.size() - 1)
		HexUtils.place_on_hex(flat_tiles[i], spawnables.table.drops[spawn_index], grid)
