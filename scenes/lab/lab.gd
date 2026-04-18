class_name Lab
extends Node2D

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

signal looked_into_telescope

var _open_telescope_intent: bool
var _open_pc_intent: bool
var _reports: Array[ReportData]


func _ready() -> void:
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

	_player.move_finished.connect(_on_move_finished)
	_telescope.clicked.connect(_on_telescope_clicked)
	_pc.clicked.connect(_on_pc_clicked)
	_pc.reports_sent.connect(_on_reports_sent)
	_notification_timer.timeout.connect(_on_timeout)

	_cursor.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var e = event as InputEventMouseButton
		if not e.pressed:
			return

		var pos := get_global_mouse_position()

		if _is_point_on_navmesh(pos):
			_open_telescope_intent = false
			_open_pc_intent = false
			_cursor.global_position = pos
			_cursor.visible = true
			_player.move_to(pos)


func enter() -> void:
	var offset = get_viewport_rect().size / 2
	var pos: Vector2 = global_position + Vector2(offset.x, offset.y)
	camera.global_position = pos


func add_report(data: ReportData) -> void:
	_reports.append(data)


func _is_point_on_navmesh(point: Vector2) -> bool:
	var map := get_world_2d().navigation_map
	var closest := NavigationServer2D.map_get_closest_point(map, point)

	return closest.distance_to(point) < 1.0


func _on_move_finished() -> void:
	_cursor.visible = false

	if _open_telescope_intent:
		looked_into_telescope.emit()

	if _open_pc_intent:
		_try_to_send_reports()


func _try_to_send_reports() -> void:
	if _reports.size() == 0:
		_show_notification("Doesn't have reports to send")
		return

	_pc.send_reports(_reports)
	_reports.clear()
	get_tree().paused = true


func _show_notification(message: String) -> void:
	if not _notification_timer.is_stopped():
		_notification_timer.stop()

	_label.text = message
	_label.visible = true
	_notification_timer.start()


func _on_telescope_clicked() -> void:
	var pos := _telescope_point.global_position

	_cursor.global_position = pos
	_cursor.visible = true
	_player.move_to(pos)

	_open_telescope_intent = true
	_open_pc_intent = false


func _on_pc_clicked() -> void:
	var pos := _chair.global_position

	_cursor.global_position = pos
	_cursor.visible = true
	_player.move_to(pos)

	_open_pc_intent = true
	_open_telescope_intent = false


func _on_timeout() -> void:
	_label.visible = false


func _on_reports_sent() -> void:
	_show_notification("All reports sent")
	get_tree().paused = false
