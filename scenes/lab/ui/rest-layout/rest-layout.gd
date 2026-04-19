class_name RestLayout
extends Panel

@onready var _label: Label = %Label
@onready var _timer: Timer = %Timer


func _ready() -> void:
	assert(_label != null, "label is not set")
	assert(_timer != null, "timer is not set")

	EventBus.sleep_started.connect(_on_sleep_started)

	_timer.timeout.connect(_on_timeout)

	visible = false


func show_layout() -> void:
	visible = true
	_timer.start()


func _on_sleep_started() -> void:
	show_layout()


func _on_timeout() -> void:
	EventBus.emit_sleep_ended()
	visible = false
