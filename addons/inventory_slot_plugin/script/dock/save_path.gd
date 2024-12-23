@tool
extends PanelContainer

# Enumeração para definir os modos de caminho
enum MODE_PATH {PLUGIN, UNDEFINED}

# Carregamento de ícones
const SLOT_SAVE_INVENTORY = preload("res://addons/inventory_slot_plugin/assets/icons/slot_save_inventory.tres")
const SLOT_UNSAVE_INVENTORY = preload("res://addons/inventory_slot_plugin/assets/icons/slot_unsave_inventory.tres")

# Referências aos nós do editor
@onready var pluginpath: HBoxContainer = $Vbox/hbox
@onready var plugin_path_button: ButtonVisible = $Vbox/hbox/vbox/SaveButton
@onready var path_global: OptionButton = %path_global
@onready var extension: LineEdit = %extension
@onready var save: Button = $Vbox/hbox/vbox/Save
@onready var path_button: Button = %path
@onready var warning: Label = %warning

# Função chamada quando o nó é carregado
func _ready() -> void:
	# Obtém as configurações do sistema de arquivos
	var _system_file = InventorySystem._get_settings_system()
	
	# Define os valores iniciais dos controles com base nas configurações
	path_global.select(_system_file.path_mode)
	extension.text = _system_file.extension
	path_button.text = _system_file.path
	path_button.tooltip_text = _system_file.path

# Função chamada quando um caminho é selecionado
func path_selection(_path: String) -> void:
	# Atualiza o texto e a dica do botão de caminho
	path_button.text = _path
	path_button.tooltip_text = _path
	
	# Atualiza o ícone do botão de salvar
	save.icon = SLOT_UNSAVE_INVENTORY

# Função chamada quando um item é selecionado no menu de caminho global
func _on_path_global_item_selected(_index: int) -> void:
	# Verifica o modo de caminho selecionado
	match _index:
		MODE_PATH.PLUGIN:
			# Habilita o botão de caminho do plugin e exibe o contêiner
			plugin_path_button.disabled = false
			pluginpath.show()
		MODE_PATH.UNDEFINED:
			# Esconde o contêiner e desabilita o botão de caminho do plugin
			pluginpath.hide()
			plugin_path_button.disabled = true

# Função chamada quando o texto no campo de extensão é alterado
func _on_extension_text_changed(_new_text: String) -> void:
	# Atualiza o ícone do botão de salvar
	save.icon = SLOT_UNSAVE_INVENTORY

# Função chamada quando o botão "Panel System Path" é pressionado
func _on_panel_system_path_pressed() -> void:
	# Cria um explorador de arquivos
	var explorer = EditorFileDialog.new()
	
	# Conecta o sinal de seleção de diretório
	explorer.dir_selected.connect(path_selection)
	explorer.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	explorer.current_dir = InventorySystem._get_settings_system().path
	
	# Adiciona o explorador como filho e exibe o diálogo
	add_child(explorer)
	explorer.popup_file_dialog()

# Função chamada quando o botão "Save" é pressionado
func _on_save_pressed() -> void:
	# Verifica se a extensão tem pelo menos 3 caracteres
	if extension.text.length() <= 2:
		# Exibe o aviso de extensão inválida
		warning.show()
		return
	
	# Esconde o aviso de extensão inválida
	warning.hide()
	
	# Salva as configurações do sistema de arquivos
	InventorySystem.push_system_file(
		path_global.get_selected_id(),
		path_button.text,
		extension.text
	)
	
	# Atualiza o ícone do botão de salvar
	save.icon = SLOT_SAVE_INVENTORY
	
	# Emite o sinal de recarregamento do dock
	Inventory.reload_dock.emit()