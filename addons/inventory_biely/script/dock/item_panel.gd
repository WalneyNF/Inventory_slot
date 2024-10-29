@tool

extends TypePanel

enum SELECTION {ICON,SCENE}

@onready var icon: Button = %Icon
@onready var edit_item_name: LineEdit = %item_name
@onready var scene: Button = %scene
@onready var id_unique: Button = $Vbox/TopBar/Hbox/id_unique
@onready var top_bar: PanelContainer = $Vbox/TopBar
@onready var hbox: HBoxContainer = $Vbox/Hbox


var item_name: String
var selection: int


func _ready() -> void:
	hbox.hide()


func start(_item_name: String,_icon_path: String) -> void:
	icon.icon = load(_icon_path)
	item_name = _item_name
	
	edit_item_name.text = _item_name
	id_unique.text = str(get_index()," - ",item_name)



func call_file_dialog(filters: Array) -> void:
	var explorer = EditorFileDialog.new()
	
	explorer.file_selected.connect(file_selection)
	explorer.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	explorer.filters = filters
	
	add_child(explorer)
	explorer.popup_file_dialog()


func file_selection(path: String) -> void:
	var inventory = pull_inventory()
	
	match selection:
		SELECTION.ICON:
			icon.icon = load(path)
			
			search_item(inventory,get_parent().my_class_name,item_name).icon = path
			push_inventory(inventory)
		SELECTION.SCENE:
			scene.text = path
			
			search_item(inventory,get_parent().my_class_name,item_name).item_path_scene = path
			push_inventory(inventory)



func _on_scene_pressed() -> void:
	selection = SELECTION.SCENE
	call_file_dialog(["*tscn"])
func _on_icon_pressed() -> void:
	selection = SELECTION.ICON
	call_file_dialog(["*png","*svg","*jpg"])


func _on_id_unique_gui_input(event: InputEvent) -> void:
	move_panel(event,self,top_bar,get_parent())
	
	id_unique.text = str(get_index()," - ",item_name)



func _on_delete_pressed() -> void:
	var inventory = pull_inventory()
	remove_item(inventory,get_parent().my_class_name,item_name)
	push_inventory(inventory)
	queue_free()


func _on_item_name_text_submitted(new_text: String) -> void:
	var inventory = pull_inventory()
	edit_item_name.release_focus()
	
	changed_item_name(inventory,get_parent().my_class_name,item_name,new_text)
	push_inventory(inventory)
	
	item_name = new_text
	id_unique.text = str(get_index()," - ",item_name)

func _on_max_amount_value_changed(value: float) -> void:
	var inventory = pull_inventory()
	
	search_item(inventory,get_parent().my_class_name,item_name).max_amount = int(value)
	push_inventory(inventory)
