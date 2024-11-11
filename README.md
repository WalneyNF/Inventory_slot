
# Inventory Slot Plugin
The Inventory Slot Plugin is an addon for Godot 4.3.x, designed to simplify and speed up the implementation of inventory systems in games. With an intuitive interface and a robust system, it allows you to manage items efficiently.

<img alt="Static Badge" src="https://img.shields.io/badge/current%20version-0.6.1-red"> <img alt="Static Badge" src="https://img.shields.io/badge/godot%20version-4.3.x.stable-blue">

# Summary

- [Installation](#installation)
- [How to use](#how-to-use)
- [Coding and functions](#code-and-functions)
  
# Installation
Download the Repository:
    After downloading the `.zip` file of the plugin, open your project in Godot.

Importing the Plugin:
    Go to the AssetLib window and click on `“Import Plugins”`.

![image](https://github.com/user-attachments/assets/27baefb5-0270-48c6-a943-e276f317e269)

Find the File:
    Find the plugin file you downloaded.

Restart the project:
    It's normal for some errors to appear after importing. Restart the project to make sure everything is working correctly.


# How to use

  The way to use the plugin is simple and very flexible with projects.

### 1.Create panels and configure them to your liking.

![image](https://github.com/user-attachments/assets/ba8bc02f-970f-4d62-8eea-ef472f5c52c8)


### 2.A little further down you'll find the Class / Items panel, where you'll create your classes and items.

![image](https://github.com/user-attachments/assets/4238cfe7-c616-4225-8c39-deb48334ef22)


### 3.With the initial settings made, we can put our interface into action. Add the PanelSlot node to your scene.

![image](https://github.com/user-attachments/assets/65e612b6-0cf2-4f00-b58a-e613d45510b1)

### 4.Now let's configure our panel to receive the items properly.

![image](https://github.com/user-attachments/assets/b22fdc9d-bb5e-4d13-a357-b919f441adcf)

### 5.Everything is ready, but we need to know how our interface is working. And for this we'll add an item via code in a simple way using add_item() from the Inventory singleton:

    func _ready() -> void:
        Inventory.add_item(1,0)

![image](https://github.com/user-attachments/assets/8d5a9e48-0dd9-40a2-b13e-84f70056de73)

# Coding and functions

  Here we have 2 features for manipulating items/files.
  
## Inventory ( Singleton )
  
  Handling inventory items.

  #### Using `add_item()`, you add the item to the inventory by specifying the `_item_unique_id` and directing the panel in `_panel_id`. 
    Inventory.add_item(_panel_id: int, _item_unique_id: int, _amount: int = 1, _slot: int = -1, _id: int = -1, _unique: bool = false)
  #### Remove the item from a panel, give the id of the panel to `_panel_id`, and the `id` of the item in the inventory.
    Inventory.remove_item(_panel_id: Dictionary, _id: int = -1)
  #### Search for items in a panel using `search_item`, give the `unique_id` of the item in `_item_unique_id`.
    Inventory.search_item(_panel_id: int, _item_unique_id: int = -1, _path : String = "",_slot: int = -1)
  #### Exchange panel items.
    Inventory.set_panel_item(_item_id: int, _out_panel_id: int, _new_panel_id:int, _slot: int = -1, _unique: bool = false, _out_item_remove: bool = true)
  #### Change the slot of an item.
    Inventory.set_slot_item(_panel_item: Dictionary, _item_inventory: Dictionary, _slot: int = -1, _unique: bool = true)
  #### Swap 2 slot items.
    Inventory.func changed_slots_items(item_one: Dictionary, item_two: Dictionary)`


## InventoryFile ( Class )
  File handling.
  
  #### Search for an item in a panel using `unique_id`.
    search_item_id(_panel_id: int, _item_unique_id: int = -1)
  #### Take a panel with its own id.
    get_panel(_panel_id: int)
  #### Pegue um painel com o `unique_id` de um item em inventario que esteja dentro do proprio.
    get_panel_id(_unique_id: int)
  #### Returns the name of the item
    get_class_name(_unique_id_item: int)
  #### Returns the class name of the item
    get_item_name(_unique_id_item: int)
  #### Check if the file is a json (goes beyond the extension).
    InventoryFile.is_json(_path: String)
  #### Pull the json from the dictionary.
    InventoryFile.pull_inventory(_path: String)
  #### Send your dictionary to be saved in json stop `_path`.
    InventoryFile.push_inventory(_dic: Dictionary,_path: String)
  #### Add the item directly to `ITEM_INVENTORY_PATH`.
    InventoryFile.push_item_inventory(_item_id: int, _item_inventory: Dictionary)
  #### Create a new class.
    new_class(_class_name: String)
  #### Create an item in a panel.
    new_item_panel(_class_name: String,_icon_path: String = InventoryFile.IMAGE_DEFAULT,_amount: int = 1,_description: String = “”,_path_scene: String = “res://”)
  #### Remove a class.
    remove_class(_inventory: Dictionary,_class_name: String)
  #### Remove an item in a panel.
    remove_item(_panel_id: int, _id: int = -1)
  #### Const
   `ITEM_PANEL_PATH`
   `PANEL_SLOT_PATH`
   `ITEM_INVENTORY_PATH`

