@tool

extends VBoxContainer

var class_panel: PackedScene = preload("res://addons/inventory_slot_plugin/scenes/dock/class.tscn")


func _on_ui_items_change_class() -> void:
	for child in get_children():
		child.queue_free()
	
	var inventory = InventoryFile.pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	for _class in inventory:
		var new_panel = class_panel.instantiate()
		
		add_child(new_panel)
		new_panel._start(str(_class))
