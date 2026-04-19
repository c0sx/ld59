extends Label

var _total: int
var _current: int


func _ready() -> void:
	EventBus.events_initialized.connect(_on_events_initialized)
	EventBus.new_event.connect(_on_new_event)
	EventBus.game_over.connect(_on_hide)
	EventBus.research_completed.connect(_on_hide)
	EventBus.research_failed.connect(_on_hide)
	EventBus.sleep_started.connect(_on_hide)
	EventBus.sleep_ended.connect(_on_show)

func _update() -> void:
	text = "Stars: %s/%s" % [_current, _total]


func _on_events_initialized(events: Array[EventData]) -> void:
	_total = events.size()
	_update()


func _on_new_event(_event: EventData) -> void:
	_current += 1
	_update()


func _on_hide() -> void:
	visible = false


func _on_show() -> void:
	visible = true
