extends Button

var item_node
var panel_id: int
var inventory: Inventory_main
var my_panel: PanelContainer
var right_mouse: bool
var free_use: bool

# Class =====
func _ready() -> void:
	child_exiting_tree.connect(exit_child)
	await get_tree().create_timer(0.2).timeout

func _gui_input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		right_mouse = true

func _pressed() -> void:
	
	if is_instance_valid(inventory.item_selected):
		
		if is_instance_valid(item_node):
			
			if right_mouse:
				var items = inventory.get_panel_id(panel_id).items
				var is_item = inventory.search_item(items,-1,"",inventory.SLOT_BUTTON_VOID)
				
				if is_item != null:
					changed_item_right(is_item)
				else:
					is_item = inventory.search_item(items,inventory.item_selected.item.id)
					
					if is_item != null:
						if is_item.path == item_node.item.path and is_item.amount < item_node.item_scene.max_amount:
							item_node.item.amount -= 1
							is_item.amount += 1
							
							inventory.new_data_global.emit()
				
				right_mouse = false
				return
			
			if item_node == inventory.item_selected:
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
	inventory.button_slot_changed.emit(self,false)
	item_node.position = Vector2()


func set_main_item() -> void:
	inventory.button_slot_changed.emit(self,true)
	item_node.z_index = 1


func item_move_void_slot() -> void:
	var one_item = inventory.item_selected.item.duplicate()
	var item_selected_panel_id = inventory.search_panel(one_item.id)
	
	if item_selected_panel_id != panel_id:
		inventory.set_panel_item(one_item, item_selected_panel_id, panel_id, get_index(), true)
	else:
		inventory.set_slot_item(inventory.get_panel_id(item_selected_panel_id),one_item,get_index())
	
	inventory.item_selected.queue_free()
	inventory.button_slot_changed.emit(self,false)


func item_changed_other_slot() -> void:
	if inventory.item_selected.item.slot == inventory.SLOT_BUTTON_VOID:
		return
	# Creator second item
	var one_item = inventory.item_selected.item
	var two_item = item_node.item
	
	#Changed panel
	var one_item_panel_id = inventory.search_panel(one_item.id)
	var two_item_panel_id = inventory.search_panel(two_item.id)
	
	if one_item_panel_id != panel_id:
		inventory.remove_item(inventory.get_panel_id(one_item_panel_id),one_item.id)
		inventory.remove_item(inventory.get_panel_id(two_item_panel_id),two_item.id)
		
		inventory.set_panel_item(one_item, one_item_panel_id, two_item_panel_id, two_item.slot, true, false)
		inventory.set_panel_item(two_item, two_item_panel_id, one_item_panel_id, one_item.slot, true, false)
	else:
		inventory.changed_slots_items(one_item,two_item)
	
	inventory.button_slot_changed.emit(self,false)


func shift_item_move() -> bool:
	if Input.is_key_pressed(KEY_SHIFT):
		var item = item_node.item
		var item_panel = inventory.get_panel_id(inventory.search_panel(item.id))
		var next_panel_id = my_panel.get_node_or_null(my_panel.next_system_slot)
		
		if next_panel_id == null:
			print("Não há um panel como proximo para enviar o item.")
			return false
		
		inventory.set_panel_item(item,panel_id,next_panel_id.slot_panel_id,-1,false)
		
		return true
	
	return false


func for_the_same_item() -> bool:
	
	if inventory.item_selected.item.path == item_node.item.path:
		
		var item_instance = load(item_node.item.path).instantiate()
		var max_receive = item_node.item.amount + inventory.item_selected.item.amount
		
		if max_receive >= item_instance.max_amount + 1:
			return false
		else:
			item_node.item.amount += inventory.item_selected.item.amount
			
			inventory.item_selected.item.amount -= inventory.item_selected.item.amount
		
		inventory.new_data_global.emit()
		inventory.button_slot_changed.emit(null, false)
		
		return true
	
	return false


func set_item_right_mouse() -> void:
	
	if item_node.item.amount == 1:
		set_main_item()
		inventory.new_data_global.emit()
	else:
		item_node.item.amount -= 1
		
		inventory.add_item(inventory.get_panel_id(panel_id),item_node.item.path,1,inventory.SLOT_BUTTON_VOID)
		inventory.new_data_global.emit()
	
	right_mouse = false


func changed_item_right(is_item: ItemResource) -> bool:
	
	if item_node.item.amount == 1:
		item_node.item.amount += is_item.amount
		is_item.amount = 0
		
		inventory.button_slot_changed.emit(self,true)
		item_node.z_index = 1
	else:
		item_node.item.amount -= 1
		is_item.amount += 1
	
	inventory.new_data_global.emit()
	return false
