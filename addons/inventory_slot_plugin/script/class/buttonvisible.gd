@icon("res://addons/inventory_slot_plugin/assets/icons/slot_buttonvisible.tres")
@tool

class_name ButtonVisible extends Button

@export var NodeVisible: Control
@export var icon_use: bool = true
@export var no_focus_hide: bool = false


const SLOT_BUTTON = [
	preload("res://addons/inventory_slot_plugin/assets/icons/slot_hide_button.tres"),
	preload("res://addons/inventory_slot_plugin/assets/icons/slot_show_button.tres")
]

func _ready() -> void:
	await get_tree().create_timer(0.2).timeout
	
	if icon_use: icon = SLOT_BUTTON[int(NodeVisible.visible)]
	if no_focus_hide: focus_exited.connect(no_focus)

func _pressed() -> void:
	NodeVisible.visible = !NodeVisible.visible
	
	if icon_use: icon = SLOT_BUTTON[int(NodeVisible.visible)]

func no_focus() -> void:
	NodeVisible.hide()
