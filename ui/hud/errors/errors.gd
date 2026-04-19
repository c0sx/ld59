class_name ErrorsCounterHUD
extends Label


var _current: int
var _total: int = 3


func _ready() -> void:
	EventBus.error_report_sent.connect(_on_report_sent)

	EventBus.game_over.connect(_on_hide)
	EventBus.research_completed.connect(_on_hide)
	EventBus.research_failed.connect(_on_hide)
	EventBus.sleep_started.connect(_on_hide)
	EventBus.sleep_ended.connect(_on_show)

	_update_value()


func _update_value() -> void:
	text = "Errors: %d/%d" % [_current, _total]


func _on_hide() -> void:
	visible = false


func _on_show() -> void:
	visible = true


func _on_report_sent(_report_data: ReportData, errors: int) -> void:
	_current = errors
	_update_value()
