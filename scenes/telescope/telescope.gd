class_name Telescope
extends Node2D

@export var config: DayConfig
@export var camera: Camera2D
@export var speed: float = 0.4
@export var auto_moving_speed = 10
@export var focus_duration: float = 0.75
@export var analyze_duration: float = 1
@export var event_scene: PackedScene
@export var report_added_text: String = "Report added"
@export var report_already_added: String = "Report already added"

@onready var _sprite: Sprite2D = %Sprite2D
@onready var _container: Node2D = %Container
@onready var _progress: ProgressBar = %ProgressBar
@onready var _label: Label = %Label
@onready var _notification_timer: Timer = %Timer
@onready var _canvas: CanvasLayer = %CanvasLayer
@onready var _ui_container: VBoxContainer = %VBoxContainer

signal report_added(report: ReportData)
signal closed

var _reported_events: Array[Event]
var _events: Array[Event]
var _interact_event: Event
var _looking_disabled: bool
var _tw: Tween
var _report_completed: bool
var _old_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	assert(config != null, "config is not set")
	assert(camera != null, "camera is not set")
	assert(_sprite != null, "sprite is not set")
	assert(event_scene != null, "event scene is not set")
	assert(_container != null, "container is not set")
	assert(_progress != null, "progress bar is not set")
	assert(_label != null, "label is not set")
	assert(_notification_timer != null, "notification timer is not set")
	assert(_canvas != null, "canvas layer is not set")
	assert(_ui_container != null, "ui container is not set")

	_notification_timer.timeout.connect(_on_timeout)

	_ui_container.visible = false
	_progress.visible = false
	_canvas.visible = false
	_label.visible = false


func _process(delta: float) -> void:
	if _container.get_child_count() == 0:
		return

	var child: Event
	for one in _container.get_children():
		if _reported_events.has(one):
			continue

		child = one
		break

	if not child:
		return

	var dir := camera.global_position.direction_to(child.global_position)
	camera.global_position += dir * delta * auto_moving_speed


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if event.is_action_pressed(InputActions.Esc, false):
		_close()

	if event.is_action_pressed(InputActions.Interact):
		_try_to_interact()

	if event.is_action_released(InputActions.Interact):
		_try_to_stop_interaction()

	if event is InputEventMouseMotion:
		_try_to_look(event.relative)


func enter() -> void:
	_canvas.visible = true
	_ui_container.visible = true

	var pos := _old_position
	if pos == Vector2.ZERO:
		pos = _sprite.global_position

	camera.global_position = pos
	camera.make_current()

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _close() -> void:
	_canvas.visible = false
	_ui_container.visible = false
	_old_position = camera.global_position

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	closed.emit()


func _fit_in_borders(relative: Vector2) -> Vector2:
	var sprite_rect := _sprite.get_rect()
	var sprite_offset: Vector2 = sprite_rect.size / 2
	var sprite_pos := _sprite.global_position

	var camera_rect := camera.get_viewport_rect()
	var camera_offset := camera_rect.size / 2
	var camera_pos := camera.global_position + relative

	camera_pos.x = clamp(camera_pos.x, sprite_pos.x - sprite_offset.x + camera_offset.x, sprite_pos.x + sprite_offset.x - camera_offset.x)
	camera_pos.y = clamp(camera_pos.y, sprite_pos.y - sprite_offset.y + camera_offset.y, sprite_pos.y + sprite_offset.y - camera_offset.y)

	return camera_pos


func register_new_event(event: EventData) -> void:
	var sprite_rect := _sprite.get_rect()
	var sprite_offset := sprite_rect.size / 2
	var sprite_pos := _sprite.global_position

	var camera_rect := camera.get_viewport_rect()
	var camera_offset := camera_rect.size / 2

	var instance := event_scene.instantiate() as Event
	instance.event = event

	var random_x := randf_range(
		sprite_pos.x - sprite_offset.x + camera_offset.x,
		sprite_pos.x + sprite_offset.x - camera_offset.x
	)

	var random_y := randf_range(
		sprite_pos.y - sprite_offset.y + camera_offset.y,
		sprite_pos.y + sprite_offset.y - camera_offset.y
	)

	_container.add_child(instance)
	instance.global_position = Vector2(random_x, random_y)

	instance.entered.connect(_on_event_entered)
	instance.exited.connect(_on_event_exited)


func _try_to_look(relative: Vector2) -> void:
	if _looking_disabled:
		return

	var new_pos := _fit_in_borders(relative * speed)
	camera.global_position = new_pos


func _try_to_interact() -> void:
	if _events.size() == 0:
		return

	var closest: Event
	var closest_dist: float = INF
	for event in _events:
		var dist: float = abs(event.global_position.distance_to(camera.global_position))
		if dist < closest_dist:
			closest_dist = dist
			closest = event

	if not closest:
		return

	_interact_event = closest
	_looking_disabled = true

	var is_focused: bool = closest.global_position.distance_squared_to(camera.global_position) < 0.01
	if not is_focused:
		_focus_on_event()
	else:
		_analyze_event()


func _focus_on_event() -> void:
	var event := _interact_event
	if not event:
		return

	_tw = get_tree().create_tween()
	_tw.tween_property(camera, "global_position", event.global_position, focus_duration)
	_tw.tween_callback(_on_focused)


func _analyze_event() -> void:
	if not _interact_event:
		return

	if _reported_events.has(_interact_event):
		_show_notification(report_already_added)
		return

	_tw = get_tree().create_tween()
	_progress.visible = true
	_tw.tween_property(_progress, "value", 100, analyze_duration)
	_tw.tween_callback(_on_analyzed)


func _try_to_stop_interaction() -> void:
	if not _interact_event:
		return

	var is_focused: bool = _interact_event.global_position == camera.global_position
	if not is_focused:
		_stop_focus()
	else:
		_stop_analyze()

	_looking_disabled = false
	_interact_event = null


func _stop_focus() -> void:
	if _tw:
		_tw.kill()
		_tw = null


func _stop_analyze() -> void:
	if _tw:
		_tw.kill()
		_tw = null

	_progress.value = 0
	_progress.visible = false


func _show_notification(message: String) -> void:
	if not _notification_timer.is_stopped():
		_notification_timer.stop()

	_label.text = message
	_label.visible = true
	_notification_timer.start()


func _on_event_entered(n: Event) -> void:
	_events.append(n)


func _on_event_exited(n: Event) -> void:
	_events.erase(n)


func _on_focused() -> void:
	_stop_focus()

	if _interact_event:
		_analyze_event()


func _on_analyzed() -> void:
	_stop_analyze()

	var report := ReportData.new()
	report_added.emit(report)
	_report_completed = true
	_reported_events.append(_interact_event)
	_show_notification(report_added_text)


func _on_timeout() -> void:
	_label.visible = false
