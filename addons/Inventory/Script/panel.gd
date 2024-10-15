extends PanelContainer

@export_category("Node Selector")
@export var slot_type: Inventory_main.TYPE_SLOT
@export var inventory_main: Inventory_main
@export var grid_slot: GridContainer
@export_node_path() var next_system_slot

@export_group("Slot Settings")
@export var size_slot: Vector2 = Vector2(64,64)

const SCRIPT_SLOT: Script = preload("res://addons/Inventory/Script/Slot_item_button.gd")
const ITEM_TEXTURE: PackedScene = preload("res://addons/Inventory/Scenes/Screen/item_texture.tscn")


func _ready() -> void:
	inventory_main.new_item.connect(receive_new_item)
	
	for panel_slot in inventory_main.panel_item:
		var panel = inventory_main.panel_item.get(panel_slot)
		
		if panel.type == slot_type:
			_create_slot(panel.max_slot)
			_load_items(panel.items)


func receive_new_item(item: Dictionary, type: int) -> void:
	
	if type == slot_type:
		_load_item(item)


func _create_slot(amount_size: int) -> void:
	
	for amount in amount_size:
		
		var slot_button: Button = Button.new()
		
		instance_slot_button(slot_button)
		
		grid_slot.add_child(slot_button)


func _load_items(item_array: Array) -> void:
	
	for item in item_array:
		_load_item(item)


func _load_item(item: Dictionary) -> void:
	
	var new_item = ITEM_TEXTURE.instantiate()
	
	if item.slot == inventory_main.SLOT_BUTTON_VOID:
		if inventory_main.get_child_count() == 0:
			
			var void_button = Button.new()
			var slot = void_button
			instance_slot_button(void_button)
			
			slot.free_use = true
			slot.inventory = inventory_main
			slot.item_node = new_item
			slot.item_node.inventory = inventory_main
			slot.item_node.item = item
			slot.self_modulate.a = 0
			
			inventory_main.add_child(void_button)
			slot.add_child(new_item)
			
			inventory_main.button_slot_changed.emit(slot,true)
	else:
		var slot = grid_slot.get_child(item.slot)
		
		slot.inventory = inventory_main
		slot.item_node = new_item
		slot.item_node.inventory = inventory_main
		slot.item_node.item = item
		
		slot.add_child(new_item)




func instance_slot_button(slot_button: Button) -> void:
	slot_button.set_script(SCRIPT_SLOT)
	
	slot_button.button_mask = MOUSE_BUTTON_MASK_RIGHT | MOUSE_BUTTON_MASK_LEFT
	slot_button.custom_minimum_size = size_slot
	slot_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	slot_button.focus_mode = Control.FOCUS_NONE
	slot_button.inventory = inventory_main
	slot_button.type = slot_type
