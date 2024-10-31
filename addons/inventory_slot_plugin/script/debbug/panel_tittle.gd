extends Label

@export var panel: PanelContainer

func _ready() -> void:
	text = Inventory.get_panel_id(panel.slot_panel_id).panel_name
