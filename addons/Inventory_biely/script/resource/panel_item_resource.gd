#class_name PanelItemResource extends Resource

## Nome do painel de slots
@export var panel_name: StringName = "new_slot"
## ID de identificação, caso houver um outro painel com a mesma indentificação, o segundo painel será ignorado.
@export var id: int = 0
## Quantidade de slots.
@export var max_slot: int = 10
## Especifique a unica classe que o painel irar usar. Caso o valor seja -1, será aceito todos os items.
@export var unique_class: int = -1

var items: Dictionary
