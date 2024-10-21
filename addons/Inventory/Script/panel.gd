extends PanelContainer

@export_category("Node Selector")
@export var slot_panel_id: int
@export var inventory: Inventory_main
@export var grid_slot: Control
@export_node_path() var next_system_slot

@export_group("Slot Settings")
@export var size_slot: Vector2 = Vector2(64,64)

const SCRIPT_SLOT: Script = preload("res://addons/Inventory/Script/Slot_item_button.gd")
const ITEM_TEXTURE: PackedScene = preload("res://addons/Inventory/Scenes/Screen/item_texture.tscn")


func _ready() -> void:
	inventory.new_item.connect(receive_new_item)
	
	for panel_slot in inventory.panel.panel_item:
		
		if panel_slot.id == slot_panel_id:
			_create_slot(panel_slot.max_slot)
			_load_items(panel_slot.items)


func receive_new_item(item: ItemResource, panel_id: int) -> void:
	
	if panel_id == slot_panel_id:
		_load_item(item)


func _create_slot(amount_size: int) -> void:
	
	for amount in amount_size:
		
		var slot_button: Button = Button.new()
		
		instance_slot_button(slot_button)
		
		grid_slot.add_child(slot_button)


func _load_items(item_array: Array) -> void:
	
	for item in item_array:
		_load_item(item)


func _load_item(item: ItemResource) -> void:
	var new_item = ITEM_TEXTURE.instantiate()
	
	if item.slot == inventory.SLOT_BUTTON_VOID:
		if inventory.get_child_count() == 0:
			
			var void_button = Button.new()
			var slot = void_button
			instance_slot_button(void_button)
			
			slot.free_use = true
			slot.inventory = inventory
			slot.item_node = new_item
			slot.item_node.inventory = inventory
			slot.item_node.item = item
			slot.self_modulate.a = 0
			
			inventory.add_child(void_button)
			slot.add_child(new_item)
			
			inventory.button_slot_changed.emit(slot,true)
	else:
		var slot = grid_slot.get_child(item.slot)
		
		slot.inventory = inventory
		slot.item_node = new_item
		slot.item_node.inventory = inventory
		slot.item_node.item = item
		
		slot.add_child(new_item)


func instance_slot_button(slot_button: Button) -> void:
	slot_button.set_script(SCRIPT_SLOT)
	
	slot_button.button_mask = MOUSE_BUTTON_MASK_RIGHT | MOUSE_BUTTON_MASK_LEFT
	slot_button.custom_minimum_size = size_slot
	slot_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	slot_button.focus_mode = Control.FOCUS_NONE
	slot_button.inventory = inventory
	slot_button.my_panel = self
	slot_button.panel_id = slot_panel_id
