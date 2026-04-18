class_name Monitor
extends Node2D

@export var _default_texture: Texture
@export var _signal_texture: Texture
@export var _ok_texture: Texture
@export var _first_error_texture: Texture
@export var _second_error_texture: Texture
@export var _third_error_texture: Texture

@onready var _sprite: Sprite2D = %Sprite2D
@onready var _timer: Timer = %Timer


func _ready() -> void:
  assert(_default_texture != null, "default texture is not set")
  assert(_signal_texture != null, "signal texture is not set")
  assert(_ok_texture != null, "ok texture is not set")
  assert(_first_error_texture != null, "first error texture is not set")
  assert(_second_error_texture != null, "second error texture is not set")
  assert(_third_error_texture != null, "third error texture is not set")
  assert(_sprite != null, "sprite is not set")

  EventBus.ok_report_sent.connect(_on_ok_report_sent)
  EventBus.error_report_sent.connect(_on_error_report_sent)
  EventBus.report_added.connect(_on_report_added)
  EventBus.report_skipped.connect(_on_report_skipped)

  _timer.timeout.connect(_on_timeout)

  hide_signal()


func show_signal() -> void:
  _sprite.texture = _signal_texture


func hide_signal() -> void:
  _sprite.texture = _default_texture


func _on_ok_report_sent(_data: ReportData) -> void:
  _sprite.texture = _ok_texture
  _timer.start()


func _on_timeout() -> void:
  if _sprite.texture == _third_error_texture:
    EventBus.emit_game_over()
  else:
    _sprite.texture = _default_texture


func _on_error_report_sent(_data: ReportData, errors_counter: int) -> void:
  var texture := _default_texture
  if errors_counter == 1:
    texture = _first_error_texture
  elif errors_counter == 2:
    texture = _second_error_texture
  elif errors_counter == 3:
    texture = _third_error_texture

  _sprite.texture = texture
  _timer.start()


func _on_report_added(_data: ReportData) -> void:
  hide_signal()


func _on_report_skipped(_data: ReportData) -> void:
  hide_signal()
