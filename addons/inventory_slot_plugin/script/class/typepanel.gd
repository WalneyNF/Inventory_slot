class_name TypePanel extends Node

# Variável para controlar o início da atualização
var start_update: bool

# Altera o nome de um item no inventário
static func changed_item_name(_inventory: Dictionary, _class_name: String, _out_item_name: String, _new_item_name: String) -> void:
	# Busca o item no inventário
	var item = InventoryFile.search_item(_inventory, _class_name, _out_item_name)
	
	# Se o item for encontrado, atualiza o nome
	if item != null:
		var new_value = _inventory.get(_class_name).get(_out_item_name)
		
		_inventory.get(_class_name).erase(_out_item_name)
		_inventory.get(_class_name)[_new_item_name] = new_value

# Altera o nome de um item em um dicionário
static func changed_dic_name(_dic: Dictionary, _out_item_name: String, _new_item_name: String) -> void:
	# Busca o item no dicionário
	var item = search_dic(_dic, _out_item_name)
	
	# Se o item for encontrado, atualiza o nome
	if item != null:
		var new_value = _dic.get(_out_item_name)
		
		_dic.erase(_out_item_name)
		_dic[_new_item_name] = new_value

# Busca um item em um dicionário pelo nome
static func search_dic(_dic: Dictionary, _item_name: String):
	for _item in _dic:
		# Verifica se o nome do item corresponde
		if _item_name == _item:
			return _dic.get(_item_name)
	
	# Exibe um erro se o item não for encontrado
	printerr("Item ", _item_name, " não encontrado")

# Retorna o próximo ID único disponível para um item no painel
static func get_item_panel_id_void() -> int:
	var _all_id_array: Array = []
	
	# Obtém o inventário do painel de itens
	var _all_id_dictionary = InventoryFile.pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	# Percorre todas as classes e itens para obter os IDs únicos
	for _all_class in _all_id_dictionary:
		if _all_id_dictionary.get(_all_class) is float: continue
		
		for _items in _all_id_dictionary.get(_all_class):
			_all_id_array.append(_all_id_dictionary.get(_all_class).get(_items).unique_id)
	
	# Ordena os IDs únicos
	_all_id_array.sort()
	
	# Retorna o próximo ID único disponível
	for _id in range(_all_id_array.size()):
		if _id != _all_id_array[_id]:
			return _id
	
	return _all_id_array.size()

# Retorna o número total de itens no painel
static func get_items_size() -> int:
	var _size_item: int = 0
	
	# Obtém o inventário dos painéis de slots
	var _all_slots = InventoryFile.pull_inventory(Inventory.PANEL_SLOT_PATH)
	
	# Conta o número total de itens
	for _all_class in _all_slots:
		for _items in _all_slots.get(_all_class):
			_size_item += 1
	
	return _size_item

# Move o painel quando o mouse é arrastado
func move_panel(event: InputEvent, panel, topbar: Control, panel_parent: BoxContainer) -> void:
	# Verifica se o botão esquerdo do mouse está pressionado
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# Verifica se o evento é de movimento do mouse
		if event is InputEventMouseMotion:
			start_update = true
			# Atualiza a posição do painel com base na posição do mouse
			panel.global_position.y = panel.get_global_mouse_position().y - topbar.size.y / 2
			panel.z_index = 1
	else:
		# Se o botão do mouse for solto, atualiza os itens do painel
		if start_update:
			update_item_panel(panel_parent)
			start_update = false

# Atualiza a ordem dos itens no painel
func update_item_panel(panel_parent: BoxContainer) -> void:
	# Obtém todos os filhos do painel
	var all_child = panel_parent.get_children()
	
	# Ordena os filhos com base na posição
	all_child.sort_custom(sort_position)
	
	# Reorganiza os filhos no painel
	for i in range(all_child.size()):
		panel_parent.move_child(all_child[i], i)
	
	# Atualiza a ordem de renderização e exibe os filhos
	for child in panel_parent.get_children():
		child.z_index = 0
		child.hide()
		child.show()

# Função de comparação para ordenar os itens com base na posição
func sort_position(a, b):
	if a.position.y - (a.size.y / 2) < b.position.y:
		return a