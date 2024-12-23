@tool
extends PanelContainer

# Referências aos nós do editor
@onready var panels: VBoxContainer = $Scroll/Panels
@onready var remove_theme: Button = %RemoveTheme
@onready var save_inventory: Button = %SaveInventory
@onready var documentation: PanelContainer = $Documentation

# Carregamento de recursos
var POPUP = load(str(Inventory.PLUGIN_PATH, "/scenes/dock/popup.tscn"))
var SLOT_ALL = load(str(Inventory.PLUGIN_PATH, "/scenes/dock/slot_all.tscn"))
var THEME_DEFAULT = load(str(Inventory.PLUGIN_PATH, "/assets/themes/default.tres"))
var SLOT_THEME_DEFAULT = load(str(Inventory.PLUGIN_PATH, "/assets/icons/slot_theme_default.tres"))
var SLOT_THEME_GODOT = load(str(Inventory.PLUGIN_PATH, "/assets/icons/slot_theme_godot.tres"))
var SLOT_UNSAVE_INVENTORY = load(str(Inventory.PLUGIN_PATH, "/assets/icons/slot_unsave_inventory.tres"))
var SLOT_SAVE_INVENTORY = load(str(Inventory.PLUGIN_PATH, "/assets/icons/slot_save_inventory.tres"))

# Função chamada quando o nó é carregado
func _ready() -> void:
	# Conecta o sinal de recarregamento do dock
	Inventory.reload_dock.connect(reload)
	
	# Gera os painéis iniciais
	generate()

# Função para gerar os painéis
func generate() -> void:
	# Instancia um novo slot "all" e adiciona ao contêiner de painéis
	var new_slotall = SLOT_ALL.instantiate()
	panels.add_child(new_slotall)

# Função para recarregar os painéis
func reload() -> void:
	# Remove o painel atual e gera um novo
	panels.get_child(2).queue_free()
	generate()

# Função chamada quando o botão "Reload Plugin" é pressionado
func _on_reload_plugin_pressed() -> void:
	reload()

# Função chamada quando o botão "Remove Theme" é pressionado
func _on_remove_theme_pressed() -> void:
	# Alterna entre o tema padrão e o tema do Godot
	if theme == null:
		theme = THEME_DEFAULT
		remove_theme.icon = SLOT_THEME_DEFAULT
		return
	
	remove_theme.icon = SLOT_THEME_GODOT
	theme = null

# Função chamada quando o botão "Delete Inventory" é pressionado
func _on_delete_inventory_pressed() -> void:
	# Instancia um popup de confirmação
	var popup = POPUP.instantiate()
	
	add_child(popup)
	
	# Inicia o popup com mensagem e botões
	popup.start(
		"Você realmente deseja remover todos os itens do inventário?",
		"No",
		"Yes"
	)
	
	# Conecta o sinal de confirmação ao método de remoção de itens
	popup.ok.connect(remove_all_item_inventory)

# Função para remover todos os itens do inventário
func remove_all_item_inventory() -> void:
	InventoryFile.remove_all_item_inventory()

# Função chamada quando o botão "Save Inventory" é pressionado
func _on_save_inventory_pressed() -> void:
	# Atualiza o ícone do botão de salvar inventário
	save_inventory.icon

# Função chamada quando o botão "Document" é pressionado
func _on_document_pressed() -> void:
	# Exibe o painel de documentação
	documentation.show()

# Função chamada quando o botão "Top" é pressionado
func _on_top_pressed() -> void:
	# Esconde o painel de documentação
	documentation.hide()