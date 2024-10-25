@tool

extends VBoxContainer

var path = "res://addons/inventory_biely/json/inventory.json"

var class_panel = preload("res://addons/inventory_biely/scenes/dock/class.tscn")


func _on_ui_items_change_class() -> void:
	for child in get_children():
		child.queue_free()
	
	var file = FileAccess.open(path,FileAccess.READ)
	var all_class = JSON.parse_string(file.get_as_text())
	
	file.close()
	
	for _class in all_class:
		var new_panel = class_panel.instantiate()
		
		add_child(new_panel)
		new_panel._start(str(_class))
