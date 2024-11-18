@tool

extends EditorPlugin

var dock 

func _enter_tree() -> void:
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
	start()

func start() -> void:
	var inventory_slot_plugin_path = str(get_script().resource_path).get_base_dir()
	
	dock = load("res://addons/inventory_slot_plugin/scenes/dock/ivt_slot.tscn").instantiate()
	
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL,dock)
	add_autoload_singleton("Inventory","res://addons/inventory_slot_plugin/script/slot/inventory.gd")


func reload() -> void:
	remove_control_from_docks(dock)
	start()

func _exit_tree():
	remove_control_from_docks(dock)
	dock.free()
