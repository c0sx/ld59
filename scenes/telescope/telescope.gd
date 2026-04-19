class_name Telescope
extends Node2D

@export var progress_stream: AudioStream
@export var focus_streams: Array[AudioStream]
@export var config: DayConfig
@export var camera: Camera2D
@export var speed: float = 0.4
@export var auto_moving_speed = 10
@export var focus_duration: float = 0.75
@export var analyze_duration: float = 1
@export var event_scene: PackedScene
@export var report_added_text: String = "Report added"
@export var report_already_added_text: String = "Report already added"
@export var report_skipped_text: String = "Report skipped"

@onready var _sprite: Sprite2D = %Sprite2D
@onready var _container: Node2D = %Container
@onready var _progress: ProgressBar = %ProgressBar
@onready var _label: Label = %Label
@onready var _notification_timer: Timer = %Timer
@onready var _canvas: CanvasLayer = %CanvasLayer
@onready var _focusing_container: VBoxContainer = %FocusingHelper
@onready var _analyzing_container: VBoxContainer = %AnalyzingHelper
@onready var _focus_rect: TextureRect = %FocusRect
@onready var _audio: AudioStreamPlayer2D = %AudioStreamPlayer2D

signal closed

const DISTANCE_THRESHOLD = 0.1

var _reported_events: Array[Event]
var _events: Array[Event]
var _focus_event: Event
var _looking_disabled: bool
var _tw: Tween
var _old_position: Vector2 = Vector2.ZERO

var _is_focused: bool


func _ready() -> void:
	assert(focus_streams.size() > 0, "empty focus streams")
	assert(progress_stream != null, "progress stream is not set")
	assert(config != null, "config is not set")
	assert(camera != null, "camera is not set")
	assert(_sprite != null, "sprite is not set")
	assert(event_scene != null, "event scene is not set")
	assert(_container != null, "container is not set")
	assert(_progress != null, "progress bar is not set")
	assert(_label != null, "label is not set")
	assert(_notification_timer != null, "notification timer is not set")
	assert(_canvas != null, "canvas layer is not set")
	assert(_focusing_container != null, "focusing container is not set")
	assert(_analyzing_container != null, "analyzing container is not set")
	assert(_focus_rect != null, "focus rect is not set")
	assert(_audio != null, "audio is not set")

	EventBus.new_event.connect(_on_new_event)

	_notification_timer.timeout.connect(_on_timeout)

	_focusing_container.visible = false
	_analyzing_container.visible = false
	_focus_rect.visible = false
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

	if not _is_focused:
		if event.is_action_pressed(InputActions.Esc, false):
			_try_to_close()

		if event.is_action_pressed(InputActions.Interact):
			_try_to_focus()

		if event.is_action_released(InputActions.Interact):
			_try_to_stop_focus()

		if event is InputEventMouseMotion:
			_try_to_look(event.relative)
	else:
		if event.is_action_pressed(InputActions.Esc, false):
			_try_to_unfocus()

		if event is InputEventMouseButton:
			var e := event as InputEventMouseButton
			if e.button_index == MOUSE_BUTTON_RIGHT:
				if e.pressed:
					_try_to_skip()
				else:
					_try_to_stop_skip()

			if e.button_index == MOUSE_BUTTON_LEFT:
				if e.pressed:
					_try_to_send_signal()
				else:
					_try_to_stop_send_signal()

		if event is InputEventMouseMotion:
			_try_to_look(event.relative)


func enter() -> void:
	_canvas.visible = true
	_focusing_container.visible = true
	_analyzing_container.visible = false
	_focus_rect.visible = false
	_looking_disabled = false

	var pos := _old_position
	if pos == Vector2.ZERO:
		pos = _sprite.global_position

	camera.global_position = pos
	camera.make_current()

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# unfocus

func _try_to_unfocus() -> void:
	if not _is_focused:
		return

	_is_focused = false
	_looking_disabled = false
	_focus_rect.visible = false
	_focusing_container.visible = true
	_analyzing_container.visible = false


# close start

func _try_to_close() -> void:
	_canvas.visible = false
	_focusing_container.visible = false
	_old_position = camera.global_position

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	closed.emit()

# close end


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


# look start

func _try_to_look(relative: Vector2) -> void:
	if _looking_disabled:
		return

	var new_pos := _fit_in_borders(relative * speed)
	camera.global_position = new_pos

# look end

# focus start

func _try_to_focus() -> void:
	if _events.size() == 0:
		return

	var closest := _find_closest_event()
	if not closest:
		return

	_focus_event = closest
	_looking_disabled = true

	var distance := camera.global_position.distance_to(_focus_event.global_position)
	if distance < DISTANCE_THRESHOLD:
		_on_focused()
	else:
		_tw = get_tree().create_tween()
		_tw.tween_property(camera, "global_position", _focus_event.global_position, focus_duration)
		_tw.tween_callback(_on_focused)


func _try_to_stop_focus() -> void:
	if not _focus_event:
		return

	_stop_focus()
	_looking_disabled = false
	_focus_event = null


func _on_focused() -> void:
	_stop_focus()
	_is_focused = true

	var stream: AudioStream = focus_streams.pick_random()
	_audio.stream = stream
	_audio.play()

	_progress.value = 0
	_focusing_container.visible = false
	_analyzing_container.visible = true
	_focus_rect.visible = true


func _stop_focus() -> void:
	if _tw:
		_tw.kill()
		_tw = null


# focus end

# skip start

func _try_to_skip() -> void:
	if not _focus_event:
		return

	_tw = get_tree().create_tween()
	_progress.visible = true
	_tw.tween_property(_progress, "value", 100, analyze_duration)
	_tw.tween_callback(_on_skipped)

	_audio.stream = progress_stream
	_audio.play()


func _try_to_stop_skip() -> void:
	if not _focus_event:
		return

	_stop_skip()


func _on_skipped() -> void:
	_stop_skip()
	_focus_rect.visible = false
	_is_focused = false
	_looking_disabled = false
	_analyzing_container.visible = false

	var report_data := ReportData.new()
	var texture: Texture = _focus_event.event.textures.get(0)
	report_data.texture = texture
	report_data.event_data = _focus_event.event
	report_data.is_signal_sent = false

	var stream: AudioStream = focus_streams.pick_random()
	_audio.stream = stream
	_audio.play()

	EventBus.emit_report_skipped(report_data)

	_focus_event.mark_analyzed()
	_reported_events.append(_focus_event)
	_show_notification(report_skipped_text)


func _stop_skip() -> void:
	if _tw:
		_tw.kill()
		_tw = null

	_progress.value = 0
	_progress.visible = false


# skip end

# send signal start

func _try_to_send_signal() -> void:
	if not _focus_event:
		return

	_tw = get_tree().create_tween()
	_progress.visible = true
	_tw.tween_property(_progress, "value", 100, analyze_duration)
	_tw.tween_callback(_on_send_signal)

	_audio.stream = progress_stream
	_audio.play()


func _on_send_signal() -> void:
	_stop_send_signal()
	_focus_rect.visible = false
	_is_focused = false
	_looking_disabled = false
	_analyzing_container.visible = false

	var report_data := ReportData.new()
	var texture: Texture = _focus_event.event.textures.get(0)
	report_data.texture = texture
	report_data.event_data = _focus_event.event
	report_data.is_signal_sent = true

	var stream: AudioStream = focus_streams.pick_random()
	_audio.stream = stream
	_audio.play()

	EventBus.emit_report_added(report_data)

	_focus_event.mark_analyzed()
	_reported_events.append(_focus_event)
	_show_notification(report_added_text)


func _try_to_stop_send_signal() -> void:
	if not _focus_event:
		return

	_stop_send_signal()


func _stop_send_signal() -> void:
	if _tw:
		_tw.kill()
		_tw = null

	_progress.value = 0
	_progress.visible = false


# send signal end


func _show_notification(message: String) -> void:
	if not _notification_timer.is_stopped():
		_notification_timer.stop()

	_label.text = message
	_label.visible = true
	_notification_timer.start()


func _find_closest_event() -> Event:
	var closest: Event
	var closest_dist: float = INF
	for event in _events:
		if _reported_events.has(event):
			continue

		var dist: float = abs(event.global_position.distance_to(camera.global_position))
		if dist < closest_dist:
			closest_dist = dist
			closest = event

	return closest


func _on_event_entered(n: Event) -> void:
	_events.append(n)


func _on_event_exited(n: Event) -> void:
	_events.erase(n)


func _on_timeout() -> void:
	_label.visible = false


func _on_new_event(event_data: EventData) -> void:
	register_new_event(event_data)
