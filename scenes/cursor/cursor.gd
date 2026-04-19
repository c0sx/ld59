class_name Cursor
extends Node2D

@onready var _sprite: AnimatedSprite2D = %AnimatedSprite2D


func _ready() -> void:
  assert(_sprite != null, "animated sprite is not set")

  _sprite.play("default")
