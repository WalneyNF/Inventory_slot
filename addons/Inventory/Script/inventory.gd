extends Node

class_name Inventory_main

signal slot_changed(slot,move)
signal new_item(item,system_slot)
signal new_data(item,system_slot)
signal new_data_global()
signal discart_item(item,system_slot)

enum ITEM_TYPE {GUN,ACCESSORIES}
enum TYPE_SLOT {INVENTORY,EQUIPPED}


var item_selected


var panel_item : Dictionary = {
	"inventory" : {
		"type" : TYPE_SLOT.INVENTORY,
		"max_slot" : 20,
		"items" : [
			{"id": 0, "slot" : 0, "amount" : 1, "path": "res://addons/Inventory/Scenes/Item/Sword.tscn"},
			{"id": 2, "slot" : 1, "amount" : 2, "path": "res://addons/Inventory/Scenes/Item/Kanoa.tscn"}
		]
	},
	
	"equipped" : {
		"type" : TYPE_SLOT.EQUIPPED,
		"max_slot" : 5,
		"items" : [
			]
		}
	}

## Sub functions ================================================================
func _ready() -> void:
	slot_changed.connect(_function_slot_changed)

##===============================================================================
# New functions ================================================================

## Main functions ----------------------------------------
func add_item(dic_item: Dictionary, path: String, amount: int = 1, new_slot: bool = false, slot: int = -1, unique: bool = false):
	if unique:
		return _append_item(dic_item,path,amount)
	
	var item = search_item(dic_item.items,-1,path)
	
	if item is Dictionary:
		var item_instance = load(path).instantiate()
		
		if item_instance.max_amount == 1:
			return _append_item(dic_item,path,amount)
		if item.amount == item_instance.max_amount:
			var now_search_item = search_item_amount_min(dic_item.items, path, item_instance.max_amount)
			
			if now_search_item != null:
				item = now_search_item
		
		if amount + item.amount > item_instance.max_amount:
			
			var apply_now_item: int = (item_instance.max_amount - item.amount)
			var filter_amount: int = amount - apply_now_item
			
			item.amount = item.amount + apply_now_item # Adiciona para o item atual
			
			var separate_amount = _separater_item_amount(amount, item_instance.max_amount, filter_amount)
			
			for new_amount in separate_amount:
				add_item(dic_item,path,new_amount,false,-1,true)
			
			item.amount = item_instance.max_amount
			
			new_data.emit(item,dic_item.type)
			new_data_global.emit()
			return item
		else:
			item.amount = item.amount + amount
			
			new_data.emit(item,dic_item.type)
			new_data_global.emit()
			return item
	
	return _append_item(dic_item,path,amount)


func remove_item(dic_item: Dictionary, id: int = -1) -> bool:
	
	for items in dic_item.items:
		if items.id == id:
			dic_item.items.erase(items)
			discart_item.emit(items,dic_item.type)
			return true
	
	return false

#---------------------------------------------------------


# Adjustments -------------------------------------------
func _is_item_valid(array_item: Array, path: String) -> bool:
	for item in array_item:
		if item.path == path:
			return true
	
	return false

func _function_slot_changed(slot, move) -> void:
	if move:
		item_selected = slot.item_node
	else:
		item_selected = null

func _append_item(dic_item: Dictionary, path: String, amount: int):
	var now_slot = search_void_slot(dic_item)
	var new_create_item = {"id": randi(),"amount": amount, "slot" : now_slot, "path": path}
	
	dic_item.items.append(new_create_item)
	new_item.emit(new_create_item,dic_item.type)
	
	return new_create_item

func _separater_item_amount(amount: int, max_amount: int, filter_amount: int):
	var amount_slots = float(amount) / max_amount
	var separate_amount = []
	var next: int = 0
	var max: int = 0
	
	# se tiver muito item
	for i in filter_amount: # Separa quantos slots são necessarios e a quantidade que irar ir pra cada slot
		
		next += 1
		max += 1
		
		if next == max_amount:
			separate_amount.append(next)
			
			next = 0
		
		
		if max == filter_amount:
			separate_amount.append(next)
	
	return separate_amount
#---------------------------------------------------------

# Searchs -----------------------------------------------
func search_item(array_item: Array, id: int = -1, path : String = ""):
	if id == -1 and path != "":
		for item in array_item:
			if item.path == path:
				return item
	else:
		for item in array_item:
			if item.id == id:
				return item
	
	return null

func search_item_amount_min(array_item: Array, path: String, max_amount:int):
	for item in array_item:
		if item.path == path:
			if item.amount < max_amount:
				return item
	
	return null

func search_void_slot(dic_item: Dictionary) -> int:
	var all_slot = []
	
	for item in dic_item.items:
		all_slot.append(item.slot)
	
	all_slot.sort()
	
	for pass_slot in range(dic_item.max_slot):
		if pass_slot >= all_slot.size():
			return pass_slot
		if pass_slot != all_slot[pass_slot]:
			return pass_slot
	
	return -1

#---------------------------------------------------------
##===============================================================================
