class_name HexData
extends Resource

enum HexDirection {
	EAST,     # 0 - Vector3( 1.0, 0,  0)
	NE,       # 1 - Vector3( 0.5, 0,  0.866) 
	NW,       # 2 - Vector3(-0.5, 0,  0.866)
	WEST,     # 3 - Vector3(-1.0, 0,  0)
	SW,       # 4 - Vector3(-0.5, 0, -0.866)
	SE        # 5 - Vector3( 0.5, 0, -0.866)
}

enum MovementFlags {
	NONE = 0,
	EAST = 1 << 0,      # 1
	NE = 1 << 1,        # 2  
	NW = 1 << 2,        # 4
	WEST = 1 << 3,      # 8
	SW = 1 << 4,        # 16
	SE = 1 << 5,        # 32
	ALL = EAST | NE | NW | WEST | SW | SE  # 63
}


enum TerrainType {
	PLAIN = 0,
	HILL = 1,
	MOUNTAIN = 2,
	WATER = 3,
}

var terrain_type: TerrainType = TerrainType.PLAIN
var center: Vector3
var y_offset: float
var text: String
var mesh: HexMesh
var neighbours: Array[HexData] = []  # 0-5: E, NE, NW, W, SW, SE
var neighbour_directions: Array[bool] = []  # which sides have neighbors

func get_neighbour(direction: HexDirection) -> HexData:
	if has_neighbour(direction):
		return neighbours[direction]
	return null

func has_neighbour(direction: HexDirection) -> bool:
	return direction >= 0 and direction < 6 and neighbour_directions[direction]
