@tool
@icon("res://addons/inventory_slot_plugin/assets/icons/slot_panelslot.tres")

extends PanelContainer

class_name PanelSlot

## Emitido quando um novo item entra no painel.
signal item_entered(_item_inventory: Dictionary ,_item_panel: Dictionary)

## Emitido quando um item é descartado ou não existe mais. (Não emitido ao mover de um painel para outro)
signal item_exited(_item_inventory: Dictionary, _item_panel: Dictionary)

## Emitido quando qualquer item do painel é atualizado.
signal item_data_changed(_item_inventory: Dictionary, _item_panel: Dictionary)

## Emitido quando há um item sobrando. (Se o inventário estiver cheio, pode haver alguns itens que não cabem, e então o item e a quantidade restante são emitidos)
signal item_leftover(_item_inventory: Dictionary, _item_panel: Dictionary, amount: int)

## Emitido quando qualquer item é atualizado.
signal items_data_changed_global()

# Enumeração para definir o tipo de contêiner de slots
enum CONTAINER_SLOT {
	## Separa em grade.
	GRID,
	## Cria uma grade circular com os slots.
	WHEEL,
	## Divide a lista verticalmente.
	VBOX,
	## Divide a lista horizontalmente.
	HBOX
}

# Enumeração para definir o alinhamento do título
enum ALIGNMENT {LEFT, CENTER, RIGHT}

@export_group("Node Selector")
@export var next_system_slot: PanelSlot

@export_group("Panel Slot")
@export var slot_panel_id: int:
	set(value):
		slot_panel_id = value
		if !Engine.is_editor_hint():
			if Inventory == null: return
		
		update_visual_panel_slot()
		update_tittle_name()

@export_subgroup("Slot Mouse")
## Seleciona itens com um clique direito, permitindo pegar o item por uma unidade.
@export var use_right_click: bool = true
## Se verdadeiro, o item só pode ser movido enquanto o mouse estiver pressionado.
@export var press: bool

@export_subgroup("Slot Layout")
## Modo de alinhamento dos slots. Nem todas as configurações suportam alinhamento.
@export var container_slot: CONTAINER_SLOT:
	set(value):
		container_slot = value
		
		update_visual_panel_slot()
## Define o tamanho dos slots.
@export var size_slot: Vector2 = Vector2(64,64):
	set(value):
		size_slot = value
		
		update_visual_panel_slot()
## Define quantas colunas a grade deve ser criada para os slots.
## Observação: Isso só funcionará se container_slot estiver no modo Grid.
@export var columns_grid: float = 5.0:
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

@export_subgroup("Panel Tittle")
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

# Carregamento de scripts e cenas
const SCRIPT_SLOT: Script = preload("res://addons/inventory_slot_plugin/script/slot/slot_button.gd")
const ITEM_TEXTURE: PackedScene = preload("res://addons/inventory_slot_plugin/scenes/screen/item_texture.tscn")

# Nós do painel
var vbox_panel: VBoxContainer = VBoxContainer.new()
var grid_slot: Control
var name_label: Label = Label.new()

# Função chamada quando o nó é carregado
func _ready() -> void:
	
	update_visual_panel_slot()
	update_tittle()
	
	Inventory.changed_panel_data.connect(update_changed_panel_data)
	
	if !Engine.is_editor_hint():
		connect_signal_inventory()
		reload_item()

# Atualiza a visualização do painel de slots
func update_visual_panel_slot() -> void:
	InventorySystem._update_path()
	
	var _add: bool = false
	
	match container_slot:
		CONTAINER_SLOT.GRID:
			if grid_slot is GridContainer == false:
				if is_instance_valid(grid_slot):
					grid_slot.queue_free()
				
				grid_slot = GridContainer.new()
				_add = true
			
			grid_slot.columns = columns_grid
			grid_slot.add_theme_constant_override("h_separation", horizontal_separation)
			grid_slot.add_theme_constant_override("v_separation", vertical_separation)
		CONTAINER_SLOT.WHEEL:
			if grid_slot is WheelContainer == false:
				if is_instance_valid(grid_slot):
					grid_slot.queue_free()
				
				grid_slot = WheelContainer.new()
				_add = true
			
			grid_slot.wheel_size = Vector2(horizontal_separation, vertical_separation)
			grid_slot.wheel_rotation = columns_grid
		CONTAINER_SLOT.VBOX:
			if grid_slot is VBoxContainer == false:
				if is_instance_valid(grid_slot):
					grid_slot.queue_free()
				
				grid_slot = VBoxContainer.new()
				_add = true
			
			grid_slot.add_theme_constant_override("separation", horizontal_separation)
		CONTAINER_SLOT.HBOX:
			if grid_slot is HBoxContainer == false:
				if is_instance_valid(grid_slot):
					grid_slot.queue_free()
				
				grid_slot = HBoxContainer.new()
				_add = true
			
			grid_slot.add_theme_constant_override("separation", vertical_separation)
	
	if _add:
		_reset_slots()
		update_slots()

# Atualiza o título do painel
func update_tittle() -> void:
	if get_node_or_null("Tittle") == null:
		vbox_panel.add_child(name_label)
		vbox_panel.move_child(name_label, 0)
		name_label.name = "Tittle"
	
	update_tittle_alignment()
	
	name_label.uppercase = tittle_uppercase
	
	update_tittle_name()

# Atualiza o nome do título
func update_tittle_name() -> void:
	var _all_panel = InventoryFile.pull_inventory(Inventory.PANEL_SLOT_PATH)
	
	for _panel_slot in _all_panel:
		var _panel = _all_panel.get(_panel_slot)
		
		if _panel.id == slot_panel_id:
			name_label.text = _panel_slot

# Atualiza o alinhamento do título
func update_tittle_alignment() -> void:
	match tittle_alignment:
		ALIGNMENT.LEFT:
			name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		ALIGNMENT.CENTER:
			name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ALIGNMENT.RIGHT:
			name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

# Atualiza os slots
func update_slots() -> void:
	var _all_panel = InventoryFile.pull_inventory(Inventory.PANEL_SLOT_PATH)
	
	for panel_slot in _all_panel:
		var panel = _all_panel.get(panel_slot)
		
		if panel.id == slot_panel_id:
			_create_slot(panel.slot_amount)
			
			if !Engine.is_editor_hint():
				_load_items(InventoryFile.list_all_item_inventory(slot_panel_id))

# Recarrega os itens
func reload_item() -> void:
	
	if is_instance_valid(grid_slot):
		
		for _child in grid_slot.get_children():
			instance_slot_button(_child)
			
			if is_instance_valid(_child.item_node):
				await get_tree().create_timer(0.1).timeout
				
				item_entered.emit(
					_child.item_node.item_inventory,
					InventoryFile.search_item_id(slot_panel_id, _child.item_node.item_inventory.unique_id)
				)

# Recebe um novo item
func receive_new_item(item_panel: Dictionary, item_inventory: Dictionary, panel_slot: Dictionary) -> void:
	if panel_slot.id == slot_panel_id:
		_load_item(item_inventory)

# Cria os slots
func _create_slot(amount_size: int) -> void:
	
	for amount in amount_size:
		
		var slot_button: Button = Button.new()
		
		instance_slot_button(slot_button)
		
		grid_slot.add_child(slot_button)

# Carrega os itens
func _load_items(item_inventory_array: Array) -> void:
	
	for item_inventory in item_inventory_array:
		_load_item(item_inventory)

# Carrega um item
func _load_item(item_inventory: Dictionary) -> void:
	var new_item = ITEM_TEXTURE.instantiate()
	
	if item_inventory.slot == Inventory.ERROR.SLOT_BUTTON_VOID:
		await Inventory.get_child_count() == 0
		
		var void_button = Button.new()
		var slot = void_button
		
		instance_slot_button(void_button)
		
		slot.free_use = true
		slot.item_node = new_item
		slot.item_node.item_inventory = item_inventory
		
		slot.self_modulate.a = 0
		slot.z_index = 1
		
		new_item.panel_slot = InventoryFile.get_panel(-2)
		void_button.global_position = Vector2(99999, 99999)
		
		Inventory.add_child(void_button)
		slot.add_child(new_item)
		
		Inventory.button_slot_changed.emit(slot, true)
	else:
		var slot = grid_slot.get_child(item_inventory.slot)
		
		slot.press = press
		slot.use_right_click = use_right_click
		
		slot.item_node = new_item
		slot.item_node.item_inventory = item_inventory
		slot.item_node.panel_slot = InventoryFile.get_panel(slot_panel_id)
		
		slot.add_child(new_item)

# Reseta os slots
func _reset_slots() -> void:
	if get_node_or_null("VboxPanel") == null:
		add_child(vbox_panel)
	
	vbox_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid_slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	vbox_panel.add_child(grid_slot)
	
	vbox_panel.name = "VboxPanel"
	grid_slot.name = "GridSlot"

# Instancia o botão do slot
func instance_slot_button(slot_button: Button) -> void:
	if !Engine.is_editor_hint():
		slot_button.set_script(SCRIPT_SLOT)
		slot_button.my_panel = self
		slot_button.panel_id = slot_panel_id
		
		slot_button.press = press
		slot_button.use_right_click = use_right_click
	
	slot_button.custom_minimum_size = size_slot
	slot_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	slot_button.focus_mode = Control.FOCUS_NONE

# Atualiza os dados do painel
func update_changed_panel_data() -> void:
	update_visual_panel_slot()
	for child in grid_slot.get_children():
		child.queue_free()
	update_slots()
	update_tittle_name()

# Conecta os sinais do inventário
func connect_signal_inventory() -> void:
	Inventory.new_item.connect(receive_new_item)
	
	Inventory.new_item.connect(_new_item)
	Inventory.new_data.connect(_new_data)
	Inventory.discart_item.connect(_discart_item)
	Inventory.new_data_global.connect(_new_data_global)
	Inventory.item_leftlover.connect(_item_leftlover)

# Funções para lidar com os sinais do inventário
func _new_data(item_panel: Dictionary , item_inventory: Dictionary, system_slot: Dictionary) -> void:
	if system_slot.id == slot_panel_id:
		item_data_changed.emit(item_inventory, item_panel)
func _new_item(item_panel: Dictionary , item_inventory: Dictionary, system_slot: Dictionary) -> void:
	if system_slot.id == slot_panel_id:
		item_entered.emit(item_inventory, item_panel)
func _discart_item(item_panel: Dictionary , item_inventory: Dictionary , system_slot: Dictionary) -> void:
	if system_slot.id == slot_panel_id:
		item_exited.emit(item_inventory, item_panel)
func _item_leftlover(item_panel: Dictionary , item_inventory: Dictionary , amount) -> void:
	item_leftover.emit(item_inventory, item_panel)
func _new_data_global() -> void:
	items_data_changed_global.emit()