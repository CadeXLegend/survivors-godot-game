class_name HexTileCoordSystem
extends Node

@export var hexGrid: HexagonalRidgeHexGrid

var _hexes_data: Array[HexData]

func get_hexes_data() -> Array[HexData]: return _hexes_data

signal generation_complete

func _ready() -> void:
	_hexes_data = HexUtils.calculate_hex_data(hexGrid)
	generation_complete.emit()

#func _process(_delta: float) -> void:
	#debug_hexes()

func debug_hexes() -> void:
	for i in range(_hexes_data.size()):
		var hex_data = _hexes_data[i]
		var pos: Vector3 = hex_data.center + Vector3.UP * hex_data.y_offset
		#DebugDraw3D.draw_text(pos, pos_to_text(hex_data.center), 12)
		DebugDraw3D.draw_text(pos, "%s" % HexData.TerrainType.keys()[hex_data.terrain_type], 12)
		#for j in range(6):
			#if not hex_data.has_neighbour(j): continue
			#var neighbour = hex_data.get_neighbour(j)
			#var neighbour_pos: Vector3 = neighbour.center + Vector3.UP * neighbour.y_offset
			#DebugDraw3D.draw_arrow(pos, neighbour_pos, Color.GREEN, 0.001)
			
func pos_to_text(pos: Vector3) -> String:
	return "pos: %.1f %.1f %.1f" % [pos.x, pos.y, pos.z]
