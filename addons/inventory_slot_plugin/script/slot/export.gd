@tool
extends EditorExportPlugin

func _export_end() -> void:
	_add_export(self ,InventorySystem.INVENTORY_SYSTEM)
	_add_export(self ,Inventory.ITEM_SETTINGS)
	_add_export(self ,Inventory.ITEM_PANEL_PATH)
	_add_export(self ,Inventory.PANEL_SLOT_PATH)
	_add_export(self ,Inventory.ITEM_INVENTORY_PATH)


func _add_export(_edit: EditorExportPlugin,_path: String) -> void:
	var _file: FileAccess = FileAccess.open(_path,FileAccess.READ)
	
	_edit.add_file(_path,_file.get_buffer(_file.get_length()), false)
