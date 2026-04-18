extends Panel

@onready var _label: Label = %Label
@onready var _scroll: ScrollContainer = %ScrollContainer
@onready var _button: Button = %Button


func _ready():
	assert(_label != null, "label is not set")
	assert(_scroll != null, "scroll is not set")
	assert(_button != null, "button is not set")

	EventBus.game_over.connect(_on_game_over)

	_button.pressed.connect(_on_pressed)

	await get_tree().process_frame
	_scroll.scroll_vertical = 0


func _on_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_game_over() -> void:
	get_tree().paused = true
	visible = true
