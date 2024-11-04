@tool

extends Control

signal change_class

@onready var list_class: VBoxContainer = %ListClass

var file

func _ready() -> void:
	if !InventoryFile.is_json(InventoryFile.ITEM_PANEL_PATH):
		
		InventoryFile.push_inventory(InventoryFile.new_class("new_class"), InventoryFile.ITEM_PANEL_PATH)
	
	change_class.emit()

func _on_new_class_pressed() -> void:
	
	if InventoryFile.is_json(InventoryFile.ITEM_PANEL_PATH):
		
		file = FileAccess.open(InventoryFile.ITEM_PANEL_PATH,FileAccess.READ)
		
		var items: Dictionary = JSON.parse_string(file.get_as_text())
		file.close()
		
		var _new_class = InventoryFile.new_class(str("new_class_",items.size()))
		
		InventoryFile.push_inventory(_new_class, InventoryFile.ITEM_PANEL_PATH)
	else:
		InventoryFile.push_inventory(InventoryFile.new_class("new_class"), InventoryFile.ITEM_PANEL_PATH)
	
	change_class.emit()
