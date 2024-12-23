extends Button

# Referência ao nó do item associado a este botão
var item_node: Node

# Referência ao painel que contém este botão
var my_panel: PanelContainer

# ID do painel ao qual este botão está associado
var panel_id: int

# Indica se este botão pode ser liberado ou não
var free_use: bool

# Controla se o clique com o botão direito do mouse está habilitado
var use_right_click: bool:
	set(value):
		if value:
			button_mask = MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_RIGHT
		else:
			button_mask = MOUSE_BUTTON_MASK_LEFT
		use_right_click = value

# Indica se o botão direito do mouse está pressionado
var right_mouse: bool

# Indica se o botão esquerdo do mouse está pressionado
var left_mouse: bool

# Indica se o botão está pressionado
var press: bool

# Função chamada quando o nó é carregado
func _ready() -> void:
	# Conecta sinais para detectar quando um filho entra ou sai da árvore
	child_exiting_tree.connect(exit_child)
	child_entered_tree.connect(enter_child)
	
	# Conecta sinais para detectar quando o botão é pressionado ou solto
	button_down.connect(_button_down)
	button_up.connect(_button_up)
	
	# Conecta sinais para detectar quando o mouse entra ou sai do botão
	mouse_exited.connect(_mouse_exited)
	mouse_entered.connect(_mouse_entered)
	
	# Desativa o processamento de entrada inicialmente
	set_process_input(false)

# Função chamada para processar eventos de entrada
func _input(_event: InputEvent) -> void:
	if _event is InputEventMouseButton or _event is InputEventMouseMotion:
		
		# Verifica se o botão direito do mouse está pressionado e se está habilitado
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and use_right_click:
			right_mouse = true
			
		# Verifica se o botão esquerdo do mouse está pressionado
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			left_mouse = true
		
		else:
			# Verifica se há um item selecionado e se o botão esquerdo do mouse está pressionado
			if is_instance_valid(Inventory.item_selected):
				if left_mouse and (Inventory.item_selected.get_parent().press or press):
					_get_item()
			
			left_mouse = false

# Função chamada quando o botão é pressionado
func _button_down() -> void:
	if press:
		# Se nenhum item estiver selecionado, define o item
		if !is_instance_valid(Inventory.item_selected):
			_set_item()

# Função chamada quando o botão é solto
func _button_up() -> void:
	var _item_valid: bool = is_instance_valid(Inventory.item_selected)
	
	if press:
		# Se o item selecionado for o mesmo que o item associado a este botão, reseta
		if _item_valid:
			if Inventory.item_selected == item_node:
				reset()
		return
	
	# Realiza a ação principal
	_action()

# Função chamada quando o mouse entra no botão
func _mouse_entered() -> void:
	set_process_input(true)

# Função chamada quando o mouse sai do botão
func _mouse_exited() -> void:
	left_mouse = false
	right_mouse = false
	set_process_input(false)

# Função principal que realiza a ação do botão
func _action() -> void:
	if is_instance_valid(Inventory.item_selected):
		_get_item()
	else:
		_set_item()

# Função para definir o item no slot
func _set_item() -> void:
	if shift_item_move(): return
	
	if is_instance_valid(item_node):
		if right_mouse:
			set_item_right_mouse()
			return
		set_main_item()

# Função para pegar o item do slot
func _get_item() -> void:
	if !is_unique_class(): return
	
	if is_instance_valid(item_node):
		
		if right_mouse:
			
			if Inventory.item_selected.item_inventory.unique_id == item_node.item_inventory.unique_id:
				
				changed_item_right(Inventory.item_selected.item_inventory)
			
			right_mouse = false
			return
		
		if item_node == Inventory.item_selected:
			reset()
		else:
			if for_the_same_item(): return
			
			item_changed_other_slot()
		
	else:
		item_move_void_slot()

# Função chamada quando um filho entra na árvore
func enter_child(node: Node) -> void:
	if node is TextureRect:
		await node.get_tree().create_timer(0.2).timeout
		
		if is_instance_valid(node): tooltip_text = node.item_more()

# Função chamada quando um filho sai da árvore
func exit_child(node: Node) -> void:
	if node is TextureRect:
		tooltip_text = ""
	
	if free_use:
		queue_free()

# Função para resetar o botão
func reset() -> void:
	Inventory.button_slot_changed.emit(self,false)
	item_node.position = Vector2()

# Função para definir o item principal no slot
func set_main_item() -> void:
	Inventory.button_slot_changed.emit(self,true)
	item_node.z_index = 1

# Função para mover o item para um slot vazio
func item_move_void_slot() -> void:
	
	var _one_item = Inventory.item_selected.item_inventory
	
	var _item_selected_panel = InventoryFile.get_panel(_one_item.panel_id)
	
	if _item_selected_panel.id != panel_id:
		Inventory.set_panel_item(_one_item.id ,_item_selected_panel.id ,panel_id ,get_index() ,true )
	else:
		Inventory.set_slot_item(_item_selected_panel ,_one_item ,get_index() ,true )
	
	Inventory.item_selected.queue_free()
	Inventory.button_slot_changed.emit(self,false)

# Função para trocar o item com outro slot
func item_changed_other_slot() -> void:
	var _one_item = Inventory.item_selected.item_inventory
	var _two_item = item_node.item_inventory
	
	var _one_item_panel_id = Inventory.search_panel_id_item(_one_item.id)
	var _two_item_panel_id = Inventory.search_panel_id_item(_two_item.id)
	
	# Changed panel
	Inventory.button_slot_changed.emit(self,false)
	
	if _one_item_panel_id != panel_id:
		Inventory.set_panel_item(_one_item.id, _one_item_panel_id, -2, _two_item.slot, true, true)
		
		Inventory.set_panel_item(_two_item.id, _two_item_panel_id, _one_item_panel_id, _one_item.slot, true, true)
		Inventory.set_panel_item(_one_item.id, _one_item_panel_id, _two_item_panel_id, _two_item.slot, true, true)
	else:
		Inventory.changed_slots_items(_one_item, _two_item )

# Função para mover o item com o Shift pressionado
func shift_item_move() -> bool:
	if Input.is_key_pressed(KEY_SHIFT) and is_instance_valid(item_node):
		var _item_inventory: Dictionary = item_node.item_inventory
		var _panel_item: Dictionary = InventoryFile.get_panel(_item_inventory.panel_id)
		var _next_panel_id = my_panel.next_system_slot
		
		if _next_panel_id == null:
			print("Não há um painel como próximo para enviar o item.")
			return false
		
		Inventory.set_panel_item(_item_inventory.id,panel_id,_next_panel_id.slot_panel_id,-1,false)
		
		return true
	return false

# Função para verificar se o item é o mesmo
func for_the_same_item() -> bool:
	
	if Inventory.item_selected.item_inventory.unique_id == item_node.item_inventory.unique_id:
		
		var _item_panel: Dictionary = InventoryFile.search_item_id(item_node.item_inventory.panel_id, item_node.item_inventory.unique_id)
		var max_receive = item_node.item_inventory.amount + Inventory.item_selected.item_inventory.amount
		
		if max_receive >= _item_panel.max_amount + 1:
			return false
		else:
			
			item_node.item_inventory.amount += Inventory.item_selected.item_inventory.amount
			
			Inventory.item_selected.item_inventory.amount -= Inventory.item_selected.item_inventory.amount
			
			Inventory._refresh_data_item(
				Inventory.item_selected.item_inventory,
				InventoryFile.get_panel(
					Inventory.item_selected.item_inventory.panel_id
				)
			)
			Inventory._refresh_data_item(
				item_node.item_inventory,
				InventoryFile.get_panel(
					item_node.item_inventory.panel_id
				)
			)
		
		Inventory.button_slot_changed.emit(null, false)
		
		return true
	
	return false

# Função para definir o item com o botão direito do mouse
func set_item_right_mouse() -> void:
	var _item_panel = InventoryFile.search_item_id(item_node.item_inventory.panel_id,item_node.item_inventory.unique_id)
	
	if _item_panel.max_amount == 1:
		
		set_main_item()
		
		Inventory.new_data_global.emit()
	else:
		
		item_node.item_inventory.amount -= 1
		
		Inventory.add_item(item_node.item_inventory.panel_id,item_node.item_inventory.unique_id,1,Inventory.ERROR.SLOT_BUTTON_VOID)
		
		Inventory._refresh_data_item(item_node.item_inventory,_item_panel)
	
	right_mouse = false

# Função para trocar o item com o botão direito do mouse
func changed_item_right(is_item: Dictionary) -> bool:
	var _item_inventory = InventoryFile.search_item_id(is_item.panel_id,is_item.unique_id)
	
	if is_item.amount == _item_inventory.max_amount:
		return false
	
	if item_node.item_inventory.amount == 1:
		is_item.amount += 1
		item_node.item_inventory.amount = 0
	else:
		item_node.item_inventory.amount -= 1
		is_item.amount += 1
	
	InventoryFile.push_item_inventory(is_item.id,is_item)
	InventoryFile.push_item_inventory(item_node.item_inventory.id,item_node.item_inventory)
	
	Inventory.new_data.emit(InventoryFile.search_item_id(is_item.panel_id,is_item.unique_id),is_item,InventoryFile.get_panel(is_item.panel_id))
	Inventory.new_data.emit(InventoryFile.search_item_id(item_node.item_inventory.panel_id,item_node.item_inventory.unique_id),item_node.item_inventory,InventoryFile.get_panel(item_node.item_inventory.panel_id))
	
	Inventory.new_data_global.emit()
	
	return false

# Função para verificar se o item pertence a uma classe única
func is_unique_class() -> bool:
	var panel = InventoryFile.get_panel(panel_id)
	
	if panel.class_unique != "all":
		
		var _all_class = InventoryFile.pull_inventory(Inventory.ITEM_PANEL_PATH)
		
		for _class in _all_class:
			for _item in _all_class.get(_class):
				if _all_class.get(_class).get(_item).unique_id == Inventory.item_selected.item_inventory.unique_id:
					
					if _class == panel.class_unique:
						return true
					else:
						return false
	
	return true