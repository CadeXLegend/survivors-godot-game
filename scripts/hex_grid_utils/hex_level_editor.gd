class_name HexLevelEditor
extends Node

@export var highlight_grid: HighlightHexTileOnGrid
@export var asset_list: Array[PackedScene] = []
@export var editor_panel_scene: PackedScene
var editor_ui: EditorPanelUI

var is_edit_mode: bool = false
var selected_asset_index: int = -1
var preview_instance: Node3D
var placed_assets: Dictionary = {}
var rotation_y: float = 0.0
var scale_factor: float = 1.0

func _ready():
	if highlight_grid:
		highlight_grid.hex_hovered.connect(_on_hex_hovered)
	
	preview_instance = Node3D.new()
	preview_instance.name = "EditorPreview"
	get_tree().current_scene.add_child.call_deferred(preview_instance)

func _input(event):
	if event.is_action_pressed("hex_level_creator_toggle"):
		toggle_edit_mode()
		return
	
	if not is_edit_mode:
		return
		
	if event.is_action_pressed("hex_level_creator_place"):
		place_asset()
	if event.is_action_pressed("hex_level_creator_delete"):
		delete_asset()
	if event.is_action("hex_level_creator_rotate_left"):
		rotate_selected(-15.0)
	if event.is_action("hex_level_creator_rotate_right"):
		rotate_selected(15.0)
	if event.is_action("hex_level_creator_scale_down"):
		scale_selected(-0.01)
	if event.is_action("hex_level_creator_scale_up"):
		scale_selected(0.01)

func _on_asset_selected(index: int):
	selected_asset_index = index
	if is_edit_mode and highlight_grid.get_currently_hovered_hex():
		var center = HexUtils.get_hex_center(highlight_grid.get_currently_hovered_hex(), highlight_grid)
		update_preview(center)
	else:
		clear_preview()


func _on_save_pressed(path: String):
	save_level(path)

func _on_load_pressed(path: String):
	load_level(path)

func _on_clear_all_pressed():
	clear_all_assets()

func toggle_edit_mode():
	is_edit_mode = !is_edit_mode
	
	if is_edit_mode:
		show_editor_ui()
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	else:
		hide_editor_ui()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		clear_preview()

func show_editor_ui():
	if editor_panel_scene:
		var canvas_layer = CanvasLayer.new()
		canvas_layer.layer = 128
		editor_ui = editor_panel_scene.instantiate() as EditorPanelUI
		editor_ui.asset_selected.connect(_on_asset_selected)
		editor_ui.save_pressed.connect(_on_save_pressed)
		editor_ui.load_pressed.connect(_on_load_pressed)
		editor_ui.clear_all_pressed.connect(_on_clear_all_pressed)
		canvas_layer.add_child.call_deferred(editor_ui)
		get_tree().root.add_child.call_deferred(canvas_layer)
		_update_asset_list_ui()

func hide_editor_ui():
	if editor_ui:
		editor_ui.queue_free()
		editor_ui = null

func _on_hex_hovered(hex: HexMesh):
	if not is_edit_mode or selected_asset_index < 0:
		clear_preview()
		return

	var center = HexUtils.get_hex_center(hex, highlight_grid)
	center.y = HexUtils.get_hex_surface_y(hex, highlight_grid)
	update_preview(center)

func update_preview(center: Vector3):
	clear_preview()

	if selected_asset_index >= 0 and selected_asset_index < asset_list.size():
		var asset_scene = asset_list[selected_asset_index]
		var preview = asset_scene.instantiate() as Node3D

		preview.position = center
		preview.rotation_degrees.y = rotation_y
		preview.scale = Vector3.ONE * scale_factor

		if preview.has_method("set_preview_mode"):
			preview.set_preview_mode(true)
		else:
			_set_transparent_recursive(preview, 0.5)

		preview_instance.add_child.call_deferred(preview)

func place_asset():
	var hovered = highlight_grid.get_currently_hovered_hex()
	if not hovered or selected_asset_index < 0:
		return

	var asset_scene = asset_list[selected_asset_index]

	if placed_assets.has(hovered):
		placed_assets[hovered].queue_free()

	var asset = HexUtils.place_on_hex(hovered, asset_scene, highlight_grid)
	if asset:
		asset.add_to_group("level_editor_created_asset")
		asset.rotation_degrees.y = rotation_y
		asset.scale = Vector3.ONE * scale_factor
		placed_assets[hovered] = asset

	clear_preview()

func delete_asset():
	var hovered = highlight_grid.get_currently_hovered_hex()
	if not hovered or not placed_assets.has(hovered):
		return
	
	placed_assets[hovered].queue_free()
	placed_assets.erase(hovered)

func rotate_selected(delta_deg: float):
	rotation_y += delta_deg
	if preview_instance.get_child_count() > 0:
		preview_instance.get_child(0).rotation_degrees.y = rotation_y

func scale_selected(delta_scale: float):
	scale_factor = clamp(scale_factor + delta_scale, 0.1, 5.0)
	if preview_instance.get_child_count() > 0:
		preview_instance.get_child(0).scale = Vector3.ONE * scale_factor

func clear_preview():
	for child in preview_instance.get_children():
		child.queue_free()

func _set_transparent_recursive(node: Node, alpha: float):
	if node is MeshInstance3D and node.material_override:
		var mat = node.material_override as StandardMaterial3D
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color.a = alpha
	for child in node.get_children():
		_set_transparent_recursive(child, alpha)

func _update_asset_list_ui():
	if editor_ui == null:
		return
	
	var asset_names = []
	for scene in asset_list:
		asset_names.append(scene.resource_path.get_file().get_basename())
	
	editor_ui.populate_assets(asset_names)
	editor_ui.set_selected_asset(selected_asset_index, asset_names)

func clear_all_assets():
	for child in highlight_grid.get_children():
		if child.is_in_group("level_editor_created_asset"):
			child.queue_free()
	
	placed_assets.clear()
	clear_preview()
	selected_asset_index = -1
	rotation_y = 0.0
	scale_factor = 1.0

func _find_asset_on_hex(hex_mesh: HexMesh) -> Node3D:
	var hex_center = HexUtils.get_hex_center(hex_mesh, highlight_grid)
	
	for child in highlight_grid.get_children():
		if child is Node3D and child != preview_instance:
			var dist = (child.global_position - hex_center).length()
			if dist < 1.0:
				return child
	return null

func save_level(path: String):
	var hex_meshes = highlight_grid.get_hex_meshes()
	
	var save_data = {
		"hex_list": hex_meshes.size(),
		"assets": []
	}
	
	for hex_mesh in placed_assets.keys():
		var asset = placed_assets[hex_mesh]
		var hex_index = hex_meshes.find(hex_mesh)
		save_data.assets.append({
			"hex_index": hex_index,
			"scene_path": asset.scene_file_path,
			"position": asset.position,
			"rotation_y": asset.rotation_degrees.y,
			"scale": asset.scale
		})
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "  "))
	file.close()

func load_level(path: String):
	var hex_meshes = highlight_grid.get_hex_meshes()
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return
		
	var json_text = file.get_as_text()
	file.close()

	var data = JSON.parse_string(json_text)
	clear_all_assets()

	for asset_data in data.assets:
		var hex_index = asset_data.hex_index
		if hex_index >= 0 and hex_index < hex_meshes.size():
			var hex_mesh = hex_meshes[hex_index]
			var asset_scene = load(asset_data.scene_path) as PackedScene
			if asset_scene:
				var new_asset = HexUtils.place_on_hex(hex_mesh, asset_scene, highlight_grid)
				if new_asset:
					new_asset.add_to_group("level_editor_created_asset")
					new_asset.position = parse_vector3(asset_data.position)
					new_asset.rotation_degrees.y = float(asset_data.rotation_y)
					new_asset.scale = parse_vector3(asset_data.scale)
					placed_assets[hex_mesh] = new_asset

func parse_vector3(json_string: String) -> Vector3:
	# JSON saves as "(20.3516, 0.239341, 18.75)"
	var clean = json_string.replace("(", "").replace(")", "")
	var parts = clean.split(",")
	if parts.size() == 3:
		return Vector3(
			float(parts[0].strip_edges()),
			float(parts[1].strip_edges()),
			float(parts[2].strip_edges())
		)
	return Vector3.ZERO
