@tool
extends PanelContainer

const PANEL_SLOT = preload("res://addons/inventory_slot_plugin/scenes/dock/panel_slot.tscn")

@onready var panel_list: VBoxContainer = %PanelList

func _ready() -> void:
	if !InventoryFile.is_json(Inventory.PANEL_SLOT_PATH):
		var new_panel = {
			"Void": {
				"class_unique": "all",
				"id": -2,
				"slot_amount": 15
			}
		}
		
		
		InventoryFile.push_inventory(new_panel,Inventory.PANEL_SLOT_PATH)
	
	update_panel()


func _on_create_panel_pressed() -> void:
	var all_panel_slot = InventoryFile.pull_inventory(Inventory.PANEL_SLOT_PATH)
	
	all_panel_slot[str("NewPanel_",all_panel_slot.size()-1)] = {
			"id" : all_panel_slot.size()-1,
			"slot_amount" : 4,
			"class_unique" : "all",
			}
	
	InventoryFile.push_inventory(all_panel_slot,Inventory.PANEL_SLOT_PATH)
	
	update_panel()

func update_panel() -> void:
	for child in panel_list.get_children():
		child.queue_free()
	
	var _all_panel = InventoryFile.pull_inventory(Inventory.PANEL_SLOT_PATH)
	
	for _panel_name in _all_panel:
		var _panel = _all_panel.get(_panel_name)
		
		if _panel.id == Inventory.ERROR.SLOT_BUTTON_VOID: continue
		
		var new_panel = PANEL_SLOT.instantiate()
		
		panel_list.add_child(new_panel)
		
		new_panel.panel_slot_controller = self
		new_panel.start(_panel_name,_panel.id,_panel.slot_amount,_panel.class_unique)
