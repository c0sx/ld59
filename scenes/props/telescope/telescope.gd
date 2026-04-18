class_name TelescopeProp
extends Area2D

@onready var _sprite: Sprite2D = %Sprite2D

signal clicked


func _ready() -> void:
	_set_outline(false)

	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _set_outline(value: bool) -> void:
	_sprite.material.set_shader_parameter("enabled", value)

	if value:
		Input.set_default_cursor_shape(Input.CursorShape.CURSOR_POINTING_HAND)
	else:
		Input.set_default_cursor_shape(Input.CursorShape.CURSOR_ARROW)


func _on_mouse_entered() -> void:
	_set_outline(true)


func _on_mouse_exited() -> void:
	_set_outline(false)


func _on_input_event(_viewport: Viewport, event: InputEvent, _idx: int) -> void:
	if event is InputEventMouseButton:
		var e := event as InputEventMouseButton
		if e.button_index == MOUSE_BUTTON_LEFT and e.pressed:
			clicked.emit()
