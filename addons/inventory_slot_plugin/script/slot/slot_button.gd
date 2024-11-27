extends Button

var item_node: Node
var my_panel: PanelContainer
var panel_id: int
var free_use: bool

var use_right_click: bool:
	set(value):
		if value:
			button_mask = MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_RIGHT
		else:
			button_mask = MOUSE_BUTTON_MASK_LEFT
		use_right_click = value

var right_mouse: bool
var left_mouse: bool

var press: bool

# Class =====
func _ready() -> void:
	child_exiting_tree.connect(exit_child)
	child_entered_tree.connect(enter_child)
	
	button_down.connect(_button_down)
	button_up.connect(_button_up)
	
	mouse_exited.connect(_mouse_exited)
	mouse_entered.connect(_mouse_entered)
	
	set_process_input(false)

func _input(_event: InputEvent) -> void:
	if _event is InputEventMouseButton or _event is InputEventMouseMotion:
		
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and use_right_click:
			right_mouse = true
			
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			left_mouse = true
		
		else:
			if is_instance_valid(Inventory.item_selected):
				if left_mouse and (Inventory.item_selected.get_parent().press or press):
					_get_item()
			
			left_mouse = false

# Action ====

func _button_down() -> void:
	if press:
		if !is_instance_valid(Inventory.item_selected):
			_set_item()

func _button_up() -> void:
	var _item_valid: bool = is_instance_valid(Inventory.item_selected)
	
	if press:
		if _item_valid:
			if Inventory.item_selected == item_node:
				reset()
		return
	
	_action()



func _mouse_entered() -> void:
	set_process_input(true)
func _mouse_exited() -> void:
	left_mouse = false
	right_mouse = false
	set_process_input(false)


func _action() -> void:
	if is_instance_valid(Inventory.item_selected):
		_get_item()
	else:
		_set_item()


func _set_item() -> void:
	if shift_item_move(): return
	
	if is_instance_valid(item_node):
		if right_mouse:
			set_item_right_mouse()
			return
		set_main_item()

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


func enter_child(node: Node) -> void:
	if node is TextureRect:
		await node.get_tree().create_timer(0.2).timeout
		
		if is_instance_valid(node): tooltip_text = node.item_more()
func exit_child(node: Node) -> void:
	if node is TextureRect:
		tooltip_text = ""
	
	if free_use:
		queue_free()


# New =====
func reset() -> void:
	Inventory.button_slot_changed.emit(self,false)
	item_node.position = Vector2()

func set_main_item() -> void:
	Inventory.button_slot_changed.emit(self,true)
	item_node.z_index = 1

func item_move_void_slot() -> void:
	
	var _one_item = Inventory.item_selected.item_inventory
	
	var _item_selected_panel = InventoryFile.get_panel(_one_item.panel_id)
	
	if _item_selected_panel.id != panel_id:
		Inventory.set_panel_item(_one_item.id ,_item_selected_panel.id ,panel_id ,get_index() ,true )
	else:
		Inventory.set_slot_item(_item_selected_panel ,_one_item ,get_index() ,true )
	
	Inventory.item_selected.queue_free()
	Inventory.button_slot_changed.emit(self,false)

func item_changed_other_slot() -> void:
	var _one_item = Inventory.item_selected.item_inventory
	var _two_item = item_node.item_inventory
	
	var _one_item_panel_id = Inventory.search_panel_id_item(_one_item.id)
	var _two_item_panel_id = Inventory.search_panel_id_item(_two_item.id)
	
	#Changed panel
	Inventory.button_slot_changed.emit(self,false)
	
	if _one_item_panel_id != panel_id:
		Inventory.set_panel_item(_one_item.id, _one_item_panel_id, -2, _two_item.slot, true, true)
		
		Inventory.set_panel_item(_two_item.id, _two_item_panel_id, _one_item_panel_id, _one_item.slot, true, true)
		Inventory.set_panel_item(_one_item.id, _one_item_panel_id, _two_item_panel_id, _two_item.slot, true, true)
	else:
		Inventory.changed_slots_items(_one_item, _two_item )

func shift_item_move() -> bool:
	if Input.is_key_pressed(KEY_SHIFT) and is_instance_valid(item_node):
		var _item_inventory: Dictionary = item_node.item_inventory
		var _panel_item: Dictionary = InventoryFile.get_panel(_item_inventory.panel_id)
		var _next_panel_id = my_panel.next_system_slot
		
		if _next_panel_id == null:
			print("There is no panel as next to send the item.")
			return false
		
		Inventory.set_panel_item(_item_inventory.id,panel_id,_next_panel_id.slot_panel_id,-1,false)
		
		return true
	return false

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
