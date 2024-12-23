extends TextureRect

# Enumeração para definir os pontos de ancoragem da quantidade
enum AMOUNT_ANCHOR {LEFT_UP, LEFT_DOWN, RIGHT_UP, RIGHT_DOWN}

# Referência ao nó de texto da quantidade
@onready var node_amount_text: Label = $Amount

# Variáveis para armazenar os dados do item e do painel
var item_inventory: Dictionary
var panel_slot: Dictionary
var item_settings: Dictionary

# Função chamada quando o nó é carregado
func _ready() -> void:
	# Obtém as configurações do item
	item_settings = InventoryFile.pull_inventory(Inventory.ITEM_SETTINGS)
	
	# Conecta os sinais do sistema de inventário
	Inventory.new_data.connect(reload_my_data)
	Inventory.new_data_global.connect(reload_data)
	Inventory.discart_item.connect(remove_item)
	
	# Carrega a visualização do item
	load_visual()

# Função para carregar a visualização do item
func load_visual() -> void:
	# Obtém os dados do item no painel
	var item_panel = InventoryFile.search_item_id(panel_slot.id, item_inventory.unique_id)
	
	# Define a textura do item
	texture = load(item_panel.icon)
	
	# Atualiza o texto da quantidade
	node_amount_text.text = str(item_inventory.amount)
	
	# Atualiza os dados e ajusta a posição da quantidade
	reload_data()
	anchor_visual_amount()
	
	# Define a ordem de renderização para slots vazios
	if item_inventory.slot == Inventory.ERROR.SLOT_BUTTON_VOID:
		z_index = 1

# Função para recarregar os dados do item
func reload_my_data(_item_panel: Dictionary , _item_inventory: Dictionary , _system_slot: Dictionary) -> void:
	# Verifica se o item atual é o mesmo que está sendo atualizado
	if item_inventory.id == _item_inventory.id:
		item_inventory = _item_inventory
		
		# Atualiza os dados
		# reload_data()

# Função para recarregar os dados globais
func reload_data() -> void:
	# Remove o item se a quantidade for zero
	if item_inventory.amount == 0:
		Inventory.remove_item(panel_slot.id, item_inventory.id)
	
	# Atualiza o texto da quantidade
	node_amount_text.text = str(item_inventory.amount)
	
	# Mostra ou esconde a quantidade com base nas configurações
	node_amount_text.visible = bool(int(item_settings.amount_show_being_one) + int(item_inventory.amount > 1))

# Função para gerar a descrição do item
func item_more() -> String:
	var _description: String
	
	# Adiciona o nome do item, se habilitado
	if item_settings.description_name_item:
		_description += InventoryFile.get_item_name(item_inventory.unique_id)
		_description += "\n"
	
	# Adiciona a quantidade do item, se habilitado
	if item_settings.description_amount_show:
		_description += str(item_settings.amount_text, ": ", item_inventory.amount, "/", InventoryFile.search_item_id(panel_slot.id, item_inventory.unique_id).max_amount)
		_description += "\n"
	
	# Adiciona a descrição do item, se habilitado
	if item_settings.description_description:
		_description += InventoryFile.search_item_id(panel_slot.id, item_inventory.unique_id).description
	
	return _description

# Função para remover o item
func remove_item(item_panel: Dictionary ,_item_inventory: Dictionary  ,system_slot: Dictionary) -> void:
	# Verifica se o item atual é o mesmo que está sendo removido
	if item_inventory.id == _item_inventory.id:
		queue_free()
		#print(_item_inventory)

# Função para ajustar a posição da quantidade no item
func anchor_visual_amount() -> void:
	# Define o alinhamento da quantidade com base nas configurações
	match int(item_settings.amount_anchor):
		AMOUNT_ANCHOR.LEFT_UP:
			node_amount_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			node_amount_text.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		AMOUNT_ANCHOR.LEFT_DOWN:
			node_amount_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			node_amount_text.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		AMOUNT_ANCHOR.RIGHT_UP:
			node_amount_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			node_amount_text.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		AMOUNT_ANCHOR.RIGHT_DOWN:
			node_amount_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			node_amount_text.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM