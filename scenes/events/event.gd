class_name Event
extends AnimatedSprite2D

@export var event: EventData

@onready var _notifier: VisibleOnScreenNotifier2D = %VisibleOnScreenNotifier2D

signal entered(n: Event)
signal exited(n: Event)


func _ready() -> void:
	assert(_notifier != null, "notifier is not set")
	sprite_frames = sprite_frames.duplicate()

	_notifier.screen_entered.connect(_on_screen_entered)
	_notifier.screen_exited.connect(_on_screen_exited)

	for texture in event.textures:
		sprite_frames.add_frame("default", texture)

	material = material.duplicate()
	material.set_shader_parameter("amount", 0.0)

	play("default")


func mark_analyzed() -> void:
	material.set_shader_parameter("amount", 1.0)


func _on_screen_entered() -> void:
	entered.emit(self )


func _on_screen_exited() -> void:
	exited.emit(self )
