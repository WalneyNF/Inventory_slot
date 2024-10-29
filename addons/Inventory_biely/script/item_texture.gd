extends TextureRect

enum AMOUNT_ANCHOR {LEFT_UP,LEFT_DOWN,RIGHT_UP,RIGHT_DOWN}

@export_group("Visual")
@export var amount_shown_being_one: bool
@export var amount_anchor: AMOUNT_ANCHOR

@onready var amount_text: Label = $Amount

var item_inventory: Dictionary
var panel_slot: Dictionary


func _ready() -> void:
	Inventory.new_data_global.connect(reload_data)
	Inventory.discart_item.connect(remove_item)
	
	load_visual()


func load_visual() -> void:
	#print(panel_slot)
	var item_panel = TypePanel.search_item_id(panel_slot.id,item_inventory.unique_id)
	
	texture = load(item_panel.icon)
	
	amount_text.text = str(item_inventory.amount)
	
	reload_data()
	anchor_visual_amount()


func reload_data() -> void:
	if item_inventory.amount == 0:
		Inventory.remove_item(panel_slot,item_inventory.id)
	
	amount_text.text = str(item_inventory.amount)
	
	amount_text.visible = bool( int(amount_shown_being_one) + int(item_inventory.amount > 1))
	
	get_parent().tooltip_text = str(
		TypePanel.get_item_name(item_inventory.unique_id),'\n',
		"Amount: ",item_inventory.amount,"/",TypePanel.search_item_id(panel_slot.id,item_inventory.unique_id).max_amount,
	)


func remove_item(_item_inventory: Dictionary,panel_id: int) -> void:
	
	if _item_inventory.id == item_inventory.id:
		queue_free()
		#print(_item_inventory)


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
