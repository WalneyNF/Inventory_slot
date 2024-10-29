extends TextureRect

enum AMOUNT_ANCHOR {LEFT_UP,LEFT_DOWN,RIGHT_UP,RIGHT_DOWN}

@export_group("Visual")
@export var amount_shown_being_one: bool
@export var amount_anchor: AMOUNT_ANCHOR

@onready var amount_text: Label = $Amount

var item: Dictionary
var panel_slot: Dictionary


func _ready() -> void:
	Inventory.new_data_global.connect(reload_data)
	Inventory.discart_item.connect(remove_item)
	
	load_visual()


func load_visual() -> void:
	var item_panel = TypePanel.search_item_id(panel_slot.id,item.unique_id)
	print(item_panel)
	texture = load(item_panel.icon)
	
	amount_text.text = str(item.amount)
	
	reload_data()
	anchor_visual_amount()


func reload_data() -> void:
	if item.amount == 0:
		var my_panel = Inventory.get_panel_id(get_parent().panel_id)
		Inventory.remove_item(my_panel,item.id)
	
	amount_text.text = str(item.amount)
	
	amount_text.visible = bool( int(amount_shown_being_one) + int(item.amount > 1))
	
	get_parent().tooltip_text = str(
		TypePanel.get_item_name(item.unique_id),'\n',
		"Amount: ",item.amount,"/",TypePanel.search_item_id(panel_slot.id,item.unique_id).max_amount,
	)


func remove_item(_item: Dictionary,_id: int) -> void:
	
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
