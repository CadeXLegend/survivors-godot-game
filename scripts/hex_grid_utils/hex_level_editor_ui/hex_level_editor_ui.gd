extends Control

class_name EditorPanelUI

@onready var asset_list: ItemList = %AssetListContainer

signal asset_selected(index: int)
signal save_pressed(path: String)
signal load_pressed(path: String)
signal clear_all_pressed()

func _ready() -> void:
	asset_list.item_selected.connect(func(idx): asset_selected.emit(idx))
	asset_list.item_activated.connect(func(idx): asset_selected.emit(idx))

func populate_assets(asset_names: Array):
	asset_list.clear()
	for name in asset_names:
		asset_list.add_item(str(name))

func set_selected_asset(index: int, _asset_names: Array):
	asset_list.deselect_all()
	if index >= 0:
		asset_list.select(index, true)
		asset_list.ensure_current_is_visible()

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
