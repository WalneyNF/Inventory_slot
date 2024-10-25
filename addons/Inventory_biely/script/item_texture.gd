extends TextureRect

enum AMOUNT_ANCHOR {LEFT_UP,LEFT_DOWN,RIGHT_UP,RIGHT_DOWN}

@export_group("Visual")
@export var amount_shown_being_one: bool
@export var amount_anchor: AMOUNT_ANCHOR

@onready var amount_text: Label = $Amount

var inventory: Inventory_main
var item: ItemResource
var item_scene


func _ready() -> void:
	item_scene = load(item.path).instantiate()
	inventory.new_data_global.connect(reload_data)
	inventory.discart_item.connect(remove_item)
	
	load_visual()


func load_visual() -> void:
	var item_instance = load(item.path).instantiate()
	texture = item_instance.icon
	
	amount_text.text = str(item.amount)
	
	reload_data()
	anchor_visual_amount()


func reload_data() -> void:
	if item.amount == 0:
		var my_panel = inventory.get_panel_id(get_parent().panel_id)
		inventory.remove_item(my_panel,item.id)
	
	amount_text.text = str(item.amount)
	
	amount_text.visible = bool( int(amount_shown_being_one) + int(item.amount > 1))
	
	get_parent().tooltip_text = str(
		item_scene.item_name,'\n',
		"Amount: ",item.amount,"/",item_scene.max_amount,
	)


func remove_item(_item: ItemResource,_id: int) -> void:
	
	if _item.id == item.id:
		queue_free()


func anchor_visual_amount() -> void:
	match amount_anchor:
		AMOUNT_ANCHOR.LEFT_UP:
			amount_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			amount_text.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		AMOUNT_ANCHOR.LEFT_DOWN:
			amount_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			amount_text.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		AMOUNT_ANCHOR.RIGHT_UP:
			amount_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			amount_text.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		AMOUNT_ANCHOR.RIGHT_DOWN:
			amount_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			amount_text.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
