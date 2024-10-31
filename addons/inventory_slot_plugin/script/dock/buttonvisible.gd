@tool

class_name ButtonVisible extends Button

@export var NodeVisible: Control


const SLOT_BUTTON = [
	preload("res://addons/inventory_slot_plugin/assets/icons/slot_hide_button.tres"),
	preload("res://addons/inventory_slot_plugin/assets/icons/slot_show_button.tres")
]

func _ready() -> void:
	await get_tree().create_timer(0.2).timeout
	icon = SLOT_BUTTON[int(NodeVisible.visible)]

func _pressed() -> void:
	NodeVisible.visible = !NodeVisible.visible
	
	icon = SLOT_BUTTON[int(NodeVisible.visible)]
