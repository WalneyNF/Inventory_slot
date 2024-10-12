extends Button

var item_node
var type: int
var inventory: Inventory_main

func _pressed() -> void:
	
	if is_instance_valid(inventory.item_selected):
		
		if is_instance_valid(item_node):
			
			if item_node == inventory.item_selected:
				reset()
			else:
				if for_the_same_item(): return
				
				item_changed_other_slot()
			
		else:
			item_move_void_slot()
		
	else:
		if is_instance_valid(item_node):
			set_main_item()

func _ready() -> void:
	child_exiting_tree.connect(exit_child)

func exit_child(node: Node) -> void:
	tooltip_text = ""


func reset() -> void:
	inventory.slot_changed.emit(self,false)
	item_node.position = Vector2()


func set_main_item() -> void:
	inventory.slot_changed.emit(self,true)
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
	inventory.slot_changed.emit(self,false)
	
	item_node.z_index = 0


func item_changed_other_slot() -> void:
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
	
	inventory.slot_changed.emit(self,false)


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
		inventory.slot_changed.emit(null, false)
		
		return true
	
	return false
