@tool

extends Control

# Sinal emitido quando há uma alteração na classe
signal change_class

# Referência ao contêiner que lista as classes
@onready var list_class: VBoxContainer = %ListClass

# Variável para armazenar o arquivo
var file

# Função chamada quando o nó é carregado
func _ready() -> void:
	# Verifica se o arquivo JSON de classes existe
	if !InventoryFile.is_json(Inventory.ITEM_PANEL_PATH):
		# Cria uma nova classe padrão caso o arquivo não exista
		InventoryFile.push_inventory(InventoryFile.new_class("new_class"), Inventory.ITEM_PANEL_PATH)
	
	# Emite o sinal de alteração na classe
	change_class.emit()

# Função chamada quando o botão "Nova Classe" é pressionado
func _on_new_class_pressed() -> void:
	# Verifica se o arquivo JSON de classes existe
	if InventoryFile.is_json(Inventory.ITEM_PANEL_PATH):
		# Abre o arquivo JSON para leitura
		file = FileAccess.open(Inventory.ITEM_PANEL_PATH, FileAccess.READ)
		
		# Faz o parse do JSON para um dicionário
		var items: Dictionary = JSON.parse_string(file.get_as_text())
		file.close()
		
		# Cria uma nova classe com um nome único
		var _new_class = InventoryFile.new_class(str("new_class_", items.size()))
		
		# Salva a nova classe no arquivo
		InventoryFile.push_inventory(_new_class, Inventory.ITEM_PANEL_PATH)
	else:
		# Cria uma nova classe padrão caso o arquivo não exista
		InventoryFile.push_inventory(InventoryFile.new_class("new_class"), Inventory.ITEM_PANEL_PATH)
	
	# Emite o sinal de alteração na classe
	change_class.emit()
	
	# Emite o sinal de alteração nos dados do painel
	Inventory.changed_panel_data.emit()