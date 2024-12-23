@tool

extends PanelContainer

# Referências aos nós do editor
@onready var edit_name: LineEdit = %edit_name
@onready var name_class: Button = %name_class
@onready var items: VBoxContainer = $Vbox/PanelItems/Vbox/Hbox/Items
@onready var top_bar: PanelContainer = $Vbox/TopBar
@onready var panel_items: PanelContainer = $Vbox/PanelItems
@onready var more_buttons: VBoxContainer = $Vbox/TopBar/Hbox/More/more_buttons

# Variável para controlar se os itens devem ser carregados
var load_items: bool = true

# Sinal emitido quando um item é alterado
signal change_item

# Função chamada para iniciar o painel com o nome da classe
func _start(_class_name: String) -> void:
	# Define o nome da classe no contêiner de itens
	items.my_class_name = _class_name
	
	# Atualiza o texto do botão e do campo de edição com o nome da classe
	name_class.text = _class_name
	edit_name.text = _class_name
	
	# Carrega os itens da classe, se necessário
	if load_items:
		items.load_items()
		load_items = false

# Função chamada quando o texto no campo de edição é submetido
func _on_edit_name_text_submitted(new_text: String) -> void:
	# Obtém o inventário atual
	var inventory = InventoryFile.pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	# Altera o nome da classe no inventário
	InventoryFile.changed_dictionary_name(inventory, name_class.text, new_text)
	
	# Atualiza o nome da classe no contêiner de itens e no botão
	items.my_class_name = new_text
	name_class.text = new_text
	edit_name.hide()
	
	# Salva o inventário atualizado
	InventoryFile.push_inventory(inventory, Inventory.ITEM_PANEL_PATH)
	
	# Emite o sinal de alteração no painel
	Inventory.changed_panel_data.emit()

# Função chamada quando o botão "Novo Item" é pressionado
func _on_new_item_pressed() -> void:
	# Obtém o inventário atual
	var inventory = InventoryFile.pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	# Adiciona um novo item à classe atual
	InventoryFile.push_inventory(InventoryFile.new_item_panel(name_class.text), Inventory.ITEM_PANEL_PATH)
	
	# Emite o sinal de alteração no item
	change_item.emit()

# Função chamada quando o foco do campo de edição é perdido
func _on_edit_name_focus_exited() -> void:
	# Esconde o campo de edição
	edit_name.hide()

# Função chamada quando o botão "Remover" é pressionado
func _on_remove_pressed() -> void:
	# Obtém o inventário atual
	var inventory = InventoryFile.pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	# Remove a classe atual do inventário
	InventoryFile.remove_class(inventory, name_class.text)
	InventoryFile.push_inventory(inventory, Inventory.ITEM_PANEL_PATH)
	
	# Emite o sinal de alteração no painel
	Inventory.changed_panel_data.emit()
	
	# Remove o painel atual
	queue_free()

# Função chamada quando o botão "Editar Nome" é pressionado
func _on_edit_name_pressed() -> void:
	# Mostra o campo de edição e esconde os botões adicionais
	edit_name.show()
	more_buttons.hide()