extends Button

var item_node
var panel_id: int
var my_panel: PanelContainer
var right_mouse: bool
var free_use: bool
# Class =====
func _ready() -> void:
	child_exiting_tree.connect(exit_child)

func _gui_input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		right_mouse = true

func _pressed() -> void:
	
	if is_instance_valid(Inventory.item_selected):
		
		if is_instance_valid(item_node):
			
			if right_mouse:
				
				var items = Inventory.get_panel_id(panel_id).items
				var is_item = Inventory.search_item(items,-1,"",Inventory.ERROR.SLOT_BUTTON_VOID)
				
				if is_item != null and is_item.path == item_node.item.path:
					changed_item_right(is_item)
				else:
					is_item = Inventory.search_item(items,Inventory.item_selected.item.id)
					
					if is_item != null:
						if is_item.path == item_node.item.path and is_item.amount < item_node.item_scene.max_amount:
							item_node.item.amount -= 1
							is_item.amount += 1
							
							Inventory.new_data_global.emit()
				
				right_mouse = false
				return
			
			if item_node == Inventory.item_selected:
				reset()
			else:
				if for_the_same_item(): return
				
				item_changed_other_slot()
			
		else:
			item_move_void_slot()
		
	else:
		if shift_item_move(): return
		
		if is_instance_valid(item_node):
			if right_mouse:
				set_item_right_mouse()
				return
			set_main_item()

func exit_child(node: Node) -> void:
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
	
	var one_item = Inventory.item_selected.item
	var item_selected_panel_id = Inventory.get_panel_id(one_item.unique_id)
	
	if item_selected_panel_id != panel_id:
		Inventory.set_panel_item(one_item, item_selected_panel_id, panel_id, get_index(), true)
	else:
		Inventory.set_slot_item(Inventory.get_panel_id(item_selected_panel_id),one_item,get_index())
	
	Inventory.item_selected.queue_free()
	Inventory.button_slot_changed.emit(self,false)


func item_changed_other_slot() -> void:
	var one_item = Inventory.item_selected.item
	var two_item = item_node.item
	
	var one_item_panel_id = Inventory.search_panel(one_item.id)
	var two_item_panel_id = Inventory.search_panel(two_item.id)
	
	#Changed panel
	Inventory.button_slot_changed.emit(self,false)
	
	if one_item_panel_id != panel_id:
		Inventory.remove_item(Inventory.get_panel_id(one_item_panel_id),one_item.id)
		Inventory.remove_item(Inventory.get_panel_id(two_item_panel_id),two_item.id)
		
		Inventory.set_panel_item(one_item, one_item_panel_id, two_item_panel_id, two_item.slot, true, false)
		Inventory.set_panel_item(two_item, two_item_panel_id, one_item_panel_id, one_item.slot, true, false)
	else:
		Inventory.changed_slots_items(one_item,two_item)


func shift_item_move() -> bool:
	if Input.is_key_pressed(KEY_SHIFT) and is_instance_valid(item_node):
		var item = item_node.item
		var item_panel = Inventory.get_panel_id(Inventory.search_panel_id_item(item.id))
		var next_panel_id = my_panel.next_system_slot
		
		if next_panel_id == null:
			print("There is no panel as next to send the item.")
			return false
		
		Inventory.set_panel_item(item,panel_id,next_panel_id.slot_panel_id,-1,false)
		
		return true
	
	return false


func for_the_same_item() -> bool:
	
	if Inventory.item_selected.item.path == item_node.item.path:
		
		var item_instance = load(item_node.item.path).instantiate()
		var max_receive = item_node.item.amount + Inventory.item_selected.item.amount
		
		if max_receive >= item_instance.max_amount + 1:
			return false
		else:
			item_node.item.amount += Inventory.item_selected.item.amount
			
			Inventory.item_selected.item.amount -= Inventory.item_selected.item.amount
		
		Inventory.new_data_global.emit()
		Inventory.button_slot_changed.emit(null, false)
		
		return true
	
	return false


func set_item_right_mouse() -> void:
	
	if item_node.item.amount == 1:
		set_main_item()
		Inventory.new_data_global.emit()
	else:
		item_node.item.amount -= 1
		
		Inventory.add_item(Inventory.get_panel_id(panel_id),item_node.item.path,1,Inventory.ERROR.SLOT_BUTTON_VOID)
		Inventory.new_data_global.emit()
	
	right_mouse = false


func changed_item_right(is_item: Dictionary) -> bool:
	
	if item_node.item.amount == 1:
		item_node.item.amount += is_item.amount
		is_item.amount = 0
		
		Inventory.button_slot_changed.emit(self,true)
		item_node.z_index = 1
	else:
		item_node.item.amount -= 1
		is_item.amount += 1
	
	Inventory.new_data_global.emit()
	return false
