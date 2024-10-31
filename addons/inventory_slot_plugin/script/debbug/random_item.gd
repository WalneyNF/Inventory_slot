@tool
extends Button

var items = []

func _ready() -> void:
	items = TypePanel.list_all_item()

func _pressed() -> void:
	Inventory.add_item(1,items[randi_range(0,items.size()-1)].unique_id,randi_range(1,3))
