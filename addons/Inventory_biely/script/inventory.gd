@tool
extends Node

class_name Inventory_main

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

var item_selected: Control

## Sub functions ================================================================
func _ready() -> void:
	print("to rodando no autoload")
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



func get_amount_panel_inventory_item(panel_id: int) -> int:
	var all = TypePanel.list_all_inventory_item(panel_id)
	var amount: int
	
	for i in all:
		print(i)
		if i.panel_id == panel_id:
			amount += 1
	
	return amount


func remove_item(panel_item: Dictionary, id: int = -1) -> bool:
	
	for items in panel_item.items:
		if items.id == id:
			panel_item.items.erase(items)
			
			discart_item.emit(items,panel_item.id)
			return true
	
	return false


func set_panel_item(item: Dictionary, out_panel_id: int, new_panel_id:int, slot: int = -1, unique: bool = false, out_item_remove: bool = true):
	var out_panel: Dictionary = get_panel_id(out_panel_id)
	var new_panel: Dictionary = get_panel_id(new_panel_id)
	var new_item: Dictionary = item
	
	if new_panel.max_slot == new_panel.items.size() and slot != ERROR.SLOT_BUTTON_VOID:
		if unique:
			return ERROR.NO_SPACE_FOR_ITEM_IN_SLOTS
		else:
			var item_instance = load(item.path).instantiate()
			var search_item = search_item_amount_min(new_panel.items,item.path,item_instance.max_amount)
			
			if search_item != null:
				
				if item_instance.max_amount > search_item.amount:
					
					var size = item_instance.max_amount - search_item.amount
					search_item.amount = search_item.amount + size
					item.amount -= size
					
					new_data_global.emit()
					return new_item
		
		return ERROR.NO_SPACE_FOR_ITEM_IN_SLOTS
	
	if out_item_remove:
		remove_item(out_panel,item.id)
	
	if out_panel == null or new_data == null: return
	
	var result #= add_item(new_panel, new_item.path,new_item.amount,slot,new_item.id,unique)
	
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


func set_slot_item(panel_item: Dictionary, item: Dictionary, slot: int = -1, unique: bool = true) -> void:
	
	var new_item: Dictionary = item
	
	#print(item.id)
	remove_item(panel_item,item.id)
	#add_item(panel_item, new_item.path,new_item.amount,slot,new_item.id,unique)


func changed_slots_items(item_one: Dictionary, item_two: Dictionary) -> void:
	var one = item_one
	var two = item_two
	
	var panel_one #= get_panel_id(search_panel(item_one.id))
	var panel_two #= get_panel_id(search_panel(item_two.id))
	
	remove_item(panel_one,item_one.id)
	remove_item(panel_two,item_two.id)
	
	add_item(panel_one,one.path,one.amount,two.slot,one.id,true)
	add_item(panel_two,two.path,two.amount,one.slot,two.id,true)


func get_all_panels() -> Dictionary:
	return TypePanel.pull_inventory(TypePanel.PANEL_SLOT_PATH)


func get_panel_id_item(unique_id: int) -> Dictionary:
	var all_TypePanel.pull_inventory(TypePanel.PANEL_SLOT_PATH)

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
		
		if item_selected.item.slot == ERROR.SLOT_BUTTON_VOID:
			if item_selected.item.amount == 0:
				item_selected.get_parent().queue_free()
	
	if move:
		item_selected = slot.item_node
	else:
		item_selected = null

func _append_item(panel_slot: Dictionary, item: Dictionary, amount: int, slot: int = ERROR.VOID, id: int = -1):
	var now_slot = slot
	
	#if now_slot == ERROR.VOID:
	#	now_slot = search_void_slot(panel_item)
	
	var _new_item = TypePanel.pull_inventory(TypePanel.ITEMS_PATH)
	
	_new_item[str(randi())] = {
		"slot" = slot,
		"unique_id" = item.unique_id,
		"amount" = amount,
		"panel_id" = panel_slot.id
	}
	
	TypePanel.push_inventory(_new_item,TypePanel.ITEMS_PATH)
	
	#if id == -1:
	#	_new_item.id = randi()
	#else:
	#	_new_item.id = id
	#_new_item.amount = amount
	#_new_item.slot = now_slot
	#_new_item.path = path
	#panel_item.items.append(_new_item)
	#new_item.emit(_new_item,panel_item)
	
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
	var all_panel = TypePanel.pull_inventory(TypePanel.PANEL_SLOT_PATH)
	
	for panels in all_panel:
		
		if all_panel.get(panels).id == id:
			return all_panel.get(panels)


# Searchs -----------------------------------------------
func search_item(panel_id: int, item_unique_id: int = -1, path : String = "",slot: int = -1):
	var all_items = TypePanel.pull_inventory(TypePanel.ITEMS_PATH)
	
	if slot != -1:
		for item in all_items:
			if all_items.get(item).slot == slot:
				return item
	
	#if id == -1 and path != "":
	#	for item in array_items:
	#		if item.path == path:
	#			return item
	#else:
	for item in all_items:
		if all_items.get(item).unique_id == item_unique_id:
			return item
	
	return null

func search_item_amount_min(panel_id: int, item_unique_id: int, max_amount:int):
	var items = TypePanel.list_all_inventory_item(panel_id)
	
	for item in items:
		if items.get(item).unique_id == item_unique_id:
			if item.amount < max_amount:
				return items.get(item)
	
	return null

func search_void_slot(panel_id: int) -> int:
	var all_slot = []
	
	for item in TypePanel.list_all_inventory_item(panel_id):
		all_slot.append(item.slot)
	
	all_slot.sort()
	
	for pass_slot in range(get_panel_id(panel_id).slot_amount):
		if pass_slot >= all_slot.size():
			return pass_slot
		if pass_slot != all_slot[pass_slot]:
			return pass_slot
	
	return -1

func search_panel(panel_id: int) -> Dictionary:
	var panel = TypePanel.pull_inventory(TypePanel.PANEL_SLOT_PATH)
	
	for _all in panel:
		
		if panel.get(_all).id == panel_id:
			return panel.get(_all)
	
	return {}


func search_panel_id_item(item_id: int) -> int:
	var all = TypePanel.pull_inventory(TypePanel.ITEM_PATH)
	
	for panels in all:
		for items in all.get(panels):
			if all.get(panels).get(items).id == item_id:
				return all.get(panels).get(items).id
	
	return -1

#---------------------------------------------------------
##===============================================================================
