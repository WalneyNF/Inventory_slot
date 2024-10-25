@tool

extends Control

signal change_class

@onready var list_class: VBoxContainer = $Panel/Scroll/Vbox/ItemBar/Items/Scroll/ListClass

var path = "res://addons/inventory_biely/json/inventory.json"
var file

func _ready() -> void:
	
	if !FileAccess.file_exists(path):
		file = FileAccess.open(path,FileAccess.WRITE)
		
		file.store_string(JSON.stringify({"void": {}}))
		file.close()
	else:
		var feature_profile := EditorFeatureProfile.new()
		feature_profile.set_disable_class("TypePanel", true)
	
	change_class.emit()

func _on_new_class_pressed() -> void:
	if FileAccess.file_exists(path):
		file = FileAccess.open(path,FileAccess.READ)
		
		var items: Dictionary = JSON.parse_string(file.get_as_text())
		file.close()
		
		items[str("new_class_",items.size())] = {}
		
		file = FileAccess.open(path,FileAccess.WRITE)
		file.store_string(JSON.stringify(items, "\t"))
		file.close()
	
	change_class.emit()
