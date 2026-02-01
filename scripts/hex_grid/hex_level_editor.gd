class_name HexLevelEditor
extends Node

@export var highlightSystem: HighlightHexesOnGrid
@export var coordSystem: HexTileCoordSystem
@export var editor_panel_scene: PackedScene
@export var asset_list: Array[PackedScene] = []
@export var spawn_list: Array[PackedScene] = []
@export var assets_folder_path: String = "res://assets/"
@export var spawn_folder_path: String = "res://spawns/"
var editor_ui: EditorPanelUI

var is_edit_mode: bool = false
var is_assets_mode: bool = true
var selected_asset_index: int = -1
var selected_spawn_index: int = -1
var placed_spawns: Dictionary = {}
var placed_assets: Dictionary = {}
var preview_instance: Node3D
var rotation_y: float = 0.0
var scale_factor: float = 1.0

func _ready():
	highlightSystem.hex_hovered.connect(_on_hex_hovered)
	preview_instance = Node3D.new()
	preview_instance.name = "EditorPreview"
	get_tree().current_scene.add_child.call_deferred(preview_instance)
	_populate_asset_list_from_folder()
	_populate_spawn_list_from_folder()

func _populate_asset_list_from_folder():
	asset_list.clear()
	
	if not DirAccess.dir_exists_absolute(assets_folder_path):
		print("Assets folder not found: ", assets_folder_path)
		return
	
	_recursive_scan(assets_folder_path, ["fbx"])

func _populate_spawn_list_from_folder():
	spawn_list.clear()
	if not DirAccess.dir_exists_absolute(spawn_folder_path): 
		return
	_recursive_scan(spawn_folder_path, ["tscn"], true)
	print("Loaded ", spawn_list.size(), " spawn points")

func _recursive_scan(current_path: String, filters: Array[String], isSpawns: bool = false):
	var dir = DirAccess.open(current_path)
	if not dir:
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	print(file_name)
	while file_name != "":
		var full_path = current_path.path_join(file_name)

		if dir.current_is_dir() and file_name != "." and file_name != "..":
			_recursive_scan(full_path, filters, isSpawns)
		else:
			if full_path.get_extension().to_lower() in filters:
				var packed_scene = load(full_path) as PackedScene
				if packed_scene:
					if isSpawns: spawn_list.append(packed_scene)
					else: asset_list.append(packed_scene)
					print("Added asset: ", full_path)
		file_name = dir.get_next()

	dir.list_dir_end()
	if isSpawns: _update_spawn_list_ui()
	else: _update_asset_list_ui()
	print("Loaded ", asset_list.size(), " assets from ", assets_folder_path, " (recursive)")

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
	if is_edit_mode and highlightSystem.get_current_hover_hex_data():
		var hex_data = highlightSystem.get_current_hover_hex_data()
		update_preview(hex_data)
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
		editor_ui.spawn_selected.connect(_on_spawn_selected)
		editor_ui.assets_mode_toggled.connect(_on_assets_mode_toggled)
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

func _on_hex_hovered(hex_data: HexData):
	if not is_edit_mode or selected_asset_index < 0:
		clear_preview()
		return

	update_preview(hex_data)

func _on_spawn_selected(index: int):
	selected_spawn_index = index
	if is_edit_mode and highlightSystem.get_current_hover_hex_data():
		var hex_data = highlightSystem.get_current_hover_hex_data()
		update_preview(hex_data)
	else:
		clear_preview()

func _on_assets_mode_toggled(enabled: bool):
	is_assets_mode = not enabled
	selected_asset_index = -1 if enabled else selected_asset_index
	selected_spawn_index = -1 if not enabled else selected_spawn_index
	editor_ui.set_selected_asset(selected_asset_index)
	editor_ui.set_selected_spawn(selected_spawn_index)
	if not enabled:
		editor_ui.populate_assets(asset_list)
	else:
		editor_ui.populate_spawns(spawn_list)
	clear_preview()

func update_preview(hex_data: HexData):
	clear_preview()
	var index =  selected_asset_index if is_assets_mode else selected_spawn_index
	if index >= 0 and index < asset_list.size():
		var asset_scene = asset_list[index] if is_assets_mode else spawn_list[index]
		var preview = asset_scene.instantiate() as Node3D
		var center = hex_data.center
		center.y = hex_data.y_offset
		preview.position = center
		preview.rotation_degrees.y = rotation_y
		preview.scale = Vector3.ONE * scale_factor

		if preview.has_method("set_preview_mode"):
			preview.set_preview_mode(true)
		else:
			_set_transparent_recursive(preview, 0.5)

		preview_instance.add_child.call_deferred(preview)

func place_asset():
	var hovered_hex_data = highlightSystem.get_current_hover_hex_data()
	var index = selected_asset_index if is_assets_mode else selected_spawn_index
	if not hovered_hex_data or index < 0:
		return

	var placed_array = placed_assets if is_assets_mode else placed_spawns
	if placed_array.has(hovered_hex_data):
		placed_array[hovered_hex_data].queue_free()

	var asset_scene = asset_list[index] if is_assets_mode else spawn_list[index]
	var asset = HexUtils.place_on_hex(hovered_hex_data, asset_scene, coordSystem.hexGrid)
	if asset:
		await asset.ready
		if not is_assets_mode:
			if asset is HexSpawnPoint:
				var node = asset.inject(hovered_hex_data, coordSystem.hexGrid, coordSystem, highlightSystem)
		asset.add_to_group("level_editor_created_asset")
		asset.rotation_degrees.y = rotation_y
		asset.scale = Vector3.ONE * scale_factor
		placed_array[hovered_hex_data] = asset
	clear_preview()

func delete_asset():
	var hovered_hex_data = highlightSystem.get_current_hover_hex_data()
	var assets = placed_assets if is_assets_mode else placed_spawns
	if not hovered_hex_data or not assets.has(hovered_hex_data):
		return

	assets[hovered_hex_data].queue_free()
	assets.erase(hovered_hex_data)

func rotate_selected(delta_deg: float):
	rotation_y += delta_deg
	if preview_instance.get_child_count() > 0:
		var preview = preview_instance.get_child(0)
		preview.rotation_degrees.y = rotation_y
		var hovered = highlightSystem.get_current_hover_hex_data()
		if hovered and placed_assets.has(hovered):
			placed_assets[hovered].rotation_degrees.y = rotation_y

func scale_selected(delta_scale: float):
	scale_factor = clamp(scale_factor + delta_scale, 0.1, 5.0)
	if preview_instance.get_child_count() > 0:
		var preview = preview_instance.get_child(0)
		preview.scale = Vector3.ONE * scale_factor
		var hovered = highlightSystem.get_current_hover_hex_data()
		if hovered and placed_assets.has(hovered):
			placed_assets[hovered].scale = Vector3.ONE * scale_factor

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
	if editor_ui == null: return

	var asset_names = []
	for scene in asset_list:
		asset_names.append(scene.resource_path.get_file().get_basename())

	editor_ui.populate_assets(asset_names)
	editor_ui.set_selected_asset(selected_asset_index)

func _update_spawn_list_ui():
	if editor_ui == null: return
	
	var spawn_names = []
	for scene in spawn_list:
		spawn_names.append(scene.resource_path.get_file().get_basename())
	
	editor_ui.populate_spawns(spawn_names)
	editor_ui.set_selected_spawn(selected_spawn_index)

func clear_all_assets():
	for asset in placed_assets.values():
		if asset:
			asset.queue_free()

	placed_assets.clear()
	clear_preview()
	selected_asset_index = -1
	rotation_y = 0.0
	scale_factor = 1.0

func save_level(path: String):
	var hex_data_list = coordSystem.get_hexes_data()

	var save_data = {
		"hex_count": hex_data_list.size(),
		"assets": []
	}

	for hex_data in placed_assets.keys():
		var asset = placed_assets[hex_data]
		var hex_index = hex_data_list.find(hex_data)
		if hex_index >= 0:
			save_data.assets.append({
				"hex_index": hex_index,
				"scene_path": asset.scene_file_path,
				"position": str(asset.position),
				"rotation_y": asset.rotation_degrees.y,
				"scale": str(asset.scale)
			})
	for hex_data in placed_spawns.keys():
		var asset = placed_spawns[hex_data]
		var hex_index = hex_data_list.find(hex_data)
		if hex_index >= 0:
			save_data.assets.append({
				"hex_index": hex_index,
				"scene_path": asset.scene_file_path,
				"position": str(asset.position),
				"rotation_y": asset.rotation_degrees.y,
				"scale": str(asset.scale)
			})

	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "  "))
	file.close()

func load_level(path: String):
	var hex_data_list = coordSystem.get_hexes_data()
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return

	var json_text = file.get_as_text()
	file.close()

	var data = JSON.parse_string(json_text)
	clear_all_assets()

	for asset_data in data.assets:
		var hex_index = asset_data.hex_index
		if hex_index >= 0 and hex_index < hex_data_list.size():
			var hex_data = hex_data_list[hex_index]
			var asset_scene = load(asset_data.scene_path) as PackedScene
			if asset_scene:
				var asset = HexUtils.place_on_hex(hex_data, asset_scene, coordSystem.hexGrid)
				if asset:
					await asset.ready
					asset.add_to_group("level_editor_created_asset")
					asset.position = parse_vector3(asset_data.position)
					asset.rotation_degrees.y = float(asset_data.rotation_y)
					asset.scale = parse_vector3(asset_data.scale)
					if asset is HexSpawnPoint:
						var node = asset.inject(hex_data, coordSystem.hexGrid, coordSystem, highlightSystem)
						placed_spawns[hex_data] = asset
					else:
						placed_assets[hex_data] = asset

func parse_vector3(json_string: String) -> Vector3:
	var clean = json_string.replace("(", "").replace(")", "")
	var parts = clean.split(",")
	if parts.size() == 3:
		return Vector3(
			float(parts[0].strip_edges()),
			float(parts[1].strip_edges()),
			float(parts[2].strip_edges())
		)
	return Vector3.ZERO
