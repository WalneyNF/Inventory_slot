extends Node


func _on_inventory_main_item_entered_panel(item: Variant, new_type: Variant) -> void:
	print("Entrou : ",Inventory.get_panel_id(new_type).panel_name)


func _on_inventory_main_item_exiting_panel(item: Variant, new_type: Variant) -> void:
	print("Saiu : ",Inventory.get_panel_id(new_type).panel_name)
