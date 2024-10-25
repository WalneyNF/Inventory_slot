extends Node

class_name TypePanel

const PATH = "res://addons/inventory_biely/json/inventory.json"
const LIFE = "res://addons/inventory_biely/assets/imagens/life.png"
var start_update: bool

func _ready() -> void:
	if Engine.is_editor_hint():
		var feature_profile := EditorFeatureProfile.new()
		feature_profile.set_disable_class("TypePanel", true)


func changed_class_name(_inventory: Dictionary,_out_class_name: String,_new_class_name: String) -> void:
	
	var new_value = _inventory.get(_out_class_name)
	
	_inventory.erase(_out_class_name)
	_inventory[_new_class_name] = new_value


func changed_item_name(_inventory: Dictionary,_class_name: String,_out_item_name: String,_new_item_name: String) -> void:
	
	var item = search_item(_inventory,_class_name,_out_item_name)
	
	if item != null:
		var new_value = _inventory.get(_class_name).get(_out_item_name)
		
		_inventory.get(_class_name).erase(_out_item_name)
		_inventory.get(_class_name)[_new_item_name] = new_value
		


func search_item(_inventory: Dictionary,_class_name: String,_item_name: String):
	for _class in _inventory:
		if _class_name == _class:
			for _item in _inventory.get(_class):
				
				if _item_name == _item:
					
					return _inventory.get(_class_name).get(_item_name)
	
	printerr("Item ",_item_name," não foi encontrado!")

func pull_inventory() -> Dictionary:
	if FileAccess.file_exists(PATH):
		var file = FileAccess.open(PATH,FileAccess.READ)
		
		var all_class: Dictionary = JSON.parse_string(file.get_as_text())
		file.close()
		
		return all_class
	
	return {}


func push_inventory(dic: Dictionary) -> void:
	var file = FileAccess.open(PATH,FileAccess.WRITE)
	
	file.store_string(JSON.stringify(dic,"\t"))
	file.close()


func new_item(_inventory: Dictionary,_class_name: String,icon_path: String = LIFE,amount: int = 1,item_path_scene: String = "res://") -> void:
	
	for _class in _inventory:
		if _class == _class_name:
			
			_inventory.get(_class)[str("new_item_",_inventory.get(_class).size())] = {
				"icon" : icon_path,
				"max_amount" : amount,
				"item_path_scene" : item_path_scene
			}


func remove_item(_inventory: Dictionary,_class_name: String,_item_name: String) -> void:
	_inventory.get(_class_name).erase(_item_name)

func remove_class(_inventory: Dictionary,_class_name: String) -> void:
	_inventory.erase(_class_name)


func move_panel(event: InputEvent,panel,topbar: Control,panel_parent: BoxContainer) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if event is InputEventMouseMotion:
			start_update = true
			panel.global_position.y = panel.get_global_mouse_position().y - topbar.size.y/2
			panel.z_index = 1
	else:
		if start_update:
			update_item_panel(panel_parent)
			start_update = false


func update_item_panel(panel_parent: BoxContainer) -> void:
	var all_child = panel_parent.get_children()
	
	all_child.sort_custom(sort_position)
	
	for i in range(all_child.size()):
		panel_parent.move_child(all_child[i],i)
	
	for child in panel_parent.get_children():
		
		child.z_index = 0
		child.hide()
		child.show()
		
		child.id_unique.text = str(child.get_index())


func sort_position(a,b):
	if a.position.y-100 < b.position.y:
		return a
