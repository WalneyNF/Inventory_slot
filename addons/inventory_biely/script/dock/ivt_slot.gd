@tool
extends PanelContainer

@onready var ui_items: Control = $Panels/UiPanel/Vbox/UiItems
@onready var settings: PanelContainer = $Panels/InventoryMain/Vbox/Settings


func _on_inv_main_button_pressed() -> void:
	settings.visible = !settings.visible


func _on_ui_button_pressed() -> void:
	ui_items.visible = !ui_items.visible
