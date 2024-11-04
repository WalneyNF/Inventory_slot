extends TextureRect

enum AMOUNT_ANCHOR {LEFT_UP,LEFT_DOWN,RIGHT_UP,RIGHT_DOWN}

@onready var node_amount_text: Label = $Amount

var item_inventory: Dictionary
var panel_slot: Dictionary
var item_settings: Dictionary

func _ready() -> void:
	item_settings = InventoryFile.pull_inventory(InventoryFile.ITEM_SETTINGS)
	
	Inventory.new_data.connect(reload_my_data)
	Inventory.new_data_global.connect(reload_data)
	Inventory.discart_item.connect(remove_item)
	
	load_visual()

func load_visual() -> void:
	var item_panel = InventoryFile.search_item_id(panel_slot.id,item_inventory.unique_id)
	
	texture = load(item_panel.icon)
	
	node_amount_text.text = str(item_inventory.amount)
	
	reload_data()
	anchor_visual_amount()
	
	if item_inventory.slot == Inventory.ERROR.SLOT_BUTTON_VOID:
		z_index = 1

func reload_my_data(_item_panel: Dictionary , _item_inventory: Dictionary , _system_slot: Dictionary) -> void:
	if item_inventory.id == _item_inventory.id:
		item_inventory = _item_inventory
		
		#reload_data()

func reload_data() -> void:
	if item_inventory.amount == 0:
		Inventory.remove_item(panel_slot,item_inventory.id)
	
	node_amount_text.text = str(item_inventory.amount)
	
	node_amount_text.visible = bool(int(item_settings.amount_show_being_one) + int(item_inventory.amount > 1))

func item_more() -> String:
	var _description: String
	
	if item_settings.description_name_item:
		_description += InventoryFile.get_item_name(item_inventory.unique_id)
		_description += "\n"
	if item_settings.description_amount_show:
		_description += str(item_settings.amount_text,": ",item_inventory.amount,"/",InventoryFile.search_item_id(panel_slot.id,item_inventory.unique_id).max_amount)
		_description += "\n"
	if item_settings.description_description:
		_description += InventoryFile.search_item_id(panel_slot.id,item_inventory.unique_id).description
	
	return _description

func remove_item(item_panel: Dictionary ,_item_inventory: Dictionary  ,system_slot: Dictionary) -> void:
	
	if item_inventory.id == _item_inventory.id:
		queue_free()
		#print(_item_inventory)

func anchor_visual_amount() -> void:
	
	match int(item_settings.amount_anchor):
		AMOUNT_ANCHOR.LEFT_UP:
			node_amount_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			node_amount_text.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		AMOUNT_ANCHOR.LEFT_DOWN:
			node_amount_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			node_amount_text.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		AMOUNT_ANCHOR.RIGHT_UP:
			node_amount_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			node_amount_text.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		AMOUNT_ANCHOR.RIGHT_DOWN:
			node_amount_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			node_amount_text.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
