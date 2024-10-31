@tool

extends EditorPlugin

var dock 

func _enter_tree() -> void:
	
	start()

func start() -> void:
	dock = load("res://addons/inventory_slot_plugin/scenes/dock/ivt_slot.tscn").instantiate()
	
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL,dock)
	add_autoload_singleton("Inventory","res://addons/inventory_slot_plugin/script/inventory.gd")


func reload() -> void:
	remove_control_from_docks(dock)
	start()

func _exit_tree():
	# Clean-up of the plugin goes here.
	# Remove the dock.
	remove_control_from_docks(dock)
	# Erase the control from the memory.
	dock.free()
