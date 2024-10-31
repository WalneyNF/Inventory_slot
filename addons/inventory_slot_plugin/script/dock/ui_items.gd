@tool

extends Control

signal change_class

@onready var list_class: VBoxContainer = %ListClass

var file

func _ready() -> void:
	
	if !FileAccess.file_exists(TypePanel.ITEM_PATH):
		
		TypePanel.push_inventory({"void": {}})
	
	change_class.emit()

func _on_new_class_pressed() -> void:
	if FileAccess.file_exists(TypePanel.ITEM_PATH):
		file = FileAccess.open(TypePanel.ITEM_PATH,FileAccess.READ)
		
		var items: Dictionary = JSON.parse_string(file.get_as_text())
		file.close()
		
		items[str("new_class_",items.size())] = {}
		
		file = FileAccess.open(TypePanel.ITEM_PATH,FileAccess.WRITE)
		file.store_string(JSON.stringify(items, "\t"))
		file.close()
	
	change_class.emit()
