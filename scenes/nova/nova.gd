class_name Nova
extends Sprite2D

@onready var _notifier: VisibleOnScreenNotifier2D = %VisibleOnScreenNotifier2D

signal entered(n: Nova)
signal exited(n: Nova)


func _ready() -> void:
	assert(_notifier != null, "notifier is not set")

	_notifier.screen_entered.connect(_on_screen_entered)
	_notifier.screen_exited.connect(_on_screen_exited)


func _on_screen_entered() -> void:
	entered.emit(self )


func _on_screen_exited() -> void:
	exited.emit(self )
