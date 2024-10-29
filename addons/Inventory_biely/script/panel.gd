@tool

extends PanelContainer

class_name PanelSlot

enum CONTAINER_SLOT {
	## Separa em blocos.
	GRID,
	## Cria um circulo com os slots.
	WHEEL,
	## Separa em lista na vertical.
	VBOX,
	## Separa em lista na horizontalpp.
	HBOX
}

enum ALIGNMENT {LEFT, CENTER, RIGHT}

@export_group("Node Selector")
@export var next_system_slot: PanelSlot

@export_group("Panel Slot")
@export var slot_panel_id: int:
	set(value):
		slot_panel_id = value
		if !Engine.is_editor_hint():
			if Inventory == null: return
		
		update_tittle_name()

@export_subgroup("Slot")
## Modo de alinhamento dos Slots. Nem todas as configurações são compativeis com o alinhamento.
@export var container_slot: CONTAINER_SLOT:
	set(value):
		container_slot = value
		update_visual_panel_slot()
## Define o tamanho do slots.
@export var size_slot: Vector2 = Vector2(64,64):
	set(value):
		size_slot = value
		update_visual_panel_slot()
## Define em quantas colunas o grid irar criar para os slots.
## Obs: Só irar funcionar caso o container_slot esteja em modo Grid.
@export var columns_grid: int = 5:
	set(value):
		columns_grid = value
		update_visual_panel_slot()
@export var horizontal_separation: float = 2:
	set(value):
		horizontal_separation = value
		update_visual_panel_slot()
@export var vertical_separation: float = 2:
	set(value):
		vertical_separation = value
		update_visual_panel_slot()



@export_subgroup("Tittle")
@export var show_panel_tittle: bool = true:
	set(value):
		show_panel_tittle = value
		name_label.visible = show_panel_tittle
@export var tittle_alignment: ALIGNMENT:
	set(value):
		tittle_alignment = value
		update_tittle_alignment()
@export var tittle_uppercase: bool:
	set(value):
		tittle_uppercase = value
		name_label.uppercase = tittle_uppercase

const SCRIPT_SLOT: Script = preload("res://addons/inventory_biely/script/slot_item_button.gd")
const ITEM_TEXTURE: PackedScene = preload("res://addons/inventory_biely/scenes/screen/item_texture.tscn")


var vbox_panel: VBoxContainer = VBoxContainer.new()
var grid_slot: Control
var name_label: Label = Label.new()


func _ready() -> void:
	
	update_visual_panel_slot()
	update_tittle()
	
	if !Engine.is_editor_hint():
		Inventory.new_item.connect(receive_new_item)


## Visual ================================================
func update_visual_panel_slot() -> void:
	
	for child in vbox_panel.get_children():
		if child is Container:
			child.queue_free()
	
	match container_slot:
		CONTAINER_SLOT.GRID:
			grid_slot = GridContainer.new()
			grid_slot.columns = columns_grid
			grid_slot.add_theme_constant_override("h_separation",horizontal_separation)
			grid_slot.add_theme_constant_override("v_separation",vertical_separation)
		CONTAINER_SLOT.WHEEL:
			grid_slot = WheelContainer.new()
			grid_slot.wheel_size = Vector2(horizontal_separation,vertical_separation)
			grid_slot.wheel_rotation = columns_grid
			
		CONTAINER_SLOT.VBOX:
			grid_slot = VBoxContainer.new()
			grid_slot.add_theme_constant_override("separation",horizontal_separation)
		CONTAINER_SLOT.HBOX:
			grid_slot = HBoxContainer.new()
			grid_slot.add_theme_constant_override("separation",vertical_separation)
	
	
	if get_node_or_null("VboxPanel") == null:
		add_child(vbox_panel)
	
	vbox_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid_slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	vbox_panel.add_child(grid_slot)
	
	vbox_panel.name = "VboxPanel"
	grid_slot.name = "GridSlot"
	
	#if !Engine.is_editor_hint(): return
	
	update_slots()


func update_tittle() -> void:
	if get_node_or_null("Tittle") == null:
		vbox_panel.add_child(name_label)
		vbox_panel.move_child(name_label,0)
		name_label.name = "Tittle"
	
	update_tittle_alignment()
	
	name_label.uppercase = tittle_uppercase
	
	update_tittle_name()


func update_tittle_name() -> void:
	var all_panel = Inventory.get_all_panels()
	
	for panel_slot in all_panel:
		var panel = all_panel.get(panel_slot)
		
		if panel.id == slot_panel_id:
			name_label.text = panel_slot


func update_tittle_alignment() -> void:
	match tittle_alignment:
		ALIGNMENT.LEFT:
			name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		ALIGNMENT.CENTER:
			name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ALIGNMENT.RIGHT:
			name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT


func update_slots() -> void: # Mudar
	var all_panel = Inventory.get_all_panels()
	
	for panel_slot in all_panel:
		var panel = all_panel.get(panel_slot)
		#print(panel.id == slot_panel_id)
		if panel.id == slot_panel_id:
			_create_slot(panel.slot_amount)
			
			if !Engine.is_editor_hint():
				_load_items(TypePanel.list_all_inventory_item(slot_panel_id))


## Slots System ====================================

func receive_new_item(item_panel: Dictionary, item_inventory: Dictionary, panel_slot: Dictionary) -> void:
	if panel_slot.id == slot_panel_id:
		_load_item(item_inventory)


func _create_slot(amount_size: int) -> void:
	
	for amount in amount_size:
		
		var slot_button: Button = Button.new()
		
		instance_slot_button(slot_button)
		
		grid_slot.add_child(slot_button)


func _load_items(item_inventory_array: Array) -> void:
	
	for item_inventory in item_inventory_array:
		_load_item(item_inventory)


func _load_item(item_inventory: Dictionary) -> void:
	var new_item = ITEM_TEXTURE.instantiate()
	
	if item_inventory.slot == Inventory_main.ERROR.SLOT_BUTTON_VOID:
		await Inventory.get_child_count() == 0
		
		var void_button = Button.new()
		var slot = void_button
		
		instance_slot_button(void_button)
		
		slot.free_use = true
		slot.item_node = new_item
		slot.item_node.item_inventory = item_inventory
		slot.self_modulate.a = 0
		new_item.panel_slot = Inventory.get_panel_id(-2)
		
		Inventory.add_child(void_button)
		slot.add_child(new_item)
		
		Inventory.button_slot_changed.emit(slot,true)
	else:
		var slot = grid_slot.get_child(item_inventory.slot)
		
		slot.item_node = new_item
		slot.item_node.item_inventory = item_inventory
		slot.item_node.panel_slot = Inventory.get_panel_id(slot_panel_id)
		
		slot.add_child(new_item)


func instance_slot_button(slot_button: Button) -> void:
	if !Engine.is_editor_hint():
		slot_button.set_script(SCRIPT_SLOT)
		slot_button.my_panel = self
		slot_button.panel_id = slot_panel_id
	
	slot_button.button_mask = MOUSE_BUTTON_MASK_RIGHT | MOUSE_BUTTON_MASK_LEFT
	slot_button.custom_minimum_size = size_slot
	slot_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	slot_button.focus_mode = Control.FOCUS_NONE
