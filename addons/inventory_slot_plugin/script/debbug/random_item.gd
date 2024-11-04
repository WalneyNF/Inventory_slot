extends Button

var items = []

func _ready() -> void:
	items = InventoryFile.list_all_item_panel(-1)

func _pressed() -> void:
	var unique_id = items[randi_range(0,items.size()-1)].unique_id
	
	Inventory.add_item(1,unique_id,1)
