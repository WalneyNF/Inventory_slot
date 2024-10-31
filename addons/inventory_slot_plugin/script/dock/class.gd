@tool

extends TypePanel

@onready var edit_name: LineEdit = %edit_name
@onready var name_class: Button = %name_class
@onready var items: VBoxContainer = $Vbox/PanelItems/Vbox/Hbox/Items
@onready var top_bar: PanelContainer = $Vbox/TopBar
@onready var panel_items: PanelContainer = $Vbox/PanelItems

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
	var inventory = pull_inventory()
	changed_class_name(inventory,name_class.text,new_text)
	
	items.my_class_name = new_text
	name_class.text = new_text
	edit_name.hide()
	
	push_inventory(inventory)



func _on_new_item_pressed() -> void:
	var inventory = pull_inventory()
	
	new_item(inventory,name_class.text)
	push_inventory(inventory)
	
	change_item.emit()


func _on_edit_name_focus_exited() -> void:
	edit_name.hide()


func _on_delete_pressed() -> void:
	var inventory = pull_inventory()
	remove_class(inventory,name_class.text)
	push_inventory(inventory)
	
	queue_free()
