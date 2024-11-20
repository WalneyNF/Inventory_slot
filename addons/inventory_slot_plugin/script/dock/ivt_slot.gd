@tool
extends PanelContainer

@onready var panels: VBoxContainer = $Scroll/Panels
@onready var remove_theme: Button = %RemoveTheme
@onready var save_inventory: Button = %SaveInventory
@onready var documentation: PanelContainer = $Documentation

var POPUP = load(str(Inventory.PLUGIN_PATH,"/scenes/dock/popup.tscn"))
var SLOT_ALL = load(str(Inventory.PLUGIN_PATH,"/scenes/dock/slot_all.tscn"))
var THEME_DEFAULT = load(str(Inventory.PLUGIN_PATH,"/assets/themes/default.tres"))
var SLOT_THEME_DEFAULT = load(str(Inventory.PLUGIN_PATH,"/assets/icons/slot_theme_default.tres"))
var SLOT_THEME_GODOT = load(str(Inventory.PLUGIN_PATH,"/assets/icons/slot_theme_godot.tres"))
var SLOT_UNSAVE_INVENTORY = load(str(Inventory.PLUGIN_PATH,"/assets/icons/slot_unsave_inventory.tres"))
var SLOT_SAVE_INVENTORY = load(str(Inventory.PLUGIN_PATH,"/assets/icons/slot_save_inventory.tres"))

func _ready() -> void:
	Inventory.reload_dock.connect(reload)
	
	generate()

func generate() -> void:
	var new_slotall = SLOT_ALL.instantiate()
	
	panels.add_child(new_slotall)

func reload() -> void:
	panels.get_child(2).queue_free()
	
	generate()


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


func _on_document_pressed() -> void:
	documentation.show()


func _on_top_pressed() -> void:
	documentation.hide()
