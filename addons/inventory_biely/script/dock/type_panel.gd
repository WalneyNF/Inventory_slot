extends Node

class_name TypePanel

const ITEM_PATH = "res://addons/inventory_biely/json/system/items.json"
const ITEMS_PATH = "res://addons/inventory_biely/json/save/inventory.json"
const PANEL_SLOT_PATH = "res://addons/inventory_biely/json/system/panel_slot.json"
const LIFE = "res://addons/inventory_biely/assets/imagens/life.png"

var start_update: bool


func changed_class_name(_inventory: Dictionary,_out_class_name: String,_new_class_name: String) -> void:
	
	var new_value = _inventory.get(_out_class_name)
	
	_inventory.erase(_out_class_name)
	_inventory[_new_class_name] = new_value


static func changed_item_name(_inventory: Dictionary,_class_name: String,_out_item_name: String,_new_item_name: String) -> void:
	
	var item = search_item(_inventory,_class_name,_out_item_name)
	
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

static func search_item(_inventory: Dictionary,_class_name: String,_item_name: String):
	for _class in _inventory:
		if _class_name == _class:
			for _item in _inventory.get(_class):
				
				if _item_name == _item:
					
					return _inventory.get(_class_name).get(_item_name)
	
	printerr("Item ",_item_name," não foi encontrado!")

static func search_dic(_dic: Dictionary,_item_name: String):
	for _item in _dic:
		
		if _item_name == _item:
			
			return _dic.get(_item_name)
	
	printerr("Item ",_item_name," não foi encontrado!")

static func search_item_id(panel_id: int, item_unique_id: int = -1):
	#if slot != -1:
	#	for item in array_items:
	#		if item.slot == slot:
	#			return item
	
	#if id == -1 and path != "":
	#	for item in array_items:
	#		if item.path == path:
	#			return item
	#else:
	var items = TypePanel.pull_inventory(TypePanel.ITEM_PATH)
	
	for _all in items:
		for _item in items.get(_all):
			var item = items.get(_all).get(_item)
			if items.get(_all).get(_item).unique_id == item_unique_id:
				return items.get(_all).get(_item)
	
	return null

static func get_item_name(unique_id_item: int) -> StringName:
	var all_items = pull_inventory(ITEM_PATH)
	
	for _class in all_items:
		for _items in all_items.get(_class):
			if all_items.get(_class).get(_items).unique_id == unique_id_item:
				return _items
	
	return ""

static func pull_inventory(path: String = ITEM_PATH) -> Dictionary:
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path,FileAccess.READ)
		
		var all_class: Dictionary = JSON.parse_string(file.get_as_text())
		file.close()
		
		return all_class
	
	return {}

static func push_inventory(dic: Dictionary,path: String = ITEM_PATH) -> void:
	var file = FileAccess.open(path,FileAccess.WRITE)
	
	file.store_string(JSON.stringify(dic,"\t"))
	file.close()

static func new_item(_inventory: Dictionary,_class_name: String,icon_path: String = LIFE,amount: int = 1,path_scene: String = "res://") -> void:
	
	for _class in _inventory:
		
		if _class == _class_name:
			
			_inventory.get(_class)[str("new_item_",get_id_void())] = {
				"unique_id" : get_id_void(),
				"icon" : icon_path,
				"max_amount" : amount,
				"path_scene" : path_scene
			}

static func get_id_void() -> int:
	var all_id: Array = []
	
	var all_slots = pull_inventory(ITEM_PATH)
	
	for all_class in all_slots:
		for items in all_slots.get(all_class):
			all_id.append(all_slots.get(all_class).get(items).unique_id)
	
	
	all_id.sort()
	
	for id in range(all_id.size()):
		if id != all_id[id]:
			return id
	
	return all_id.size()

static func get_items_size() -> int:
	var size_item: int = 0
	
	var all_slots = pull_inventory(PANEL_SLOT_PATH)
	
	for all_class in all_slots:
		for items in all_slots.get(all_class):
			size_item += 1
	
	return size_item

static func remove_item(_inventory: Dictionary,_class_name: String,_item_name: String) -> void:
	_inventory.get(_class_name).erase(_item_name)

static func remove_class(_inventory: Dictionary,_class_name: String) -> void:
	_inventory.erase(_class_name)


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


static func list_all_item(panel_id: int = -1) -> Array:
	var inventory = pull_inventory()
	
	var all_items: Array
	
	for _class in inventory:
		for items in inventory.get(_class):
			if panel_id == -1:
				all_items.append(inventory.get(_class).get(items))
			else:
				if panel_id == inventory.get(_class).get(items).panel_id:
					all_items.append(inventory.get(_class).get(items))
	
	return all_items

static func list_all_inventory_item(panel_id) -> Array:
	var inventory = pull_inventory(ITEMS_PATH)
	
	var all_items: Array
	
	for items in inventory:
		if panel_id == -1:
			all_items.append(inventory.get(items))
		else:
			if panel_id == inventory.get(items).panel_id:
				all_items.append(inventory.get(items))
	
	return all_items
