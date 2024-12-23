@tool

extends VBoxContainer

# Nome da classe atual
var my_class_name

# Carrega a cena do painel de item
var itempanel = preload("res://addons/inventory_slot_plugin/scenes/dock/item_panel.tscn")

# Função para carregar os itens da classe
func load_items() -> void:
	# Remove todos os filhos atuais do contêiner
	for child in get_children():
		child.queue_free()
	
	# Verifica se o arquivo JSON existe
	if InventoryFile.is_json(Inventory.ITEM_PANEL_PATH):
		# Remove todos os filhos atuais do contêiner novamente (redundante)
		for child in get_children():
			child.queue_free()
		
		# Abre o arquivo JSON para leitura
		var file = FileAccess.open(Inventory.ITEM_PANEL_PATH, FileAccess.READ)
		var all_class = JSON.parse_string(file.get_as_text())
		
		file.close()
		
		# Itera sobre todas as classes no arquivo JSON
		for _class in all_class:
			# Verifica se a classe corresponde ao nome da classe atual
			if _class == my_class_name:
				# Ignora valores inválidos (como floats)
				if all_class.get(_class) is float: continue
				
				# Itera sobre os itens da classe
				for items in all_class.get(_class):
					var new_item = all_class.get(_class).get(items)
					
					# Instancia um novo painel de item
					var new_panel = itempanel.instantiate()
					
					# Adiciona o painel como filho do contêiner
					add_child(new_panel)
					
					# Inicia o painel com os dados do item
					new_panel.start(items, new_item)

# Função chamada quando há uma alteração nos itens da classe
func _on_class_change_item() -> void:
	# Remove todos os filhos atuais do contêiner
	for child in get_children():
		child.queue_free()
	
	# Abre o arquivo JSON para leitura
	var file = FileAccess.open(Inventory.ITEM_PANEL_PATH, FileAccess.READ)
	var all_class = JSON.parse_string(file.get_as_text())
	
	file.close()
	
	# Itera sobre todas as classes no arquivo JSON
	for _class in all_class:
		# Verifica se a classe corresponde ao nome da classe atual
		if _class == my_class_name:
			# Itera sobre os itens da classe
			for items in all_class.get(_class):
				var new_item = all_class.get(_class).get(items)
				
				# Instancia um novo painel de item
				var new_panel = itempanel.instantiate()
				
				# Adiciona o painel como filho do contêiner
				add_child(new_panel)
				
				# Inicia o painel com os dados do item
				new_panel.start(items, new_item)