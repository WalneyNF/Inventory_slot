extends Button

@onready var inventory: Inventory_main = $"../../Inventory_main"

@export_file var items: Array[String] = [
	
]

func _pressed() -> void:
	inventory.add_item(inventory.panel.panel_item[0],items[randi_range(0,items.size()-1)],randi_range(1,3))
