class_name TelescopeProp
extends Area2D

@onready var _animated_sprite: AnimatedSprite2D = %AnimatedSprite2D

signal clicked


func _ready() -> void:
	assert(_animated_sprite != null, "animated sprite is not set")

	EventBus.new_event.connect(_on_new_event)
	EventBus.report_added.connect(_on_end_event)
	EventBus.report_skipped.connect(_on_end_event)

	_set_outline(false)

	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _set_outline(value: bool) -> void:
	_animated_sprite.material.set_shader_parameter("enabled", value)


func _on_mouse_entered() -> void:
	_set_outline(true)


func _on_mouse_exited() -> void:
	_set_outline(false)


func _on_input_event(_viewport: Viewport, event: InputEvent, _idx: int) -> void:
	if event is InputEventMouseButton:
		var e := event as InputEventMouseButton
		if e.button_index == MOUSE_BUTTON_LEFT and e.pressed:
			clicked.emit()


func _on_new_event(_data: EventData) -> void:
	_animated_sprite.play("default")


func _on_end_event(_data: ReportData) -> void:
	_animated_sprite.stop()
