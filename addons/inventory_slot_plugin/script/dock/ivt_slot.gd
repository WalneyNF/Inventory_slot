@tool
extends PanelContainer

@onready var panels: VBoxContainer = $Scroll/Panels
@onready var remove_theme: Button = %RemoveTheme
@onready var save_inventory: Button = %SaveInventory

const POPUP = preload("res://addons/inventory_slot_plugin/scenes/dock/popup.tscn")
const SLOT_ALL = preload("res://addons/inventory_slot_plugin/scenes/dock/slot_all.tscn")
const THEME_DEFAULT = preload("res://addons/inventory_slot_plugin/assets/themes/default.tres")
const SLOT_THEME_DEFAULT = preload("res://addons/inventory_slot_plugin/assets/icons/slot_theme_default.tres")
const SLOT_THEME_GODOT = preload("res://addons/inventory_slot_plugin/assets/icons/slot_theme_godot.tres")
const SLOT_UNSAVE_INVENTORY = preload("res://addons/inventory_slot_plugin/assets/icons/slot_unsave_inventory.tres")
const SLOT_SAVE_INVENTORY = preload("res://addons/inventory_slot_plugin/assets/icons/slot_save_inventory.tres")

func _ready() -> void:
	
	var new_slotall = SLOT_ALL.instantiate()
	
	panels.add_child(new_slotall)

func reload() -> void:
	panels.get_child(2).queue_free()
	
	_ready()


func _on_reload_plugin_pressed() -> void:
	reload()

func _on_remove_theme_pressed() -> void:
	if theme == null:
		theme = THEME_DEFAULT
		remove_theme.icon = SLOT_THEME_DEFAULT
		return
	
	remove_theme.icon = SLOT_THEME_GODOT
	theme = null


func _on_delete_inventory_pressed() -> void:
	var popup = POPUP.instantiate()
	
	add_child(popup)
	
	popup.start(
		"Do you really want to remove all the items from the inventory?",
		"No",
		"Yes"
	)
	
	popup.ok.connect(remove_all_item_inventory)


func remove_all_item_inventory() -> void:
	InventoryFile.remove_all_item_inventory()


func _on_save_inventory_pressed() -> void:
	save_inventory.icon
