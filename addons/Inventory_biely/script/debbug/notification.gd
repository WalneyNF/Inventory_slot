extends Control

@export var inventory: Inventory_main
@export var use: bool = true

func _ready() -> void:
	inventory.item_entered_panel.connect(item_entered_panel)
	inventory.new_item.connect(new_item)
	inventory.discart_item.connect(discart_item)
	inventory.new_data_global.connect(new_data_global)


func new_item(item: ItemResource ,system_slot: PanelItemResource) -> void:
	create_popup("New Item",str(item.path.get_basename().split(item.path.get_extension())))
func item_entered_panel(item: ItemResource ,new_id: int) -> void:
	create_popup("Item entered Panel",str(item.path.get_file()," - ",inventory.get_panel_id(new_id).panel_name))
func discart_item(item: ItemResource ,new_id: int) -> void:
	create_popup("Discart item",str(item.path.get_file()," - ",inventory.get_panel_id(new_id).panel_name))
func new_data_global() -> void:
	create_popup("Reload data global","reload")

#signal new_item(item: ItemResource ,system_slot: PanelItemResource)
#signal item_entered_panel()
signal item_exiting_panel(item: ItemResource ,new_id: int)
signal button_slot_changed(slot: Control,move: bool)



func create_popup(_tittle: StringName,_text : String) -> void:
	if use == false: return
	
	var tittle = Label.new()
	var text = Label.new()
	
	var panel = PanelContainer.new()
	var vbox = VBoxContainer.new()
	
	add_child(panel)
	panel.add_child(vbox)
	vbox.add_child(tittle)
	vbox.add_child(text)
	
	tittle.text = _tittle
	text.text = _text
	
	tittle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	panel.size = Vector2(
		200,
		50
	)
	panel.global_position = Vector2(
		25,
		get_viewport().size.y
	)
	
	create_tween().tween_property(panel,"global_position:y",(get_viewport().size.y - (panel.size.y * get_child_count()) - 25),0.3).set_trans(Tween.TRANS_CUBIC)
	await get_tree().create_timer(2).timeout
	create_tween().tween_property(panel,"modulate:a",0,0.3).set_trans(Tween.TRANS_CUBIC) == null
	await get_tree().create_timer(0.3).timeout
	panel.queue_free()
