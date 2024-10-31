@tool
extends PanelContainer

@onready var panels: VBoxContainer = $Scroll/Panels

const SLOT_ALL = preload("res://addons/inventory_slot_plugin/scenes/dock/slot_all.tscn")
const THEME_DEFAULT = preload("res://addons/inventory_slot_plugin/assets/themes/default.tres")


func _ready() -> void:
	var new_slotall = SLOT_ALL.instantiate()
	
	panels.add_child(new_slotall)

func _on_reload_plugin_pressed() -> void:
	panels.get_child(1).queue_free()
	
	_ready()


func _on_remove_theme_pressed() -> void:
	if theme == null:
		theme = THEME_DEFAULT
		
		return
	
	theme = null
