@tool

extends TypePanel

@onready var edit_name: LineEdit = %edit_name
@onready var name_class: Button = %name_class
@onready var items: VBoxContainer = $Vbox/PanelItems/Vbox/Hbox/Items
@onready var top_bar: PanelContainer = $Vbox/TopBar
@onready var panel_items: PanelContainer = $Vbox/PanelItems
@onready var more_buttons: VBoxContainer = $Vbox/TopBar/Hbox/More/more_buttons

var load_items: bool = true

signal change_item


func _start(_class_name: String) -> void:
	items.my_class_name = _class_name
	
	name_class.text = _class_name
	edit_name.text = _class_name
	
	if load_items:
		items.load_items()
		load_items = false


func _on_name_class_gui_input(event: InputEvent) -> void:
	move_panel(event,self,top_bar,get_parent())
	
	if event is InputEventMouseButton:
		if event.double_click:
			edit_name.show()


func _on_edit_name_text_submitted(new_text: String) -> void:
	var inventory = InventoryFile.pull_inventory(InventoryFile.ITEM_PANEL_PATH)
	
	InventoryFile.changed_dictionary_name(inventory,name_class.text,new_text)
	
	items.my_class_name = new_text
	name_class.text = new_text
	edit_name.hide()
	
	InventoryFile.push_inventory(inventory, InventoryFile.ITEM_PANEL_PATH)
	
	Inventory.changed_panel_data.emit()

func _on_new_item_pressed() -> void:
	var inventory = InventoryFile.pull_inventory(InventoryFile.ITEM_PANEL_PATH)
	
	InventoryFile.push_inventory(InventoryFile.new_item_panel(name_class.text), InventoryFile.ITEM_PANEL_PATH)
	
	change_item.emit()


func _on_edit_name_focus_exited() -> void:
	edit_name.hide()


func _on_remove_pressed() -> void:
	var inventory = InventoryFile.pull_inventory(InventoryFile.ITEM_PANEL_PATH)
	
	InventoryFile.remove_class(inventory,name_class.text)
	InventoryFile.push_inventory(inventory, InventoryFile.ITEM_PANEL_PATH)
	
	Inventory.changed_panel_data.emit()
	queue_free()

func _on_edit_name_pressed() -> void:
	edit_name.show()
	more_buttons.hide()
