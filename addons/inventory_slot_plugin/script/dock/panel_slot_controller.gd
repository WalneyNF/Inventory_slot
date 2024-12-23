@tool
extends PanelContainer

# Carrega a cena do painel de slot
const PANEL_SLOT = preload("res://addons/inventory_slot_plugin/scenes/dock/panel_slot.tscn")

# Referência ao contêiner que lista os painéis
@onready var panel_list: VBoxContainer = %PanelList

# Função chamada quando o nó é carregado
func _ready() -> void:
	# Verifica se o arquivo JSON de painéis existe
	if !InventoryFile.is_json(Inventory.PANEL_SLOT_PATH):
		# Cria um painel padrão caso o arquivo não exista
		var new_panel = {
			"Void": {
				"class_unique": "all",
				"id": -2,
				"slot_amount": 15
			}
		}
		
		# Salva o painel padrão no arquivo
		InventoryFile.push_inventory(new_panel, Inventory.PANEL_SLOT_PATH)
	
	# Atualiza a lista de painéis
	update_panel()

# Função chamada quando o botão "Criar Painel" é pressionado
func _on_create_panel_pressed() -> void:
	# Obtém todos os painéis atuais
	var all_panel_slot = InventoryFile.pull_inventory(Inventory.PANEL_SLOT_PATH)
	
	# Adiciona um novo painel ao inventário
	all_panel_slot[str("NewPanel_", all_panel_slot.size() - 1)] = {
		"id": all_panel_slot.size() - 1,
		"slot_amount": 4,
		"class_unique": "all",
	}
	
	# Salva os painéis atualizados no arquivo
	InventoryFile.push_inventory(all_panel_slot, Inventory.PANEL_SLOT_PATH)
	
	# Atualiza a lista de painéis
	update_panel()

# Função para atualizar a lista de painéis
func update_panel() -> void:
	# Remove todos os filhos atuais do contêiner de painéis
	for child in panel_list.get_children():
		child.queue_free()
	
	# Obtém todos os painéis do inventário
	var _all_panel = InventoryFile.pull_inventory(Inventory.PANEL_SLOT_PATH)
	
	# Itera sobre cada painel no inventário
	for _panel_name in _all_panel:
		var _panel = _all_panel.get(_panel_name)
		
		# Ignora painéis com IDs inválidos
		if _panel.id == Inventory.ERROR.SLOT_BUTTON_VOID: continue
		
		# Instancia um novo painel de slot
		var new_panel = PANEL_SLOT.instantiate()
		
		# Adiciona o painel como filho do contêiner de painéis
		panel_list.add_child(new_panel)
		
		# Define o controlador do painel
		new_panel.panel_slot_controller = self
		
		# Inicia o painel com os dados do painel atual
		new_panel.start(_panel_name, _panel.id, _panel.slot_amount, _panel.class_unique)