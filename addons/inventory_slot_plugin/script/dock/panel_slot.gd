@tool
extends TypePanel

# Referências aos nós do editor
@onready var option_class: OptionButton = %Class
@onready var panel_name: LineEdit = %PanelName
@onready var id: SpinBox = %Id
@onready var amount: SpinBox = %Amount
@onready var tittle: ButtonVisible = %Tittle
@onready var settings: VBoxContainer = $Vbox/Settings
@onready var top_bar: HBoxContainer = $Vbox/TopBar
@onready var id_warning: Label = $Vbox/Settings/ID/Warning

# Variáveis para armazenar o nome do painel e o controle do slot
var out_panel_name: String
var panel_slot_controller: Control
var option_selected: int 

# Função chamada quando o nó é carregado
func _ready() -> void:
	# Esconde o contêiner de configurações inicialmente
	settings.hide()
	
	# Conecta o sinal de alteração de dados do painel
	Inventory.changed_panel_data.connect(update_option_class)
	
	# Atualiza as opções de classe
	update_option_class()

# Função para iniciar o painel com os dados fornecidos
func start(_panel_name: StringName, _id: int, slot_amount: int, class_unique: String) -> void:
	# Define os valores iniciais do painel
	out_panel_name = _panel_name
	panel_name.text = _panel_name
	id.value = _id
	amount.value = slot_amount
	
	# Seleciona a classe única no menu de opções
	for i in option_class.item_count:
		if option_class.get_item_text(i) == class_unique:
			option_class.select(i)
	
	# Atualiza o título do painel
	tittle.text = str(_id, " - ", _panel_name)

# Função para atualizar as opções de classe
func update_option_class() -> void:
	# Limpa as opções atuais do menu de classes
	option_class.clear()
	option_class.add_item("all")
	
	# Obtém todas as classes do inventário
	var _all_class = InventoryFile.pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	# Adiciona as classes ao menu de opções
	for _class in _all_class:
		option_class.add_item(_class)
	
	# Seleciona a opção previamente selecionada
	option_class.select(option_selected)

# Função para alterar o nome do painel
func change_panel_name(new_name: String) -> void:
	# Remove o foco do campo de texto
	panel_name.release_focus()
	
	# Obtém os painéis atuais
	var panels = InventoryFile.pull_inventory(Inventory.PANEL_SLOT_PATH)
	
	# Altera o nome do painel no inventário
	changed_dic_name(panels, out_panel_name, new_name)
	
	# Salva as alterações no inventário
	InventoryFile.push_inventory(panels, Inventory.PANEL_SLOT_PATH)
	
	# Atualiza o nome do painel
	out_panel_name = new_name
	
	# Atualiza o título do painel
	tittle.text = str(id.value, " - ", out_panel_name)
	
	# Emite o sinal de alteração de dados do painel
	Inventory.changed_panel_data.emit()

# Função chamada quando o botão "Remover" é pressionado
func _on_remove_pressed() -> void:
	# Obtém os painéis atuais
	var panels = InventoryFile.pull_inventory(Inventory.PANEL_SLOT_PATH)
	
	# Remove o painel atual do inventário
	for panel in panels:
		if panels.get(panel).id == id.value:
			panels.erase(panel)
	
	# Salva as alterações no inventário
	InventoryFile.push_inventory(panels, Inventory.PANEL_SLOT_PATH)
	
	# Emite o sinal de alteração de dados do painel
	Inventory.changed_panel_data.emit()
	
	# Remove o painel atual
	queue_free()

# Função chamada quando o texto no campo "PanelName" é submetido
func _on_panel_name_text_submitted(new_text: String) -> void:
	# Altera o nome do painel
	change_panel_name(new_text)

# Função chamada quando o valor do campo "Id" é alterado
func _on_id_value_changed(value: float) -> void:
	# Obtém os painéis atuais
	var panels = InventoryFile.pull_inventory(Inventory.PANEL_SLOT_PATH)
	
	# Verifica se o ID já está em uso
	for panel in panels:
		if panel != out_panel_name:
			if panels.get(panel).id == value:
				id_warning.show()
				return
	
	# Esconde o aviso de ID duplicado
	id_warning.hide()
	
	# Obtém o dicionário do painel atual
	var dic = search_dic(panels, out_panel_name)
	
	# Atualiza o ID do painel
	dic.id = value
	
	# Salva as alterações no inventário
	InventoryFile.push_inventory(panels, Inventory.PANEL_SLOT_PATH)
	
	# Atualiza o título do painel
	tittle.text = str(value, " - ", out_panel_name)
	
	# Emite o sinal de alteração de dados do painel
	Inventory.changed_panel_data.emit()

# Função chamada quando o valor do campo "Amount" é alterado
func _on_amount_value_changed(value: float) -> void:
	# Obtém os painéis atuais
	var panels = InventoryFile.pull_inventory(Inventory.PANEL_SLOT_PATH)
	
	# Obtém o dicionário do painel atual
	var dic = search_dic(panels, out_panel_name)
	
	# Atualiza a quantidade de slots do painel
	dic.slot_amount = value
	
	# Salva as alterações no inventário
	InventoryFile.push_inventory(panels, Inventory.PANEL_SLOT_PATH)
	
	# Emite o sinal de alteração de dados do painel
	Inventory.changed_panel_data.emit()

# Função chamada quando uma opção de classe é selecionada
func _on_class_item_selected(index: int) -> void:
	# Armazena a opção selecionada
	option_selected = index
	
	# Obtém os painéis atuais
	var panels = InventoryFile.pull_inventory(Inventory.PANEL_SLOT_PATH)
	
	# Obtém o dicionário do painel atual
	var dic = search_dic(panels, out_panel_name)
	
	# Atualiza a classe única do painel
	dic.class_unique = option_class.get_item_text(index)
	
	# Salva as alterações no inventário
	InventoryFile.push_inventory(panels, Inventory.PANEL_SLOT_PATH)
	
	# Emite o sinal de alteração de dados do painel
	Inventory.changed_panel_data.emit()

# Função chamada quando ocorre um evento de entrada no título do painel
func _on_tittle_gui_input(event: InputEvent) -> void:
	# Move o painel com base no evento do mouse
	move_panel(event, self, top_bar, get_parent())

# Função chamada quando o foco do campo "PanelName" é perdido
func _on_panel_name_focus_exited() -> void:
	# Altera o nome do painel
	change_panel_name(panel_name.text)

# Função chamada quando o botão "Editar Nome" é pressionado
func _on_edit_name_pressed() -> void:
	# Mostra o campo de edição e seleciona o texto
	tittle.NodeVisible.show()
	panel_name.grab_focus()
	panel_name.select_all()