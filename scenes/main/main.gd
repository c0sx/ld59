class_name MainScene
extends Node2D

@export var config: DayConfig
@export var progress_threshold: int

@onready var _lab: Lab = %Lab
@onready var _telescope: Telescope = %Telescope
@onready var _camera: Camera2D = %Camera2D

var _errors_counter: int = 0
var _progress: int = 0


func _ready() -> void:
	assert(config != null, "config is not set")
	assert(_lab != null, "lab is not set")
	assert(_telescope != null, "telescope is not set")
	assert(_camera != null, "camera is not set")

	EventBus.report_sent.connect(_on_report_sent)

	_telescope.visible = false
	_telescope.process_mode = Node.PROCESS_MODE_DISABLED

	_lab.looked_into_telescope.connect(_on_looked_into_telescope)
	_lab.new_event.connect(_on_new_event)
	_telescope.closed.connect(_on_look_stopped)

	_camera.make_current()
	_lab.enter(config)


func _on_looked_into_telescope() -> void:
	_telescope.visible = true
	_telescope.process_mode = Node.PROCESS_MODE_INHERIT

	_lab.visible = false
	_lab.process_mode = Node.PROCESS_MODE_DISABLED

	_telescope.enter()


func _on_look_stopped() -> void:
	_telescope.visible = false
	_telescope.process_mode = Node.PROCESS_MODE_DISABLED

	_lab.visible = true
	_lab.process_mode = Node.PROCESS_MODE_INHERIT

	_lab.enter(config)


func _on_new_event(event_data: EventData) -> void:
	_telescope.register_new_event(event_data)


func _on_report_sent(report_data: ReportData) -> void:
	if report_data.event_data.is_anomaly:
		_errors_counter += 1
		EventBus.emit_error_report_sent(report_data, _errors_counter)
	else:
		_progress += 1
		if _progress >= progress_threshold:
			EventBus.emit_research_completed()
		else:
			EventBus.emit_progress_increased(_progress / float(progress_threshold))
			EventBus.emit_ok_report_sent(report_data)
