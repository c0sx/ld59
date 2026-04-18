class_name Monitor
extends Node2D

@export var _default_texture: Texture
@export var _signal_texture: Texture

@onready var _sprite: Sprite2D = %Sprite2D


func _ready() -> void:
  assert(_default_texture != null, "default texture is not set")
  assert(_signal_texture != null, "signal texture is not set")
  assert(_sprite != null, "sprite is not set")

  hide_signal()


func show_signal() -> void:
  _sprite.texture = _signal_texture


func hide_signal() -> void:
  _sprite.texture = _default_texture
