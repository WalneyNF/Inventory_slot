@tool
extends Panel

# Sinal emitido quando o botão "OK" é pressionado
signal ok

# Sinal emitido quando o botão "Cancelar" é pressionado
signal cancel

# Referências aos nós do editor
@onready var tittle_node: Label = $Bar/Panel/Vbox/Tittle
@onready var cancel_node: Button = $Bar/Panel/Vbox/Hbox/Cancel
@onready var ok_node: Button = $Bar/Panel/Vbox/Hbox/Ok

# Função para iniciar o popup com os textos fornecidos
func start(_tittle: String, _cancel: String, _ok: String):
	# Define o texto do título
	tittle_node.text = _tittle
	
	# Define o texto do botão "Cancelar"
	cancel_node.text = _cancel
	
	# Define o texto do botão "OK"
	ok_node.text = _ok

# Função chamada quando o botão "Cancelar" é pressionado
func _on_cancel_pressed() -> void:
	# Emite o sinal de cancelamento
	cancel.emit()
	
	# Remove o popup da árvore
	queue_free()

# Função chamada quando o botão "OK" é pressionado
func _on_ok_pressed() -> void:
	# Emite o sinal de confirmação
	ok.emit()
	
	# Remove o popup da árvore
	queue_free()