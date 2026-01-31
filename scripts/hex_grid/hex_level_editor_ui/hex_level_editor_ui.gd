extends Control

class_name EditorPanelUI

@export var asset_list: ItemList
@export var spawn_list: ItemList
@export var assets_toggle: CheckButton

signal asset_selected(index: int)
signal spawn_selected(index: int)
signal assets_mode_toggled(enabled: bool)
signal save_pressed(path: String)
signal load_pressed(path: String)
signal clear_all_pressed()

func _ready() -> void:
	asset_list.item_selected.connect(func(idx): asset_selected.emit(idx))
	asset_list.item_activated.connect(func(idx): asset_selected.emit(idx))
	spawn_list.item_selected.connect(func(idx): spawn_selected.emit(idx))
	spawn_list.item_activated.connect(func(idx): spawn_selected.emit(idx))

func populate_assets(asset_names: Array):
	asset_list.clear()
	for asset_name in asset_names:
		asset_list.add_item(str(asset_name))

func populate_spawns(spawn_names: Array):
	spawn_list.clear()
	for spawn_name in spawn_names:
		spawn_list.add_item(str(spawn_name))

func set_selected_asset(index: int):
	asset_list.deselect_all()
	if index >= 0:
		asset_list.select(index, true)
		asset_list.ensure_current_is_visible()

func set_selected_spawn(index: int):
	if spawn_list:
		spawn_list.deselect_all()
		if index >= 0:
			spawn_list.select(index, true)
			spawn_list.ensure_current_is_visible()

func clear_assets():
	for child in asset_list.get_children():
		child.queue_free()

func _on_save_pressed():
	var dialog = FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.filters = ["*.json ; JSON Files"]
	
	var levels_dir = "user://levels/"
	DirAccess.make_dir_recursive_absolute(levels_dir)
	dialog.current_dir = levels_dir
	dialog.current_file = "level_%s.json" % floor(Time.get_unix_time_from_system())
	
	get_tree().root.add_child(dialog)
	dialog.popup_centered_ratio(0.75)
	dialog.file_selected.connect(func(path): save_pressed.emit(path))

func _on_load_pressed():
	var dialog = FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.filters = ["*.json ; JSON Files"]
	
	var levels_dir = "user://levels/"
	DirAccess.make_dir_recursive_absolute(levels_dir)
	dialog.current_dir = levels_dir
	
	get_tree().root.add_child(dialog)
	dialog.popup_centered_ratio(0.75)
	dialog.file_selected.connect(func(path): load_pressed.emit(path))

func _on_clear_pressed():
	clear_all_pressed.emit()

func _on_assets_toggle_toggled(toggled_on: bool) -> void:
	assets_mode_toggled.emit(toggled_on)
