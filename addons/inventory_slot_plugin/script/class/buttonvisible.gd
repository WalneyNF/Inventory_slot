@icon("res://addons/inventory_slot_plugin/assets/icons/slot_buttonvisible.tres")
@tool

# Define o nome da classe e herda de Button
class_name ButtonVisible extends Button

# Variável exportada para referenciar o nó de controle que será mostrado/escondido
@export var NodeVisible: Control

# Variável exportada para controlar se o ícone será usado
@export var icon_use: bool = true

# Variável exportada para controlar se o nó será escondido ao perder o foco
@export var no_focus_hide: bool = false

# Array contendo os ícones para o botão (esconder e mostrar)
const SLOT_BUTTON = [
	preload("res://addons/inventory_slot_plugin/assets/icons/slot_hide_button.tres"),
	preload("res://addons/inventory_slot_plugin/assets/icons/slot_show_button.tres")
]

# Função chamada quando o nó é carregado
func _ready() -> void:
	# Aguarda um pequeno intervalo de tempo (0.2 segundos)
	await get_tree().create_timer(0.2).timeout
	
	# Se o ícone estiver habilitado, define o ícone inicial com base na visibilidade do nó
	if icon_use: icon = SLOT_BUTTON[int(NodeVisible.visible)]
	
	# Se a opção de esconder ao perder o foco estiver habilitada, conecta o sinal de foco perdido
	if no_focus_hide: focus_exited.connect(no_focus)

# Função chamada quando o botão é pressionado
func _pressed() -> void:
	# Alterna a visibilidade do nó de controle
	NodeVisible.visible = !NodeVisible.visible
	
	# Atualiza o ícone do botão com base na nova visibilidade do nó
	if icon_use: icon = SLOT_BUTTON[int(NodeVisible.visible)]

# Função chamada quando o botão perde o foco (se habilitado)
func no_focus() -> void:
	# Esconde o nó de controle
	NodeVisible.hide()