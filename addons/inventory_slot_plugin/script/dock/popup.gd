@tool
extends Panel

signal ok
signal cancel

@onready var tittle_node: Label = $Bar/Panel/Vbox/Tittle
@onready var cancel_node: Button = $Bar/Panel/Vbox/Hbox/Cancel
@onready var ok_node: Button = $Bar/Panel/Vbox/Hbox/Ok

func start(_tittle: String,_cancel: String,_ok: String):
	tittle_node.text = _tittle
	cancel_node.text = _cancel
	ok_node.text = _ok


func _on_cancel_pressed() -> void:
	cancel.emit()
	queue_free()

func _on_ok_pressed() -> void:
	ok.emit()
	queue_free()
