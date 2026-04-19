class_name Monitor
extends Node2D

@export var ok_stream: AudioStream
@export var err_stream: AudioStream
@export var ok_message: String = 'ok'
@export var first_error_message: String = 'danger'
@export var second_error_message: String = 'keep silent'
@export var third_error_message: String = 'found you'
@export var new_event_message: String = 'new coords'
@export var send_report_message: String = "send report"
@export var loading_coords_message: String = "loading"

@onready var _sprite: Sprite2D = %Sprite2D
@onready var _timer: Timer = %Timer
@onready var _ok_label: Label = %OKLabel
@onready var _error_label: Label = %ErrorLabel
@onready var _audio: AudioStreamPlayer2D = %AudioStreamPlayer2D


func _ready() -> void:
  assert(ok_stream != null, "ok stream is not set")
  assert(err_stream != null, "err stream is not set")
  assert(_sprite != null, "sprite is not set")
  assert(_ok_label != null, "ok label is not set")
  assert(_error_label != null, "error label is not set")
  assert(_audio != null, "audio is not set")

  EventBus.new_event.connect(_on_new_event)
  EventBus.ok_report_sent.connect(_on_ok_report_sent)
  EventBus.error_report_sent.connect(_on_error_report_sent)
  EventBus.report_added.connect(_on_report_added)
  EventBus.report_skipped.connect(_on_report_skipped)
  EventBus.brief_read.connect(_on_brief_read)

  _timer.timeout.connect(_on_timeout)

  _error_label.visible = false
  _ok_label.visible = false


func _show_ok_message(msg: String, start_timer: bool = true) -> void:
  _timer.stop()
  _error_label.visible = false
  _ok_label.visible = true
  _ok_label.text = msg

  _audio.stop()
  _audio.stream = ok_stream
  _audio.play()

  if start_timer:
    _timer.start()


func _show_error_message(msg: String) -> void:
  _timer.stop()
  _error_label.visible = true
  _ok_label.visible = false
  _error_label.text = msg

  _audio.stop()
  _audio.stream = err_stream
  _audio.play()

  _timer.start()


func _on_ok_report_sent(_data: ReportData) -> void:
  _show_ok_message(ok_message)


func _on_timeout() -> void:
  _error_label.visible = false
  _ok_label.visible = false

  if _error_label.text == third_error_message:
    EventBus.emit_game_over()


func _on_error_report_sent(_data: ReportData, errors_counter: int) -> void:
  if errors_counter == 1:
    _show_error_message(first_error_message)
  elif errors_counter == 2:
    _show_error_message(second_error_message)
  elif errors_counter == 3:
    _show_error_message(third_error_message)


func _on_report_added(_data: ReportData) -> void:
  _error_label.visible = false
  _ok_label.visible = false

  _show_ok_message(send_report_message, false)


func _on_report_skipped(_data: ReportData) -> void:
  _error_label.visible = false
  _ok_label.visible = false


func _on_new_event(_event: EventData) -> void:
  _show_ok_message(new_event_message, false)


func _on_brief_read() -> void:
  _show_ok_message(loading_coords_message, false)
