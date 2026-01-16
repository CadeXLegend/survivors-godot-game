@tool
extends EditorPlugin
class_name HexHighlightEditorPlugin

var flat_tile_color: Color = Color("ffc60090")
var ridge_tile_color: Color = Color("ff004589")

var hexGrid: HexagonalRidgeHexGrid
var hover_hex: HexMesh = null
var highlight_overlay: MeshInstance3D

func _enable_plugin() -> void:
	print("HexHighlightEditorPlugin: Enabled")
	# Plugin is now active

func _disable_plugin() -> void:
	print("HexHighlightEditorPlugin: Disabled")
	# Clean up any persistent state here
	if highlight_overlay and highlight_overlay.get_parent():
		highlight_overlay.get_parent().remove_child(highlight_overlay)
	highlight_overlay = null
	hover_hex = null

func _enter_tree() -> void:
	print("HexHighlightEditorPlugin: ENTER_TREE")
	_setup_highlight_overlay()

func _exit_tree() -> void:
	print("HexHighlightEditorPlugin: EXIT_TREE")
	# Full cleanup
	if highlight_overlay and highlight_overlay.get_parent():
		highlight_overlay.get_parent().remove_child(highlight_overlay)
	highlight_overlay = null
	hover_hex = null

func _handles(object: Object) -> bool:
	# Activate when HexagonalRidgeHexGrid is selected
	return object is HexagonalRidgeHexGrid

func _forward_3d_gui_input(camera: Camera3D, event: InputEvent) -> int:
	if event is InputEventMouseMotion:
		_handle_editor_mouse_hover(camera, event.position)
		# Let editor continue handling input (orbit, pan, etc.)
	return EditorPlugin.AFTER_GUI_INPUT_PASS

func _handle_editor_mouse_hover(camera: Camera3D, mouse_pos: Vector2):
	if not hexGrid or not camera:
		return
	
	# Direct viewport unprojection to world Y=0 plane
	var from = camera.project_ray_origin(mouse_pos)
	var to = camera.project_ray_normal(mouse_pos)
	
	# Intersect ray with hex grid plane (Y=0)
	if abs(to.y) > 0.001:
		var t = -from.y / to.y
		var world_pos = from + t * to
		
		var closest_hex = _find_closest_hex(world_pos)
		if closest_hex != hover_hex:
			update_hover(closest_hex)
	else:
		if hover_hex:
			update_hover(null)

func _setup_highlight_overlay():
	var edited_scene = EditorInterface.get_edited_scene_root()
	if not edited_scene:
		print("No edited scene open")
		return

	hexGrid = _find_hex_grid(edited_scene)
	if not hexGrid:
		print("No HexagonalRidgeHexGrid found in scene")
		return
	
	print("HexGrid found: ", hexGrid.name)
	
	# Create highlight overlay
	highlight_overlay = MeshInstance3D.new()
	var hex_shape = HexMesh.new()
	hex_shape.diameter = 1.0
	highlight_overlay.mesh = hex_shape
	highlight_overlay.position.y = 0.1
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = flat_tile_color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	highlight_overlay.material_override = mat
	
	hexGrid.add_child(highlight_overlay)
	highlight_overlay.visible = false
	print("Highlight overlay created successfully")

func update_hover(new_hex: HexMesh):
	hover_hex = new_hex
	if hover_hex and highlight_overlay:
		var center = HexUtils.get_hex_center(hover_hex, hexGrid)
		highlight_overlay.global_position = center + Vector3.UP * 0.1
		highlight_overlay.visible = true
		
		var mat: StandardMaterial3D = highlight_overlay.material_override
		if HexUtils.is_ridge_tile(hover_hex):
			mat.albedo_color = ridge_tile_color
		else:
			mat.albedo_color = flat_tile_color
	elif highlight_overlay:
		highlight_overlay.visible = false

func _find_closest_hex(world_pos: Vector3) -> HexMesh:
	var closest_hex: HexMesh = null
	var closest_dist = INF
	
	for hex_mesh in hexGrid.get_hex_meshes():
		if hex_mesh is HexMesh:
			var hex_center = HexUtils.get_hex_center(hex_mesh, hexGrid)
			var dist = (hex_center - world_pos).length()
			if dist < closest_dist and dist < 2.0:
				closest_dist = dist
				closest_hex = hex_mesh
	
	return closest_hex

func _find_hex_grid(root: Node) -> HexagonalRidgeHexGrid:
	print("trying")
	if root is HexagonalRidgeHexGrid:
		return root
	for child in root.get_children():
		var found = _find_hex_grid(child)
		if found:
			return found
	return null
