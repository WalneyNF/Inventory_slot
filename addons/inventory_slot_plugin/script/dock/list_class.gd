@tool

extends VBoxContainer

# Carrega a cena do painel de classe
var class_panel: PackedScene = preload("res://addons/inventory_slot_plugin/scenes/dock/class.tscn")

# Função chamada quando há uma alteração na interface de itens
func _on_ui_items_change_class() -> void:
	# Remove todos os filhos atuais do contêiner
	for child in get_children():
		child.queue_free()
	
	# Obtém o inventário atual
	var inventory = InventoryFile.pull_inventory(Inventory.ITEM_PANEL_PATH)
	
	# Itera sobre cada classe no inventário
	for _class in inventory:
		# Instancia um novo painel de classe
		var new_panel = class_panel.instantiate()
		
		# Adiciona o painel como filho do contêiner
		add_child(new_panel)
		
		# Inicia o painel com o nome da classe
		new_panel._start(str(_class))