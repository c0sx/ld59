extends Panel

@onready var _button: Button = %Button

func _ready() -> void:
	assert(_button != null, "button is not set")

	EventBus.research_completed.connect(_on_research_completed)

	_button.pressed.connect(_on_pressed)


func _on_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_research_completed() -> void:
	get_tree().paused = true
	visible = true
