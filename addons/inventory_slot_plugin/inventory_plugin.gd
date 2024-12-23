@tool

extends EditorPlugin

# Variável para armazenar o dock (painel) do plugin
var dock 

# Função chamada quando o plugin é carregado no editor
func _enter_tree() -> void:
	# Importa as configurações do plugin
	_import_settings()
	# Configura e prepara o plugin
	_ready_plugin()

# Função chamada quando o plugin é descarregado do editor
func _exit_tree():
	# Remove o dock do editor
	remove_control_from_docks(dock)
	# Libera a memória ocupada pelo dock
	dock.free()

# Função para configurar e preparar o plugin
func _ready_plugin() -> void:
	# Obtém o caminho base do plugin
	var inventory_slot_plugin_path = str(get_script().resource_path).get_base_dir()
	
	# Adiciona um singleton para o inventário
	add_autoload_singleton("Inventory",str(inventory_slot_plugin_path,"/script/slot/inventory.gd"))
	
	# Aguarda um pequeno intervalo de tempo (configurado para 0.2 segundos)
	await get_tree().create_timer(0.2).timeout # Tempo definido na configuração
	
	# Carrega e instancia a cena do dock
	dock = load(str(inventory_slot_plugin_path,"/scenes/dock/ivt_slot.tscn")).instantiate()
	# Adiciona o dock ao editor na posição especificada
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL,dock)

# Função para importar as configurações do plugin
func _import_settings() -> void:
	# Obtém o caminho base do plugin
	var _path: String = get_script().resource_path.get_base_dir()
	
	# Verifica se as configurações do sistema de inventário estão vazias
	if InventorySystem._get_settings_system() == {}:
		# Cria o sistema de arquivos para o inventário
		InventorySystem._create_file_system(0,_path)
	
	# Verifica se o diretório de salvamento existe
	if !DirAccess.dir_exists_absolute(str(InventorySystem.get_save_path(),"/save")):
		# Obtém o sistema de arquivos
		var _file_system = InventorySystem._get_settings_system()
		
		# Cria o caminho JSON para salvar os dados
		InventorySystem._create_json_path(
			_path,
			_file_system.extension,
			true
		)
	
	# Atualiza o caminho do sistema de inventário
	InventorySystem._update_path()

# Função para recarregar o plugin
func reload() -> void:
	# Remove o dock do editor
	remove_control_from_docks(dock)
	# Reconfigura e prepara o plugin novamente
	_ready_plugin()