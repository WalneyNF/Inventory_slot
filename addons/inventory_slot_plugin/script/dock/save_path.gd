@tool
extends PanelContainer

enum MODE_PATH {PLUGIN,UNDEFINED}

const SLOT_SAVE_INVENTORY = preload("res://addons/inventory_slot_plugin/assets/icons/slot_save_inventory.tres")
const SLOT_UNSAVE_INVENTORY = preload("res://addons/inventory_slot_plugin/assets/icons/slot_unsave_inventory.tres")

@onready var pluginpath: HBoxContainer = $Vbox/hbox
@onready var plugin_path_button: ButtonVisible = $Vbox/hbox/vbox/SaveButton
@onready var path_global: OptionButton = %path_global
@onready var extension: LineEdit = %extension
@onready var save: Button = $Vbox/hbox/vbox/Save
@onready var path_button: Button = %path
@onready var warning: Label = %warning

func _ready() -> void:
	var _system_file = InventorySystem._get_settings_system()
	
	path_global.select(_system_file.path_mode)
	extension.text = _system_file.extension
	path_button.text = _system_file.path
	path_button.tooltip_text = _system_file.path


func path_selection(_path: String) -> void:
	path_button.text = _path
	path_button.tooltip_text = _path
	
	save.icon = SLOT_UNSAVE_INVENTORY


func _on_path_global_item_selected(_index: int) -> void:
	match _index:
		MODE_PATH.PLUGIN:
			plugin_path_button.disabled = false
			pluginpath.show()
		MODE_PATH.UNDEFINED:
			pluginpath.hide()
			plugin_path_button.disabled = true

func _on_extension_text_changed(_new_text: String) -> void:
	save.icon = SLOT_UNSAVE_INVENTORY

func _on_panel_system_path_pressed() -> void:
	var explorer = EditorFileDialog.new()
	
	explorer.dir_selected.connect(path_selection)
	explorer.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	explorer.current_dir = InventorySystem._get_settings_system().path
	
	add_child(explorer)
	explorer.popup_file_dialog()

func _on_save_pressed() -> void:
	if extension.text.length() <= 2:
		warning.show()
		return
	
	warning.hide()
	
	InventorySystem.push_system_file(
		path_global.get_selected_id(),
		path_button.text,
		extension.text
	)
	
	save.icon = SLOT_SAVE_INVENTORY
	Inventory.reload_dock.emit()
