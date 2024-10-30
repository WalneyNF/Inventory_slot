@tool
extends Node

#class_name Inventory_main

# new_data.emit(item_panel,item_inventory,panel_slot)
signal new_item(item_panel: Dictionary , item_inventory: Dictionary, panel_slot: Dictionary)
signal new_data(item: Dictionary ,system_slot: Dictionary)
signal discart_item(item: Dictionary ,system_slot: Dictionary)
signal item_entered_panel(item: Dictionary ,new_id: int)
signal item_exiting_panel(item: Dictionary ,out_id: int)
signal button_slot_changed(slot: Control,move: bool)
signal new_data_global()

#@export var panel: PanelResource


enum ERROR {
	SLOT_BUTTON_VOID = -2,
	VOID = -1,
	NO_SPACE_FOR_ITEM_IN_SLOTS,
	ITEM_LEFT_WITH_FULL_SLOTS
}

var item_selected: Control # Item node dos slots

## Sub functions ================================================================
func _ready() -> void:
	set_process_input(false)
	
	button_slot_changed.connect(_function_slot_changed)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		item_selected.global_position = event.position - (item_selected.size/2)


##===============================================================================
# New functions ================================================================

## Main functions ----------------------------------------
func add_item(panel_id: int, item_unique_id: int, amount: int = 1, slot: int = -1, id: int = -1, unique: bool = false):
	var item_panel = TypePanel.search_item_id(panel_id,item_unique_id)
	var item_inventory = search_item(panel_id,item_unique_id)
	
	var panel_slot = search_panel(panel_id)
	
	var panel_slot_amount = get_amount_panel_inventory_item(panel_id)
	
	if panel_slot_amount != panel_slot.slot_amount:
		if unique:
			return _append_item(panel_slot,item_panel,amount,slot,id)
	
	if slot == ERROR.SLOT_BUTTON_VOID: # Para botoes vazios, normalmente craidos com o botao direito.
		var _new_item = _append_item(panel_slot,item_panel,amount,ERROR.SLOT_BUTTON_VOID)
		return _new_item
	
	if item_inventory is Dictionary and item_inventory != {}:
		
		if item_panel.slot_amount == 1:
			
			if panel_slot_amount == panel_slot.slot_amount:
				return [ERROR.ITEM_LEFT_WITH_FULL_SLOTS,1]
			
			for i in amount:
				if panel_slot_amount != panel_slot.slot_amount:
					_append_item(panel_slot,item_panel,1)
				else:
					return [ERROR.ITEM_LEFT_WITH_FULL_SLOTS,amount-i]
			
			return
		
		if item_inventory.amount == panel_slot.slot_amount:
			var now_search_item = search_item_amount_min(panel_id, item_unique_id, item_panel.max_amount)#  asd
			
			if now_search_item != null:
				item_inventory = now_search_item
				#item_panel = TypePanel.search_item_id(panel_id,now_search_item.unique_id)
				#item_panel = now_search_item
		
		if amount + item_inventory.amount > item_panel.slot_amount:
			
			var apply_now_item: int = (item_panel.slot_amount - item_inventory.amount)
			var filter_amount: int = amount - apply_now_item
			
			if panel_slot_amount == panel_slot.slot_amount:
				item_inventory.amount = item_panel.slot_amount
				
				return [ERROR.ITEM_LEFT_WITH_FULL_SLOTS,amount - apply_now_item]
			else:
				
				#item.amount = item.amount + apply_now_item # Adiciona para o item atual
				
				var separate_amount = _separater_item_amount(amount, item_panel.max_amount, filter_amount)
				
				item_inventory.amount = item_panel.slot_amount
				
				new_data.emit(item_panel,item_inventory,panel_slot)
				new_data_global.emit()
				
				for new_amount in separate_amount: 
					add_item(panel_id,item_unique_id,new_amount,-1,-1,true)
			
			return item_inventory
			
		else:
			item_inventory.amount = item_inventory.amount + amount
			
			new_data.emit(item_panel ,item_inventory ,panel_slot)
			new_data_global.emit()
			return item_inventory
	
	return _append_item(panel_slot,item_panel,amount,slot,id)



func get_amount_panel_inventory_item(_panel_id: int) -> int:
	var _all_inventory_items: Array = TypePanel.list_all_inventory_item(_panel_id)
	var _amount: int = 0
	
	for _items in _all_inventory_items:
		
		if _items.panel_id == _panel_id:
			_amount += 1
	
	return _amount


func remove_item(_panel_item: Dictionary, _id: int = -1) -> bool:
	var _all_item_inventory: Array = TypePanel.list_all_inventory_item(_panel_item.id)
	
	for _items in _all_item_inventory:
		
		if _items.id == _id:
			_all_item_inventory.erase(_items)
			
			discart_item.emit(_items,_panel_item.id)
			
			TypePanel.push_item_inventory(str(_items.id),{})
			return true
	
	return false


func set_panel_item(_item_inventory: Dictionary, _out_panel_id: int, _new_panel_id:int, _slot: int = -1, _unique: bool = false, _out_item_remove: bool = true):
	var _out_panel: Dictionary = get_panel_id(_out_panel_id)
	var _new_panel: Dictionary = get_panel_id(_new_panel_id)
	var _item_panel: Dictionary = TypePanel.search_item_id(_out_panel.id,_item_inventory.unique_id)
	var _new_item: Dictionary = _item_inventory
	var _all_items_new_panel: Array = TypePanel.list_all_inventory_item(_new_panel.id)
	
	if _new_panel.slot_amount == _all_items_new_panel.size() and _slot != ERROR.SLOT_BUTTON_VOID:
		
		if _unique:
			
			return ERROR.NO_SPACE_FOR_ITEM_IN_SLOTS
		else:
			
			var _search_item = search_item_amount_min(_new_panel.items,_item_inventory.path,_item_panel.slot_amount)
			
			if search_item != null:
				
				if _item_panel.slot_amount > _search_item.amount:
					
					var _size = _item_panel.slot_amount - _search_item.amount
					_search_item.amount = _search_item.amount + _size
					_item_inventory.amount -= _size
					
					new_data_global.emit()
					
					return new_item
		
		return ERROR.NO_SPACE_FOR_ITEM_IN_SLOTS
	
	if _out_item_remove:
		remove_item(_out_panel,_item_inventory.id)
	
	if _out_panel == null or new_data == null: return
	
	var _result = add_item(_new_panel.id, _new_item.unique_id,_new_item.amount,_slot,_new_item.id,_unique)
	
	if _result is Array:
		match _result[0]:
			ERROR.NO_SPACE_FOR_ITEM_IN_SLOTS:
				return
			ERROR.ITEM_LEFT_WITH_FULL_SLOTS:
				_new_item.amount = _result[1]
				new_data_global.emit()
				return _result
	
	
	
	item_entered_panel.emit(_new_item,_new_panel_id)
	item_exiting_panel.emit(_new_item,_out_panel_id)


func set_slot_item(_panel_item: Dictionary, _item_inventory: Dictionary, _slot: int = -1, _unique: bool = true) -> void:
	
	var _new_item_inventory: Dictionary = _item_inventory
	
	remove_item(_panel_item,_item_inventory.id)
	add_item(
		_panel_item.id,
		_new_item_inventory.unique_id,
		_new_item_inventory.amount,
		_slot,
		_item_inventory.id,
		_unique
	)


func changed_slots_items(item_one: Dictionary, item_two: Dictionary) -> void:
	var one = item_one
	var two = item_two
	
	var panel_one = get_panel_id(search_panel_id_item(item_one.id))
	var panel_two = get_panel_id(search_panel_id_item(item_two.id))
	
	remove_item(panel_one,item_one.id)
	remove_item(panel_two,item_two.id)
	
	add_item(panel_one.id,one.unique_id,one.amount,two.slot,one.id,true)
	add_item(panel_two.id,two.unique_id,two.amount,one.slot,two.id,true)


func get_all_panels() -> Dictionary:
	return TypePanel.pull_inventory(TypePanel.PANEL_SLOT_PATH)


func get_panel_id_item(unique_id: int) -> int:
	var all_items = TypePanel.pull_inventory(TypePanel.ITEMS_PATH)
	
	for i in all_items:
		if all_items.get(i).unique_id == unique_id:
			return all_items.get(i).panel_id
	
	return -1

#---------------------------------------------------------


# Adjustments -------------------------------------------
func _is_item_valid(array_item: Array, path: String) -> bool:
	for item in array_item:
		if item.path == path:
			return true
	
	return false

func _function_slot_changed(slot, move) -> void:
	
	set_process_input(is_instance_valid(slot) and move == true)
	
	if is_instance_valid(item_selected):
		
		if item_selected.item_inventory.slot == ERROR.SLOT_BUTTON_VOID:
			if item_selected.item_inventory.amount == 0:
				item_selected.get_parent().queue_free()
	
	if move:
		item_selected = slot.item_node
	else:
		item_selected = null

func _append_item(_panel_slot: Dictionary, _item_panel: Dictionary, _amount: int, _slot: int = ERROR.VOID, _id: int = -1):
	
	var _now_slot: int = _slot
	var _all_items_inventory = TypePanel.pull_inventory(TypePanel.ITEMS_PATH)
	
	if _slot == ERROR.VOID:
		_slot = search_void_slot(_panel_slot.id)
	if _id == -1:
		_id = randi()
	
	_all_items_inventory[str(_id)] = {
		"unique_id" = _item_panel.unique_id,
		"id" = _id,
		"panel_id" = _panel_slot.id,
		"slot" = _slot,
		"amount" = _amount
	}
	
	TypePanel.push_inventory(_all_items_inventory,TypePanel.ITEMS_PATH)
	
	#_new_item.amount = amount
	#_new_item.slot = now_slot
	#_new_item.path = path
	#panel_item.items.append(_new_item)
	new_item.emit(_item_panel,_all_items_inventory.get(str(_id)),_panel_slot)
	
	return _all_items_inventory

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
func get_panel_id(id: int) -> Dictionary:
	var all_panel = TypePanel.pull_inventory(TypePanel.PANEL_SLOT_PATH)
	
	for panels in all_panel:
		
		if all_panel.get(panels).id == id:
			return all_panel.get(panels)
	
	return {}


# Searchs -----------------------------------------------
func search_item(_panel_id: int, _item_unique_id: int = -1, _path : String = "",_slot: int = -1):
	var _all_items: Dictionary = TypePanel.pull_inventory(TypePanel.ITEMS_PATH)
	
	if _slot != -1:
		for _item: String in _all_items:
			if _all_items.get(_item).slot == _slot:
				return _item
	
	#if id == -1 and path != "":
	#	for item in array_items:
	#		if item.path == path:
	#			return item
	#else:
	for _item: String in _all_items:
		if _all_items.get(_item).unique_id == _item_unique_id:
			return _item
	
	return null

func search_item_amount_min(_panel_id: int, _item_unique_id: int, _max_amount:int):
	var _all_items = TypePanel.list_all_inventory_item(_panel_id)
	
	for _item: Dictionary in _all_items:
		
		if _all_items.get(_item).unique_id == _item_unique_id:
			if _item.amount < _max_amount:
				
				return _all_items.get(_item)
	
	return null

func search_void_slot(_panel_id: int) -> int:
	var _all_slot: Array = []
	
	for _item: Dictionary in TypePanel.list_all_inventory_item(_panel_id):
		_all_slot.append(_item.slot)
	
	_all_slot.sort()
	
	for _pass_slot: int in range( get_panel_id(_panel_id).slot_amount ):
		if _pass_slot >= _all_slot.size():
			return _pass_slot
		if _pass_slot != _all_slot[_pass_slot]:
			return _pass_slot
	
	return -1

func search_panel(panel_id: int) -> Dictionary:
	var panel = TypePanel.pull_inventory(TypePanel.PANEL_SLOT_PATH)
	
	for _all in panel:
		
		if panel.get(_all).id == panel_id:
			return panel.get(_all)
	
	return {}


func search_panel_id_item(_item_id: int) -> int:
	var _all_items_inventory: Dictionary = TypePanel.pull_inventory(TypePanel.ITEMS_PATH)
	
	for _item: String in _all_items_inventory:
		if _all_items_inventory.get(_item).id == _item_id:
			
			return _all_items_inventory.get(_item).panel_id
	
	return -1

#---------------------------------------------------------
##===============================================================================
