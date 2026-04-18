class_name ProgressHUD
extends Label


func _ready() -> void:
	EventBus.progress_increased.connect(_on_progress_increased)

	_update_value(0)


func _update_value(value: float) -> void:
	text = "Progress: %d%s" % [value * 100, "%"]


func _on_progress_increased(value: float) -> void:
	_update_value(value)
