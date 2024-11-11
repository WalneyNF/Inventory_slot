@tool
@icon("res://addons/inventory_slot_plugin/assets/icons/slot_whellcontainer.tres")
extends Container

class_name WheelContainer

@export var wheel_size: Vector2 = Vector2(1,1):
	set(value):
		wheel_size = value
		start()

@export_range(0.0,360.0) var wheel_rotation: float = 0.0:
	set(value):
		wheel_rotation = value
		start()

func _draw() -> void:
	start()

func _ready() -> void:
	start()
	
	child_entered_tree.connect(child_enter)
	child_exiting_tree.connect(child_exit)

func child_enter(node) -> void:
	start()

func child_exit(node) -> void:
	start()

func start() -> void:
	
	var num_children = get_child_count()
	
	for i in range(num_children):
		
		var child = get_child(i)
		var angle = (2 * PI * i / num_children) + wheel_rotation
		
		child.position = Vector2(
			cos(angle) * size.x,
			sin(angle) * size.y
		) * (wheel_size * 0.4) - (child.size / 2) + (size/2)
