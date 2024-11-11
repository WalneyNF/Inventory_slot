
class_name TypePanel extends Node


var start_update: bool


static func changed_item_name(_inventory: Dictionary,_class_name: String,_out_item_name: String,_new_item_name: String) -> void:
	
	var item = InventoryFile.search_item(_inventory,_class_name,_out_item_name)
	
	if item != null:
		var new_value = _inventory.get(_class_name).get(_out_item_name)
		
		_inventory.get(_class_name).erase(_out_item_name)
		_inventory.get(_class_name)[_new_item_name] = new_value

static func changed_dic_name(_dic: Dictionary,_out_item_name: String,_new_item_name: String) -> void:
	
	var item = search_dic(_dic,_out_item_name)
	
	if item != null:
		var new_value = _dic.get(_out_item_name)
		
		_dic.erase(_out_item_name)
		_dic[_new_item_name] = new_value

static func search_dic(_dic: Dictionary,_item_name: String):
	for _item in _dic:
		
		if _item_name == _item:
			
			return _dic.get(_item_name)
	
	printerr("Item ",_item_name," not found!")

static func get_item_panel_id_void() -> int:
	var _all_id_array: Array = []
	
	var _all_id_dictionary = InventoryFile.pull_inventory(InventoryFile.ITEM_PANEL_PATH)
	
	for _all_class in _all_id_dictionary:
		if _all_id_dictionary.get(_all_class) is float: continue
		
		for _items in _all_id_dictionary.get(_all_class):
			_all_id_array.append(_all_id_dictionary.get(_all_class).get(_items).unique_id)
	
	
	_all_id_array.sort()
	
	for _id in range(_all_id_array.size()):
		if _id != _all_id_array[_id]:
			return _id
	
	return _all_id_array.size()

static func get_items_size() -> int:
	var _size_item: int = 0
	
	var _all_slots = InventoryFile.pull_inventory(InventoryFile.PANEL_SLOT_PATH)
	
	for _all_class in _all_slots:
		for _items in _all_slots.get(_all_class):
			
			_size_item += 1
	
	return _size_item

func move_panel(event: InputEvent,panel,topbar: Control,panel_parent: BoxContainer) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if event is InputEventMouseMotion:
			start_update = true
			panel.global_position.y = panel.get_global_mouse_position().y - topbar.size.y/2
			panel.z_index = 1
	else:
		if start_update:
			update_item_panel(panel_parent)
			start_update = false

func update_item_panel(panel_parent: BoxContainer) -> void:
	var all_child = panel_parent.get_children()
	
	all_child.sort_custom(sort_position)
	
	for i in range(all_child.size()):
		panel_parent.move_child(all_child[i],i)
	
	for child in panel_parent.get_children():
		
		child.z_index = 0
		child.hide()
		child.show()
		
		#child.id_unique.text = str(child.get_index())

func sort_position(a,b):
	if a.position.y-(a.size.y/2) < b.position.y:
		return a
