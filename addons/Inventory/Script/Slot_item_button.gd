extends Button

var item_node
var type: int
var inventory: Inventory_main
var right_mouse: bool
var free_use: bool

var dedbug_text = Label.new()
func _process(delta: float) -> void:
	dedbug_text.text = str(inventory.get_panel_type(type).type)

# Class =====
func _ready() -> void:
	add_child(dedbug_text)
	child_exiting_tree.connect(exit_child)
	await get_tree().create_timer(0.2).timeout

func _gui_input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		right_mouse = true

func _pressed() -> void:
	
	if is_instance_valid(inventory.item_selected):
		
		if is_instance_valid(item_node):
			
			if right_mouse:
				var items = inventory.get_panel_type(type).items
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
	var one_item = inventory.item_selected.duplicate()
	
	one_item.position = Vector2()
	one_item.inventory = inventory
	one_item.item = inventory.item_selected.item
	one_item.item.slot = get_index()
	
	add_child(one_item)
	
	item_node = one_item
	
	inventory.item_selected.queue_free()
	inventory.button_slot_changed.emit(self,false)
	
	item_node.z_index = 0


func item_changed_other_slot() -> void:
	if inventory.item_selected.item.slot == inventory.SLOT_BUTTON_VOID:
		return
	# Creator second item
	var one_item = inventory.item_selected.duplicate()
	var two_item = item_node.duplicate()
	
	one_item.position = Vector2()
	one_item.inventory = inventory
	one_item.item = inventory.item_selected.item
	one_item.item.slot = get_index()
	one_item.z_index = 0
	
	two_item.position = Vector2()
	two_item.inventory = inventory
	two_item.item = item_node.item
	two_item.item.slot = inventory.item_selected.get_parent().get_index()
	two_item.z_index = 0
	
	add_child(one_item)
	inventory.item_selected.get_parent().add_child(two_item)
	
	# Delete original
	inventory.item_selected.queue_free()
	item_node.queue_free()
	
	# Set variable
	item_node = one_item
	two_item.get_parent().item_node = two_item
	
	inventory.button_slot_changed.emit(self,false)


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
		
		inventory.add_item(inventory.get_panel_type(type),item_node.item.path,1,false,inventory.SLOT_BUTTON_VOID)
		inventory.new_data_global.emit()
	
	right_mouse = false


func changed_item_right(is_item: Dictionary) -> bool:
	
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
