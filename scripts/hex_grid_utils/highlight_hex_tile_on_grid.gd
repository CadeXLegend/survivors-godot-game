@tool
extends HexagonalRidgeHexGrid

@export var camera: Camera3D
@export var flat_tile_color: Color = Color.YELLOW
@export var ridge_tile_color: Color = Color.RED

var hover_hex: HexMesh = null
var highlight_overlay: MeshInstance3D

func _ready():
	# Create flat hex overlay for highlight
	var overlay_mesh = MeshInstance3D.new()
	var hex_shape = HexMesh.new()
	hex_shape.diameter = 1.0
	overlay_mesh.mesh = hex_shape
	overlay_mesh.position.y = 0.1
	
	# Dynamic material for color changes
	var mat = StandardMaterial3D.new()
	mat.albedo_color = flat_tile_color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	overlay_mesh.material_override = mat
	
	add_child(overlay_mesh)
	highlight_overlay = overlay_mesh

func _input(event):
	if event is InputEventMouseMotion and camera:
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * 1000
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to)
		var result = space_state.intersect_ray(query)
		
		if result:
			var world_pos = result.position
			var closest_hex: HexMesh = null
			var closest_dist = INF
			
			for hex_mesh in get_hex_meshes():
				var hex_center = HexUtils.get_hex_center(hex_mesh, self)
				var dist = (hex_center - world_pos).length()
				if dist < closest_dist and dist < 2.0:
					closest_dist = dist
					closest_hex = hex_mesh
			
			if closest_hex != hover_hex:
				update_hover(closest_hex)

func update_hover(new_hex: HexMesh):
	hover_hex = new_hex
	if hover_hex:
		var center = HexUtils.get_hex_center(hover_hex, self)
		highlight_overlay.global_position = center + Vector3.UP * 0.1
		highlight_overlay.visible = true
		
		# Use exported colors
		var mat: StandardMaterial3D = highlight_overlay.material_override
		if HexUtils.is_ridge_tile(hover_hex):
			mat.albedo_color = ridge_tile_color
		else:
			mat.albedo_color = flat_tile_color
	else:
		highlight_overlay.visible = false
