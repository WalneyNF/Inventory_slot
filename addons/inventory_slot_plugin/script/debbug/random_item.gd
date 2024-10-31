@tool
extends Button

var items = []

func _ready() -> void:
	items = TypePanel.list_all_item()

func _pressed() -> void:
	#print(items)
	#print(items[randi_range(0,items.size()-1)])
	#add_item(panel_id: int, item_unique_id: int, amount: int = 1, slot: int = -1, id: int = -1, unique: bool = false):
	Inventory.add_item(0,items[randi_range(0,items.size()-1)].unique_id,randi_range(1,3))
	#Inventory._append_item(Inventory.get_panel_id(0),items[randi_range(0,items.size()-1)],1,-1)
