@tool

extends TypePanel

# Enumeração para seleção de tipo de arquivo
enum SELECTION {ICON, SCENE}

# Referências aos nós do editor
@onready var icon: Button = %Icon
@onready var edit_item_name: LineEdit = %item_name
@onready var scene: Button = %scene
@onready var id_unique: Button = $Vbox/TopBar/Hbox/id_unique
@onready var top_bar: PanelContainer = $Vbox/TopBar
@onready var hbox: HBoxContainer = $Vbox/Hbox
@onready var id: SpinBox = %id
@onready var description: TextEdit = %description

# Variáveis para armazenar o nome e os dados do item
var item_name: String
var item: Dictionary
var selection: int

# Função chamada quando o nó é carregado
func _ready() -> void:
	hbox.hide()

# Função para iniciar o painel com os dados do item
func start(_item_name: String, _item: Dictionary) -> void:
	# Carrega o ícone do item
	icon.icon = load(_item.icon)
	item_name = _item_name
	item = _item
	scene.text = _item.scene
	
	# Atualiza a visualização do item
	update_visual()

# Função para atualizar a visualização do item
func update_visual() -> void:
	edit_item_name.text = item_name
	id_unique.text = str(item.unique_id, " - ", item_name)
	id.value = item.unique_id
	description.text = item.description

# Função para abrir o explorador de arquivos
func call_file_dialog(filters: Array) -> void:
	var explorer = EditorFileDialog.new()
	
	# Conecta o sinal de seleção de arquivo
	explorer.file_selected.connect(file_selection)
	explorer.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	explorer.filters = filters
	
	# Adiciona o explorador como filho e exibe o diálogo
	add_child(explorer)
	explorer.popup_file_dialog()

# Função chamada quando um arquivo é selecionado
func file_selection(path: String) -> void:
	# Obtém o inventário atual
	var inventory = InventoryFile.pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	# Verifica o tipo de seleção e atualiza o item correspondente
	match selection:
		SELECTION.ICON:
			icon.icon = load(path)
			
			item = InventoryFile.search_item(inventory, get_parent().my_class_name, item_name)
			item.icon = path
			InventoryFile.push_inventory(inventory, Inventory.ITEM_PANEL_PATH)
		SELECTION.SCENE:
			scene.text = path
			
			item = InventoryFile.search_item(inventory, get_parent().my_class_name, item_name)
			item.scene = path
			InventoryFile.push_inventory(inventory, Inventory.ITEM_PANEL_PATH)

# Função chamada quando o botão "Scene" é pressionado
func _on_scene_pressed() -> void:
	selection = SELECTION.SCENE
	call_file_dialog(["*tscn"])

# Função chamada quando o botão "Icon" é pressionado
func _on_icon_pressed() -> void:
	selection = SELECTION.ICON
	call_file_dialog(["*png", "*svg", "*jpg"])

# Função chamada quando ocorre um evento de entrada no botão "id_unique"
func _on_id_unique_gui_input(event: InputEvent) -> void:
	# Move o painel com base no evento do mouse
	move_panel(event, self, top_bar, get_parent())
	
	# Atualiza a visualização do item
	update_visual()

# Função chamada quando o texto no campo de edição do nome do item é submetido
func _on_item_name_text_submitted(new_text: String) -> void:
	# Obtém o inventário atual
	var inventory = InventoryFile.pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	# Remove o foco do campo de edição
	edit_item_name.release_focus()
	
	# Altera o nome do item no inventário
	changed_item_name(inventory, get_parent().my_class_name, item_name, new_text)
	InventoryFile.push_inventory(inventory, Inventory.ITEM_PANEL_PATH)
	
	# Atualiza o nome do item e a visualização
	item_name = new_text
	update_visual()

# Função chamada quando o valor do campo "max_amount" é alterado
func _on_max_amount_value_changed(value: float) -> void:
	# Obtém o inventário atual
	var inventory = InventoryFile.pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	# Atualiza o valor máximo do item no inventário
	item = InventoryFile.search_item(inventory, get_parent().my_class_name, item_name)
	item.max_amount = int(value)
	InventoryFile.push_inventory(inventory, Inventory.ITEM_PANEL_PATH)

# Função chamada quando o texto na descrição é alterado
func _on_description_text_changed() -> void:
	# Obtém o inventário atual
	var inventory = InventoryFile.pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	# Atualiza a descrição do item no inventário
	item = InventoryFile.search_item(inventory, get_parent().my_class_name, item_name)
	item.description = description.text
	
	InventoryFile.push_inventory(inventory, Inventory.ITEM_PANEL_PATH)

# Função chamada quando o botão "Remover" é pressionado
func _on_remove_pressed() -> void:
	# Obtém o inventário atual
	var inventory = InventoryFile.pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	# Remove o item do inventário
	InventoryFile.remove_item(inventory, get_parent().my_class_name, item_name)
	InventoryFile.push_inventory(inventory, Inventory.ITEM_PANEL_PATH)
	
	# Remove o painel atual
	queue_free()

# Função chamada quando o botão "Editar Nome" é pressionado
func _on_edit_name_pressed() -> void:
	# Mostra o campo de edição e seleciona o texto
	id_unique.NodeVisible.show()
	edit_item_name.grab_focus()
	edit_item_name.select_all()