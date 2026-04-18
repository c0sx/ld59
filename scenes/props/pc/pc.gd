class_name PC
extends Area2D

@onready var _sprite: Sprite2D = %Sprite2D
@onready var _timer: Timer = %Timer
@onready var _progress: TextureProgressBar = %TextureProgressBar

signal clicked
signal reports_sent


func _ready() -> void:
	assert(_sprite != null, "sprite is not set")
	assert(_timer != null, "timer is not set")
	assert(_progress != null, "progress is not set")

	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	_set_outline(false)
	_progress.visible = false


func _process(_delta: float) -> void:
	if not _timer.is_stopped():
		var spent := _timer.wait_time - _timer.time_left
		var value := spent / _timer.wait_time

		_progress.value = value * 100


func send_reports(reports: Array[ReportData]) -> void:
	for report in reports:
		_progress.value = 0
		_progress.visible = true
		_timer.start()
		await _timer.timeout

	_progress.visible = false
	reports_sent.emit()


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
