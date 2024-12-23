class_name InventoryFile extends Node

## File Learns ===================================================================

# Verifica se o arquivo no caminho especificado é um arquivo JSON válido
static func is_json(_path: String) -> bool:
	# Verifica se o arquivo existe
	if !FileAccess.file_exists(_path):
		return false
	else:
		# Abre o arquivo para leitura
		var file = FileAccess.open(_path, FileAccess.READ)
		
		# Verifica se o conteúdo do arquivo é nulo ou vazio
		if file.get_as_text() == null:
			return false
		if file.get_as_text() == "":
			return false
		
		# Faz o parse do JSON
		var json = JSON.parse_string(file.get_as_text())
		
		# Verifica se o JSON é um dicionário
		if json is Dictionary == false:
			return false
		
		# Verifica se o JSON tem pelo menos um item e não está vazio
		if json.size() >= 1 and json != {}:
			return true
	
	return false

# Retorna o conteúdo de um arquivo JSON como um dicionário
static func pull_inventory(_path: String) -> Dictionary:
	# Verifica se o arquivo é um JSON válido
	if is_json(_path):
		# Abre o arquivo para leitura
		var file = FileAccess.open(_path, FileAccess.READ)
		
		# Faz o parse do JSON para um dicionário
		var all_class: Dictionary = JSON.parse_string(file.get_as_text())
		file.close()
		
		return all_class
	
	return {}

# Retorna uma lista de todas as classes do inventário
static func list_all_class() -> Array:
	# Obtém o inventário do painel de itens
	var _all_class: Dictionary = pull_inventory(Inventory.ITEM_PANEL_PATH)
	var _array_class: Array = []
	
	# Percorre todas as classes e adiciona ao array
	for _class in _all_class:
		_array_class.append(_all_class.get(_class))
	
	return _array_class

# Retorna uma lista de todos os itens no inventário, filtrados por painel (opcional)
static func list_all_item_inventory(_panel_id: int = -1) -> Array:
	# Obtém o inventário de itens
	var _inventory = pull_inventory(Inventory.ITEM_INVENTORY_PATH)
	
	var _all_items: Array
	
	# Se nenhum painel for especificado, retorna todos os itens
	if _panel_id == -1:
		for _items in _inventory:
			_all_items.append(_inventory.get(_items))
	else:
		# Filtra os itens pelo ID do painel
		for _items in _inventory:
			if _panel_id == _inventory.get(_items).panel_id:
				_all_items.append(_inventory.get(_items))
	
	return _all_items

# Retorna uma lista de todos os itens no painel, filtrados por painel (opcional)
static func list_all_item_panel(_panel_id: int = -1) -> Array:
	# Obtém o inventário do painel de itens
	var _inventory = pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	var _all_items: Array
	
	# Se nenhum painel for especificado, retorna todos os itens
	if _panel_id == -1:
		for _class in _inventory:
			for _items in _inventory.get(_class):
				_all_items.append(_inventory.get(_class).get(_items))
	else:
		# Filtra os itens pelo ID do painel
		for _class in _inventory:
			for _items in _inventory.get(_class):
				if _panel_id == _inventory.get(_items).panel_id:
					_all_items.append(_inventory.get(_class).get(_items))
	
	return _all_items

# Busca um item no inventário pelo nome da classe e nome do item
static func search_item(_inventory: Dictionary, _class_name: String, _item_name: String):
	for _class in _inventory:
		# Verifica se a classe corresponde
		if _class_name == _class:
			for _item in _inventory.get(_class):
				# Verifica se o item corresponde
				if _item_name == _item:
					return _inventory.get(_class_name).get(_item_name)
	
	# Exibe um erro se o item não for encontrado
	printerr("Item ", _item_name, " não encontrado!")

# Busca um item no inventário pelo ID do painel e ID único do item
static func search_item_id(_panel_id: int, _item_unique_id: int = -1):
	var _items = pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	for _all in _items:
		for _item in _items.get(_all):
			var item = _items.get(_all).get(_item)
			
			# Verifica se a chave 'unique_id' existe no dicionário
			if item.has("unique_id") and item.unique_id == _item_unique_id:
				return item
	
	# Exibe um erro se o item não for encontrado
	printerr("Item ", _item_unique_id, " não encontrado!")
	return null

# Busca uma classe pelo nome
static func search_class_name(_class_name: String):
	var _all_class: Dictionary = InventoryFile.pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	for _class in _all_class:
		if _class == _class_name:
			return _all_class.get(_class)

# Retorna o ID do painel associado a um item pelo ID único do item
static func get_panel_id(_unique_id: int) -> int:
	var all_items = pull_inventory(Inventory.ITEM_INVENTORY_PATH)
	
	for i in all_items:
		if all_items.get(i).unique_id == _unique_id:
			return all_items.get(i).panel_id
	
	return -1

# Retorna o painel associado a um ID de painel
static func get_panel(_panel_id: int) -> Dictionary:
	var _panel = pull_inventory(Inventory.PANEL_SLOT_PATH)
	
	for _all in _panel:
		if _panel.get(_all).id == _panel_id:
			return _panel.get(_all)
	
	return {}

# Retorna o painel associado a um ID único de item
static func get_panel_with_unique_id(_unique_id: int) -> Dictionary:
	var all_items = pull_inventory(Inventory.ITEM_INVENTORY_PATH)
	
	for i in all_items:
		if all_items.get(i).unique_id == _unique_id:
			return all_items.get(i)
	
	return {}

# Retorna o nome do item associado a um ID único de item
static func get_item_name(_unique_id_item: int) -> StringName:
	var _all_items = pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	for _class in _all_items:
		for _items in _all_items.get(_class):
			if _all_items.get(_class).get(_items).unique_id == _unique_id_item:
				return _items
	
	return ""

# Retorna o nome da classe associado a um ID único de item
static func get_class_name(_unique_id_item: int) -> StringName:
	var _all_items = pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	for _class in _all_items:
		for _items in _all_items.get(_class):
			if _all_items.get(_class).get(_items).unique_id == _unique_id_item:
				return _class
	
	return ""

# Retorna o próximo ID único disponível para um item no painel
static func get_item_panel_id_void() -> int:
	var _all_id_array: Array = []
	
	var _all_id_dictionary = pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	for _all_class in _all_id_dictionary:
		if _all_id_dictionary.get(_all_class) is float: continue
		
		for _items in _all_id_dictionary.get(_all_class):
			_all_id_array.append(_all_id_dictionary.get(_all_class).get(_items).unique_id)
	
	_all_id_array.sort()
	
	for _id in range(_all_id_array.size()):
		if _id != _all_id_array[_id]:
			return _id
	
	return _all_id_array.size()

# Retorna uma lista de todos os painéis
static func list_all_panel() -> Array:
	var _all_panel = pull_inventory(Inventory.PANEL_SLOT_PATH)
	var _array_panel: Array
	
	for _panel in _all_panel:
		_array_panel.append(_all_panel.get(_panel))
	
	return _array_panel

## File Whrite ==================================================================

# Salva um dicionário como JSON no caminho especificado
static func push_inventory(_dic: Dictionary, _path: String) -> void:
	var file = FileAccess.open(_path, FileAccess.WRITE)
	
	file.store_string(JSON.stringify(_dic, "\t"))
	file.close()

# Adiciona ou atualiza um item no inventário
static func push_item_inventory(_item_id: int, _item_inventory: Dictionary) -> bool:
	var _all_items = pull_inventory(Inventory.ITEM_INVENTORY_PATH)
	
	if _item_inventory == {}:
		_all_items.erase(str(_item_id))
		push_inventory(_all_items, Inventory.ITEM_INVENTORY_PATH)
		
		return true
	else:
		_all_items[str(_item_id)] = _item_inventory
		push_inventory(_all_items, Inventory.ITEM_INVENTORY_PATH)
		
		return true
	
	return false

# Remove todos os itens do inventário
static func remove_all_item_inventory() -> void:
	for panel in InventoryFile.list_all_panel():
		for item in InventoryFile.list_all_item_inventory(panel.id):
			Inventory.remove_item(panel.id, item.id)

# Altera o nome de um item no inventário
static func _changed_item_name(_inventory: Dictionary, _class_name: String, _out_item_name: String, _new_item_name: String) -> void:
	var item = InventoryFile.search_item(_inventory, _class_name, _out_item_name)
	
	if item != null:
		var new_value = _inventory.get(_class_name).get(_out_item_name)
		
		_inventory.get(_class_name).erase(_out_item_name)
		_inventory.get(_class_name)[_new_item_name] = new_value

# Altera o nome de uma classe no inventário
static func _changed_class_name(_dic: Dictionary, _out_item_name: String, _new_item_name: String) -> void:
	var item = search_class_name(_out_item_name)
	
	if item != null:
		var new_value = _dic.get(_out_item_name)
		
		_dic.erase(_out_item_name)
		_dic[_new_item_name] = new_value

## Dictionary ==================================================================

# Cria um novo item no painel
static func new_item_panel(_class_name: String, _icon_path: String = Inventory.IMAGE_DEFAULT, _amount: int = 1, _description: String = "", _path_scene: String = "res://") -> Dictionary:
	var _new_inventory = pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	for _class in _new_inventory:
		if _class == _class_name:
			_new_inventory.get(_class)[str("new_item_", get_item_panel_id_void())] = {
				"unique_id": get_item_panel_id_void(),
				"icon": _icon_path,
				"max_amount": _amount,
				"description": _description,
				"scene": _path_scene
			}
	
	return _new_inventory

# Cria uma nova classe no inventário
static func new_class(_class_name: String) -> Dictionary:
	var _new_inventory = pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	_new_inventory[_class_name] = {}
	
	return _new_inventory

# Remove um item do inventário
static func remove_item(_inventory: Dictionary, _class_name: String, _item_name: String) -> void:
	_inventory.get(_class_name).erase(_item_name)

# Remove uma classe do inventário
static func remove_class(_inventory: Dictionary, _class_name: String) -> void:
	_inventory.erase(_class_name)

# Altera o nome de uma classe no dicionário
static func changed_dictionary_name(_dictionary: Dictionary, _class_name: String, _new_class_name: String) -> Dictionary:
	var new_value = _dictionary.get(_class_name)
	
	_dictionary.erase(_class_name)
	_dictionary[_new_class_name] = new_value
	
	return _dictionary

##====================================================================
