extends Control

@onready var inventory: Inventory_main = $Inventory_main

func slot_changed(slot: Button, move: bool) -> void:
	
	set_process(is_instance_valid(slot) and move == true)


func _ready() -> void:
	set_process(false)
	
	inventory.slot_changed.connect(slot_changed)


func _process(delta: float) -> void:
	inventory.item_selected.global_position = get_global_mouse_position() - (inventory.item_selected.size/2)
