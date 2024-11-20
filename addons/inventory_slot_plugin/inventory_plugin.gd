@tool

extends EditorPlugin

var dock 

func _enter_tree() -> void:
	_import_settings()
	_ready_plugin()

func _exit_tree():
	remove_control_from_docks(dock)
	dock.free()


func _ready_plugin() -> void:
	var inventory_slot_plugin_path = str(get_script().resource_path).get_base_dir()
	
	add_autoload_singleton("Inventory",str(inventory_slot_plugin_path,"/script/slot/inventory.gd"))
	
	await get_tree().create_timer(0.2).timeout # Time set config
	
	dock = load(str(inventory_slot_plugin_path,"/scenes/dock/ivt_slot.tscn")).instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL,dock)
	
	var _exp = EditorExportPlugin.new()
	_exp.set_script(load(str(inventory_slot_plugin_path,"/script/slot/export.gd")))
	add_export_plugin(_exp)

func _import_settings() -> void:
	var _path: String = get_script().resource_path.get_base_dir()
	
	if InventorySystem._get_settings_system() == {}:
		InventorySystem._create_file_system(0,_path)
	
	if !DirAccess.dir_exists_absolute(str(InventorySystem.get_save_path(),"/save")):
		var _file_system = InventorySystem._get_settings_system()
		
		InventorySystem._create_json_path(
			_path,
			_file_system.extension,
			true
		)
	
	InventorySystem._update_path()

func reload() -> void:
	remove_control_from_docks(dock)
	_ready_plugin()
