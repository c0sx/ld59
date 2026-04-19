class_name Lab
extends Node2D

@export var config: DayConfig
@export var camera: Camera2D

@onready var _player: Player = %Player
@onready var _nav_region: NavigationRegion2D = %NavigationRegion2D
@onready var _cursor: Cursor = %Cursor
@onready var _pc: PC = %PC
@onready var _telescope: TelescopeProp = %Telescope
@onready var _chair: StaticBody2D = %Chair
@onready var _label: Label = %Label
@onready var _notification_timer: Timer = %Timer
@onready var _telescope_point: Node2D = %TelescopeTargetPoint
@onready var _bed: Bed = %Bed
@onready var _bed_point: Node2D = %BedTargetPoint
@onready var _event_timer: Timer = %EventTimer
@onready var _monitor: Monitor = %Monitor
@onready var _report: Report = %Report
@onready var _progress: Label = %Progress
@onready var _counter: Label = %StarsCounter

signal looked_into_telescope

var _open_telescope_intent: bool
var _open_pc_intent: bool
var _sleep_intent: bool
var _events: Array[EventData]


func _ready() -> void:
	assert(config != null, "config is not set")
	assert(camera != null, "camera is not set")
	assert(_player != null, "player is not set")
	assert(_nav_region != null, "nav regions is not set")
	assert(_cursor != null, "cursor is not set")
	assert(_pc != null, "pc is not set")
	assert(_telescope != null, "telescope is not set")
	assert(_chair != null, "chair is not set")
	assert(_label != null, "label is not set")
	assert(_notification_timer != null, "notification timer is not set")
	assert(_telescope_point != null, "telescope point is not set")
	assert(_bed != null, "bed is not set")
	assert(_bed_point != null, "bed point is not set")
	assert(_event_timer != null, "event timer is not set")
	assert(_monitor != null, "monitor is not set")
	assert(_progress != null, "progress is not set")
	assert(_counter != null, "counters is not set")

	EventBus.report_sent.connect(_on_report_sent)
	EventBus.report_skipped.connect(_on_report_skipped)

	_player.move_finished.connect(_on_move_finished)
	_telescope.clicked.connect(_on_telescope_clicked)
	_pc.clicked.connect(_on_pc_clicked)
	_notification_timer.timeout.connect(_on_timeout)
	_bed.clicked.connect(_on_bed_clicked)
	_event_timer.timeout.connect(_on_event_timer_timeout)

	_cursor.visible = false
	_report.visible = false

	var events := config.events.duplicate()
	events.shuffle()
	_events = events
	EventBus.emit_events_initialized(_events)

	_event_timer.start()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var e = event as InputEventMouseButton
		if not e.pressed:
			return

		var pos := get_global_mouse_position()

		if _is_point_on_navmesh(pos):
			_open_telescope_intent = false
			_open_pc_intent = false
			_sleep_intent = false

			_cursor.global_position = pos
			_cursor.visible = true
			_player.move_to(pos)


func enter() -> void:
	var offset = get_viewport_rect().size / 2
	var pos: Vector2 = global_position + Vector2(offset.x, offset.y)
	camera.global_position = pos

	_progress.visible = true
	_counter.visible = true


func _exit() -> void:
	_progress.visible = false
	_counter.visible = false


func _is_point_on_navmesh(point: Vector2) -> bool:
	var map := get_world_2d().navigation_map
	var closest := NavigationServer2D.map_get_closest_point(map, point)

	return closest.distance_to(point) < 1.0


func _try_to_send_reports() -> void:
	var reports := _player.get_reports()
	if reports.size() == 0:
		_show_notification("Doesn't have reports to send")
		return

	var report: ReportData = reports.pop_front()
	EventBus.emit_report_opened(report)
	get_tree().paused = true


func _try_to_sleep() -> void:
	EventBus.emit_sleep_started()


func _show_notification(message: String, time: float = 1) -> void:
	if not _notification_timer.is_stopped():
		_notification_timer.stop()

	_label.text = message
	_label.visible = true
	_notification_timer.start(time)


func _on_move_finished() -> void:
	_cursor.visible = false

	if _open_telescope_intent:
		_exit()
		looked_into_telescope.emit.call_deferred()

	if _open_pc_intent:
		_try_to_send_reports()

	if _sleep_intent:
		_try_to_sleep()


func _on_telescope_clicked() -> void:
	var pos := _telescope_point.global_position

	_cursor.global_position = pos
	_cursor.visible = true
	_player.move_to(pos)

	_open_telescope_intent = true
	_open_pc_intent = false
	_sleep_intent = false


func _on_pc_clicked() -> void:
	var pos := _chair.global_position

	_cursor.global_position = pos
	_cursor.visible = true
	_player.move_to(pos)

	_open_pc_intent = true
	_open_telescope_intent = false
	_sleep_intent = false


func _on_bed_clicked() -> void:
	var pos := _bed_point.global_position

	_cursor.global_position = pos
	_cursor.visible = true
	_player.move_to(pos)

	_open_pc_intent = false
	_open_telescope_intent = false
	_sleep_intent = true


func _on_timeout() -> void:
	_label.visible = false


func _on_event_timer_timeout() -> void:
	var event_data: EventData = _events.pop_front()
	if not event_data:
		EventBus.emit_research_failed()
		return

	EventBus.emit_new_event(event_data)


func _on_report_sent(_data: ReportData) -> void:
	get_tree().paused = false
	_event_timer.start()


func _on_report_skipped(_data: ReportData) -> void:
	_event_timer.start()
