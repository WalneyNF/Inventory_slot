@tool

extends PanelContainer

enum AMOUNT_ANCHOR {LEFT_UP,LEFT_DOWN,RIGHT_UP,RIGHT_DOWN}


@onready var amount_text: LineEdit = $Vbox/Hbox/Vbox/Amount/Vbox/Hbox/Vbox/name/name
@onready var amount_anchor: OptionButton = $Vbox/Hbox/Vbox/Amount/Vbox/Hbox/Vbox/anchor/anchor
@onready var amount_show_being_one: CheckBox = $Vbox/Hbox/Vbox/Amount/Vbox/Hbox/Vbox/shown_being_one/shown_being_one

@onready var description_name_item: CheckBox = $Vbox/Hbox/Vbox/Description/Vbox/Hbox/Vbox/name_item_show/name_item_show
@onready var description_amount_show: CheckBox = $Vbox/Hbox/Vbox/Description/Vbox/Hbox/Vbox/amount_show/amount_show
@onready var description_description: CheckBox = $Vbox/Hbox/Vbox/Description/Vbox/Hbox/Vbox/description/description

var _item_settings

func _ready() -> void:
	if InventoryFile.is_json(Inventory.ITEM_SETTINGS):
		_item_settings = InventoryFile.pull_inventory(Inventory.ITEM_SETTINGS)
		
		amount_text.text = _item_settings.amount_text
		amount_anchor.selected = _item_settings.amount_anchor
		amount_show_being_one.button_pressed = _item_settings.amount_show_being_one
		
		description_name_item.button_pressed = _item_settings.description_name_item
		description_amount_show.button_pressed = _item_settings.description_amount_show
		description_description.button_pressed = _item_settings.description_description
	else:
		_item_settings = {
			"amount_text" : "Amount",
			"amount_anchor" : AMOUNT_ANCHOR.LEFT_UP,
			"amount_show_being_one" : false,
			
			"description_name_item" : true,
			"description_amount_show" : true,
			"description_description" : true,
		}
		
		InventoryFile.push_inventory(_item_settings,Inventory.ITEM_SETTINGS)



func _on_name_text_submitted(new_text: String) -> void:
	_item_settings.amount_text = new_text
	amount_text.release_focus()
	
	InventoryFile.push_inventory(_item_settings,Inventory.ITEM_SETTINGS)

func _on_anchor_item_selected(index: int) -> void:
	_item_settings.amount_anchor = index
	
	InventoryFile.push_inventory(_item_settings,Inventory.ITEM_SETTINGS)

func _on_shown_being_one_pressed() -> void:
	_item_settings.amount_show_being_one = amount_show_being_one.button_pressed
	
	InventoryFile.push_inventory(_item_settings,Inventory.ITEM_SETTINGS)

func _on_name_item_show_pressed() -> void:
	_item_settings.description_name_item = description_name_item.button_pressed
	
	InventoryFile.push_inventory(_item_settings,Inventory.ITEM_SETTINGS)

func _on_amount_show_pressed() -> void:
	_item_settings.description_amount_show = description_amount_show.button_pressed
	
	InventoryFile.push_inventory(_item_settings,Inventory.ITEM_SETTINGS)

func _on_description_pressed() -> void:
	_item_settings.description_description = description_description.button_pressed
	
	InventoryFile.push_inventory(_item_settings,Inventory.ITEM_SETTINGS)
