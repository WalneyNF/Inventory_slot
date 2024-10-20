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
	button_slot_changed.connect(_function_slot_changed)

##===============================================================================
# New functions ================================================================

## Main functions ----------------------------------------
func add_item(dic_item: Dictionary, path: String, amount: int = 1, slot: int = -1, unique: bool = false):
	var item = search_item(dic_item.items,-1,path)
	
	
	if dic_item.items.size() != dic_item.max_slot:
		if unique:
			return _append_item(dic_item,path,amount,slot)
	
	if slot == SLOT_BUTTON_VOID: # Para botoes vazios, normalmente craidos com o botao direito.
		var _new_item = _append_item(dic_item,path,amount,SLOT_BUTTON_VOID)
		new_item.emit(_new_item,dic_item.type)
		
		return _new_item
	
	
	if item is Dictionary:
		var item_instance = load(path).instantiate()
		
		if item_instance.max_amount == 1:
			if dic_item.items.size() == dic_item.max_slot:
				return [ERROR.ITEM_LEFT_WITH_FULL_SLOTS,1]
			
			for i in amount:
				_append_item(dic_item,path,1)
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
				
				new_data.emit(item,dic_item.type)
				new_data_global.emit()
				
				for new_amount in separate_amount:
					add_item(dic_item,path,new_amount,-1,true)
			
			return item
			
		else:
			item.amount = item.amount + amount
			
			new_data.emit(item,dic_item.type)
			new_data_global.emit()
			return item
	
	return _append_item(dic_item,path,amount,slot)


func remove_item(dic_item: Dictionary, id: int = -1) -> bool:
	
	for items in dic_item.items:
		if items.id == id:
			dic_item.items.erase(items)
			discart_item.emit(items,dic_item.type)
			return true
	
	return false


func set_panel_item(item: Dictionary, out_type: int, new_type:int, slot: int = -1, unique: bool = false):
	var out_panel: Dictionary = get_panel_type(out_type)
	var new_panel: Dictionary = get_panel_type(new_type)
	
	if out_panel == null or new_data == null: return
	
	var result = add_item(new_panel, item.path,item.amount,slot,unique)
	
	if result is Array:
		match result[0]:
			ERROR.NO_SPACE_FOR_ITEM_IN_SLOTS:
				return
			ERROR.ITEM_LEFT_WITH_FULL_SLOTS:
				item.amount = result[1]
				new_data_global.emit()
				return result
	
	remove_item(out_panel,item.id)
	
	item_entered_panel.emit(item,new_type)
	item_exiting_panel.emit(item,out_type)


func set_slot_item(dic_item: Dictionary, item: Dictionary, slot: int = -1, unique: bool = true) -> void:
	
	add_item(dic_item, item.path,item.amount,slot,unique)
	remove_item(dic_item,item.id)


func changed_slots_items(item_one: Dictionary, item_two: Dictionary) -> void:
	var one = item_one.duplicate()
	var two = item_two.duplicate()
	
	var panel_one = get_panel_type(search_panel(item_one.id))
	var panel_two = get_panel_type(search_panel(item_two.id))
	
	#add_item(dic_item, item.path,item.amount,false,slot)
	
	remove_item(panel_one,item_one.id)
	remove_item(panel_two,item_two.id)
	
	add_item(panel_one,one.path,one.amount,two.slot,true)
	add_item(panel_two,two.path,two.amount,one.slot,true)


func search_panel(item_id: int) -> int:
	for panels in panel_item:
		for items in panel_item.get(panels).items:
			if items.id == item_id:
				return panel_item.get(panels).type
	
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

func _append_item(dic_item: Dictionary, path: String, amount: int, slot: int = ERROR.VOID):
	var now_slot = slot
	
	if now_slot == ERROR.VOID:
		now_slot = search_void_slot(dic_item)
	
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

# Get ---------------------------------------------------
func get_panel_type(type: int):
	for panels in panel_item:
		
		if panel_item.get(panels).type == type:
			return panel_item.get(panels)
	
	return null

# Searchs -----------------------------------------------
func search_item(array_item: Array, id: int = -1, path : String = "",slot: int = -1):
	if slot != -1:
		for item in array_item:
			if item.slot == slot:
				return item
	
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
