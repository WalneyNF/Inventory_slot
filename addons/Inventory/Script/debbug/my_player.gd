extends Node

@onready var inventory: Inventory_main = $"../Inventory_main"

func _on_inventory_main_item_entered_panel(item: Variant, new_type: Variant) -> void:
	print("Entrou : ",inventory.TYPE_SLOT.keys()[new_type])


func _on_inventory_main_item_exiting_panel(item: Variant, new_type: Variant) -> void:
	print("Saiu : ",inventory.TYPE_SLOT.keys()[new_type])
