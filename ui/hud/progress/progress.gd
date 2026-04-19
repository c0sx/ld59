class_name ProgressHUD
extends Label

var _total: int = 0
var _current: int = 0
var _right: int = 0
var _errors: int = 0
var _errors_total: int = 0


func _ready() -> void:
	EventBus.events_initialized.connect(_on_events_initialized)
	EventBus.report_sent.connect(_on_report_sent)

	EventBus.game_over.connect(_on_hide)
	EventBus.research_completed.connect(_on_hide)
	EventBus.research_failed.connect(_on_hide)
	EventBus.sleep_started.connect(_on_hide)
	EventBus.sleep_ended.connect(_on_show)

	_update_value()


func _update_value() -> void:
	var value: float = 0
	if _right != 0:
		value = _current / float(_right)

	text = "Progress: %d%s" % [int(value * 100), "%"]


func _on_hide() -> void:
	visible = false


func _on_show() -> void:
	visible = true


func _on_events_initialized(events: Array[EventData]) -> void:
	_total = events.size()

	for event in events:
		if event.is_anomaly:
			_errors_total += 1
		else:
			_right += 1


func _on_report_sent(report_data: ReportData) -> void:
	if not report_data.is_signal_sent:
		return

	if report_data.event_data.is_anomaly:
		_errors += 1
		EventBus.emit_error_report_sent(report_data, _errors)
	else:
		_current += 1
		_update_value()

		if _current >= _right:
			EventBus.emit_research_completed()
		else:
			EventBus.emit_ok_report_sent(report_data)
