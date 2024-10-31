@tool
extends PanelContainer

const PANEL_SLOT = preload("res://addons/inventory_slot_plugin/scenes/dock/panel_slot.tscn")

@onready var panel_list: VBoxContainer = %PanelList


func _ready() -> void:
	if !TypePanel.is_json(TypePanel.PANEL_SLOT_PATH):
		var new_panel = {
			"Void": {
				"class_unique": -1,
				"id": -2,
				"slot_amount": 15
			}
		}
		
		
		TypePanel.push_inventory(new_panel,TypePanel.PANEL_SLOT_PATH)
	
	update_panel()


func _on_create_panel_pressed() -> void:
	var all_panel_slot = TypePanel.pull_inventory(TypePanel.PANEL_SLOT_PATH)
	
	all_panel_slot[str("NewPanel_",all_panel_slot.size())] = {
			"id" : all_panel_slot.size(),
			"slot_amount" : 4,
			"class_unique" : -1,
			}
	
	TypePanel.push_inventory(all_panel_slot,TypePanel.PANEL_SLOT_PATH)
	
	update_panel()

func update_panel() -> void:
	for child in panel_list.get_children():
		child.queue_free()
	
	var panel = TypePanel.pull_inventory(TypePanel.PANEL_SLOT_PATH)
	
	for i in panel:
		if i == "Void":
			return
		
		var new_panel = PANEL_SLOT.instantiate()
		
		panel_list.add_child(new_panel)
		
		new_panel.start(i,panel.get(i).id,panel.get(i).slot_amount,panel.get(i).class_unique)
	
