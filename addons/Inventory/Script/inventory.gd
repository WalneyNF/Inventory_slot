extends Node

class_name Inventory_main


signal button_slot_changed(slot,move)
signal item_entered_panel(item ,new_type)
signal item_exiting_panel(item ,new_type)
signal new_item(item,system_slot)
signal new_data(item,system_slot)
signal new_data_global()
signal discart_item(item,system_slot)

enum ITEM_TYPE {GUN,ACCESSORIES}
enum TYPE_SLOT {INVENTORY,EQUIPPED}
enum ERROR {
	VOID = -1,
	NO_SPACE_FOR_ITEM_IN_SLOTS,
	ITEM_LEFT_WITH_FULL_SLOTS
}

const SLOT_BUTTON_VOID: int = -2

var item_selected

@export var panel : PanelResource

## Sub functions ================================================================
func _ready() -> void:
	button_slot_changed.connect(_function_slot_changed)

##===============================================================================
# New functions ================================================================

## Main functions ----------------------------------------
func add_item(dic_item: PanelItemResource, path: String, amount: int = 1, slot: int = -1, unique: bool = false):
	var item = search_item(dic_item.items,-1,path)
	
	
	if dic_item.items.size() != dic_item.max_slot:
		if unique:
			return _append_item(dic_item,path,amount,slot)
	
	if slot == SLOT_BUTTON_VOID: # Para botoes vazios, normalmente craidos com o botao direito.
		var _new_item = _append_item(dic_item,path,amount,SLOT_BUTTON_VOID)
		new_item.emit(_new_item,dic_item.id)
		
		return _new_item
	
	
	if item is ItemResource:
		var item_instance = load(path).instantiate()
		
		if item_instance.max_amount == 1:
			
			if dic_item.items.size() == dic_item.max_slot:
				return [ERROR.ITEM_LEFT_WITH_FULL_SLOTS,1]
			
			for i in amount:
				if dic_item.items.size() != dic_item.max_slot:
					_append_item(dic_item,path,1)
				else:
					return [ERROR.ITEM_LEFT_WITH_FULL_SLOTS,amount-i]
			return
		if item.amount == item_instance.max_amount:
			var now_search_item = search_item_amount_min(dic_item.items, path, item_instance.max_amount)
			
			if now_search_item != null:
				item = now_search_item
		
		if amount + item.amount > item_instance.max_amount:
			
			var apply_now_item: int = (item_instance.max_amount - item.amount)
			var filter_amount: int = amount - apply_now_item
			
			if dic_item.items.size() == dic_item.max_slot:
				item.amount = item_instance.max_amount
				
				return [ERROR.ITEM_LEFT_WITH_FULL_SLOTS,amount - apply_now_item]
			else:
				
				#item.amount = item.amount + apply_now_item # Adiciona para o item atual
				
				var separate_amount = _separater_item_amount(amount, item_instance.max_amount, filter_amount)
				
				item.amount = item_instance.max_amount
				
				new_data.emit(item,dic_item.id)
				new_data_global.emit()
				
				for new_amount in separate_amount:
					add_item(dic_item,path,new_amount,-1,true)
			
			return item
			
		else:
			item.amount = item.amount + amount
			
			new_data.emit(item,dic_item.id)
			new_data_global.emit()
			return item
	
	return _append_item(dic_item,path,amount,slot)


func remove_item(dic_item: PanelItemResource, id: int = -1) -> bool:
	
	for items in dic_item.items:
		if items.id == id:
			dic_item.items.erase(items)
			discart_item.emit(items,dic_item.id)
			return true
	
	return false


func set_panel_item(item: ItemResource, out_panel_id: int, new_panel_id:int, slot: int = -1, unique: bool = false, out_item_remove: bool = true):
	var out_panel: PanelItemResource = get_panel_id(out_panel_id)
	var new_panel: PanelItemResource = get_panel_id(new_panel_id)
	var new_item: ItemResource = item.duplicate()
	
	if out_item_remove:
		remove_item(out_panel,item.id)
	
	if out_panel == null or new_data == null: return
	
	var result = add_item(new_panel, new_item.path,new_item.amount,slot,unique)
	
	if result is Array:
		match result[0]:
			ERROR.NO_SPACE_FOR_ITEM_IN_SLOTS:
				return
			ERROR.ITEM_LEFT_WITH_FULL_SLOTS:
				new_item.amount = result[1]
				new_data_global.emit()
				return result
	
	
	
	item_entered_panel.emit(new_item,new_panel_id)
	item_exiting_panel.emit(new_item,out_panel_id)


func set_slot_item(dic_item: PanelItemResource, item: ItemResource, slot: int = -1, unique: bool = true) -> void:
	
	var new_item: ItemResource = item.duplicate()
	
	remove_item(dic_item,item.id)
	add_item(dic_item, new_item.path,new_item.amount,slot,unique)


func changed_slots_items(item_one: ItemResource, item_two: ItemResource) -> void:
	var one = item_one.duplicate()
	var two = item_two.duplicate()
	
	var panel_one = get_panel_id(search_panel(item_one.id))
	var panel_two = get_panel_id(search_panel(item_two.id))
	
	#add_item(dic_item, item.path,item.amount,false,slot)
	
	remove_item(panel_one,item_one.id)
	remove_item(panel_two,item_two.id)
	
	add_item(panel_one,one.path,one.amount,two.slot,true)
	add_item(panel_two,two.path,two.amount,one.slot,true)


func search_panel(item_id: int) -> int:
	for panels in panel.panel_item:
		for items in panels.items:
			if items.id == item_id:
				return panels.id
	
	return -1
#---------------------------------------------------------


# Adjustments -------------------------------------------
func _is_item_valid(array_item: Array, path: String) -> bool:
	for item in array_item:
		if item.path == path:
			return true
	
	return false

func _function_slot_changed(slot, move) -> void:
	if is_instance_valid(item_selected):
		
		if item_selected.item.slot == SLOT_BUTTON_VOID:
			if item_selected.item.amount == 0:
				item_selected.get_parent().queue_free()
	
	if move:
		item_selected = slot.item_node
	else:
		item_selected = null

func _append_item(dic_item: PanelItemResource, path: String, amount: int, slot: int = ERROR.VOID):
	var now_slot = slot
	
	if now_slot == ERROR.VOID:
		now_slot = search_void_slot(dic_item)
	
	var _new_item = ItemResource.new()
	
	_new_item.id = randi()
	_new_item.amount = amount
	_new_item.slot = now_slot
	_new_item.path = path
	
	dic_item.items.append(_new_item)
	new_item.emit(_new_item,dic_item.id)
	
	return _new_item

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

# Get ---------------------------------------------------
func get_panel_id(id: int):
	for panels in panel.panel_item:
		
		if panels.id == id:
			return panels
	
	return null

# Searchs -----------------------------------------------
func search_item(array_items: Array, id: int = -1, path : String = "",slot: int = -1):
	if slot != -1:
		for item in array_items:
			if item.slot == slot:
				return item
	
	if id == -1 and path != "":
		for item in array_items:
			if item.path == path:
				return item
	else:
		for item in array_items:
			if item.id == id:
				return item
	
	return null

func search_item_amount_min(array_item: Array, path: String, max_amount:int):
	for item in array_item:
		if item.path == path:
			if item.amount < max_amount:
				return item
	
	return null

func search_void_slot(dic_item: PanelItemResource) -> int:
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
