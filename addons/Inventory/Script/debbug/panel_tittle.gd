extends Label

@export var panel: PanelContainer
@export var inventory: Inventory_main

func _ready() -> void:
	text = inventory.get_panel_id(panel.slot_panel_id).panel_name
