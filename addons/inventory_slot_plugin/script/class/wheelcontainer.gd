@tool
@icon("res://addons/inventory_slot_plugin/assets/icons/slot_whellcontainer.tres")
extends Container

# Define o nome da classe e herda de Container
class_name WheelContainer

# Propriedade exportada para definir o tamanho da roda
@export var wheel_size: Vector2 = Vector2(1, 1):
	set(value):
		wheel_size = value
		start()  # Atualiza a posição dos filhos quando o valor é alterado

# Propriedade exportada para definir a rotação da roda (em graus)
@export_range(0.0, 360.0) var wheel_rotation: float = 0.0:
	set(value):
		wheel_rotation = value
		start()  # Atualiza a posição dos filhos quando o valor é alterado

# Função chamada para desenhar o contêiner
func _draw() -> void:
	start()  # Inicia a configuração da posição dos filhos

# Função chamada quando o nó é carregado
func _ready() -> void:
	start()  # Inicia a configuração da posição dos filhos
	
	# Conecta os sinais de entrada e saída de filhos
	child_entered_tree.connect(child_enter)
	child_exiting_tree.connect(child_exit)

# Função chamada quando um filho entra na árvore
func child_enter(node) -> void:
	start()  # Atualiza a posição dos filhos

# Função chamada quando um filho está saindo da árvore
func child_exit(node) -> void:
	start()  # Atualiza a posição dos filhos

# Função principal para configurar a posição dos filhos
func start() -> void:
	
	# Obtém o número de filhos no contêiner
	var num_children = get_child_count()
	
	# Itera sobre cada filho
	for i in range(num_children):
		
		# Obtém o filho atual
		var child = get_child(i)
		
		# Calcula o ângulo para posicionar o filho na roda
		var angle = (2 * PI * i / num_children) + deg_to_rad(wheel_rotation)
		
		# Calcula a posição do filho com base no ângulo e no tamanho da roda
		child.position = Vector2(
			cos(angle) * size.x,
			sin(angle) * size.y
		) * (wheel_size * 0.4) - (child.size / 2) + (size / 2)