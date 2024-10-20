extends Button

@onready var inventory: Inventory_main = $"../Inventory_main"

@export_dir var items: Array[String] = [
	
]

func _pressed() -> void:
	inventory.add_item(inventory.panel_item.inventory,items[randi_range(0,items.size()-1)],randi_range(1,3))
