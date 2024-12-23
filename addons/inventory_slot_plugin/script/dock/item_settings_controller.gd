@tool

extends PanelContainer

# Enumeração para definir os pontos de ancoragem da quantidade
enum AMOUNT_ANCHOR {LEFT_UP, LEFT_DOWN, RIGHT_UP, RIGHT_DOWN}

# Referências aos nós do editor
@onready var amount_text: LineEdit = $Vbox/Hbox/Vbox/Amount/Vbox/Hbox/Vbox/name/name
@onready var amount_anchor: OptionButton = $Vbox/Hbox/Vbox/Amount/Vbox/Hbox/Vbox/anchor/anchor
@onready var amount_show_being_one: CheckBox = $Vbox/Hbox/Vbox/Amount/Vbox/Hbox/Vbox/shown_being_one/shown_being_one

@onready var description_name_item: CheckBox = $Vbox/Hbox/Vbox/Description/Vbox/Hbox/Vbox/name_item_show/name_item_show
@onready var description_amount_show: CheckBox = $Vbox/Hbox/Vbox/Description/Vbox/Hbox/Vbox/amount_show/amount_show
@onready var description_description: CheckBox = $Vbox/Hbox/Vbox/Description/Vbox/Hbox/Vbox/description/description

# Variável para armazenar as configurações do item
var _item_settings

# Função chamada quando o nó é carregado
func _ready() -> void:
	# Verifica se o arquivo de configurações existe
	if InventoryFile.is_json(Inventory.ITEM_SETTINGS):
		# Carrega as configurações do arquivo
		_item_settings = InventoryFile.pull_inventory(Inventory.ITEM_SETTINGS)
		
		# Atualiza os valores dos controles com base nas configurações
		amount_text.text = _item_settings.amount_text
		amount_anchor.selected = _item_settings.amount_anchor
		amount_show_being_one.button_pressed = _item_settings.amount_show_being_one
		
		description_name_item.button_pressed = _item_settings.description_name_item
		description_amount_show.button_pressed = _item_settings.description_amount_show
		description_description.button_pressed = _item_settings.description_description
	else:
		# Define as configurações padrão caso o arquivo não exista
		_item_settings = {
			"amount_text": "Amount",
			"amount_anchor": AMOUNT_ANCHOR.LEFT_UP,
			"amount_show_being_one": false,
			
			"description_name_item": true,
			"description_amount_show": true,
			"description_description": true,
		}
		
		# Salva as configurações padrão no arquivo
		InventoryFile.push_inventory(_item_settings, Inventory.ITEM_SETTINGS)

# Função chamada quando o texto no campo "amount_text" é submetido
func _on_name_text_submitted(new_text: String) -> void:
	# Atualiza o texto da quantidade nas configurações
	_item_settings.amount_text = new_text
	amount_text.release_focus()
	
	# Salva as configurações atualizadas
	InventoryFile.push_inventory(_item_settings, Inventory.ITEM_SETTINGS)

# Função chamada quando um item é selecionado no menu "amount_anchor"
func _on_anchor_item_selected(index: int) -> void:
	# Atualiza o ponto de ancoragem da quantidade nas configurações
	_item_settings.amount_anchor = index
	
	# Salva as configurações atualizadas
	InventoryFile.push_inventory(_item_settings, Inventory.ITEM_SETTINGS)

# Função chamada quando o botão "amount_show_being_one" é pressionado
func _on_shown_being_one_pressed() -> void:
	# Atualiza a opção de mostrar a quantidade mesmo que seja 1
	_item_settings.amount_show_being_one = amount_show_being_one.button_pressed
	
	# Salva as configurações atualizadas
	InventoryFile.push_inventory(_item_settings, Inventory.ITEM_SETTINGS)

# Função chamada quando o botão "description_name_item" é pressionado
func _on_name_item_show_pressed() -> void:
	# Atualiza a opção de mostrar o nome do item na descrição
	_item_settings.description_name_item = description_name_item.button_pressed
	
	# Salva as configurações atualizadas
	InventoryFile.push_inventory(_item_settings, Inventory.ITEM_SETTINGS)

# Função chamada quando o botão "description_amount_show" é pressionado
func _on_amount_show_pressed() -> void:
	# Atualiza a opção de mostrar a quantidade na descrição
	_item_settings.description_amount_show = description_amount_show.button_pressed
	
	# Salva as configurações atualizadas
	InventoryFile.push_inventory(_item_settings, Inventory.ITEM_SETTINGS)

# Função chamada quando o botão "description_description" é pressionado
func _on_description_pressed() -> void:
	# Atualiza a opção de mostrar a descrição do item
	_item_settings.description_description = description_description.button_pressed
	
	# Salva as configurações atualizadas
	InventoryFile.push_inventory(_item_settings, Inventory.ITEM_SETTINGS)