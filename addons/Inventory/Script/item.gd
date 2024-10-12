extends TextureRect

class_name Item

@export_group("Item data")
@export var type: Inventory_main.ITEM_TYPE
@export var icon: Texture
@export var item_name: StringName
@export var max_amount: int = 32

@onready var amount_text: Label = $Amount

var inventory: Inventory_main
var id: int
