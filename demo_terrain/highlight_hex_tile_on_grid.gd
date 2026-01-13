@tool
extends HexagonalRidgeHexGrid

@export var camera: Camera3D
var hover_hex: HexMesh = null
var highlight_overlay: MeshInstance3D

func _ready():
	# Create flat hex overlay for highlight
	var overlay_mesh = MeshInstance3D.new()
	var hex_shape = HexMesh.new()
	hex_shape.diameter = 1.0  # Match your grid size
	overlay_mesh.mesh = hex_shape
	overlay_mesh.position.y = 0.1
	
	# Simple highlight material
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1, 1, 0, 0.5)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	overlay_mesh.material_override = mat
	
	add_child(overlay_mesh)
	highlight_overlay = overlay_mesh

func get_hex_center(mesh: HexMesh) -> Vector3:
	var vertices = mesh.get_vertices()
	var center = Vector3.ZERO
	for v in vertices:
		center += v
	return center / vertices.size() + global_position

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
			
			# Find closest hex mesh to hit position
			for hex_mesh in get_hex_meshes():
				var hex_center = get_hex_center(hex_mesh)
				var dist = (hex_center - world_pos).length()
				if dist < closest_dist and dist < 2.0:  # Within reasonable hex radius
					closest_dist = dist
					closest_hex = hex_mesh
			
			if closest_hex != hover_hex:
				update_hover(closest_hex)

func update_hover(new_hex: HexMesh):
	hover_hex = new_hex
	if hover_hex:
		var center = get_hex_center(hover_hex)
		highlight_overlay.global_position = center + Vector3.UP * 0.1
		highlight_overlay.visible = true
	else:
		highlight_overlay.visible = false
