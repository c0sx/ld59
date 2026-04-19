class_name Brief
extends Node2D

@onready var _area: Area2D = %Area2D
@onready var _sprite: Sprite2D = %Sprite2D
@onready var _canvas: CanvasLayer = %CanvasLayer
@onready var _button: Button = %Button
@onready var _cursor: Cursor = %Cursor

signal clicked

var _read: bool

func _ready() -> void:
	_area.input_event.connect(_on_input_event)
	_area.mouse_entered.connect(_on_mouse_entered)
	_area.mouse_exited.connect(_on_mouse_exited)
	_button.pressed.connect(_on_pressed)

	_set_outline(false)
	_canvas.visible = false


func read_brief() -> void:
	_canvas.visible = true


func _set_outline(value: bool) -> void:
	_sprite.material.set_shader_parameter("enabled", value)


func _on_mouse_entered() -> void:
	_set_outline(true)


func _on_mouse_exited() -> void:
	_set_outline(false)


func _on_input_event(_viewport: Viewport, event: InputEvent, _idx: int) -> void:
	if event is InputEventMouseButton:
		var e := event as InputEventMouseButton
		if e.button_index == MOUSE_BUTTON_LEFT and e.pressed:
			clicked.emit()


func _on_pressed() -> void:
	if not _read:
		EventBus.emit_brief_read()
		_read = true

	_canvas.visible = false
	_cursor.visible = false
