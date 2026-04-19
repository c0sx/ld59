class_name Player
extends CharacterBody2D


@export var movement_speed = 100
@export var steps: Array[AudioStream]

@onready var _agent: NavigationAgent2D = %NavigationAgent2D
@onready var _animated_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var _audio: AudioStreamPlayer2D = %Audio

signal move_finished

var _reports: Array[ReportData]


func _ready() -> void:
	assert(_agent != null, "agent is not set")
	assert(_animated_sprite != null, "animated sprite is not set")
	assert(_audio != null, "audio is not set")

	_agent.navigation_finished.connect(_on_navigation_finished)

	EventBus.report_added.connect(_on_report_added)
	EventBus.report_sent.connect(_on_report_sent)

	_animated_sprite.stop()
	_animated_sprite.play("idle")
	_animated_sprite.frame_changed.connect(_on_frame_changed.call_deferred)


func get_reports() -> Array[ReportData]:
	return _reports


func move_to(pos: Vector2) -> void:
	var dir := pos.x - global_position.x
	_animated_sprite.flip_h = dir < 0

	_agent.target_position = pos

	if _animated_sprite.animation == "walk":
		return

	_animated_sprite.stop()
	_animated_sprite.play("walk")


func _physics_process(_delta: float) -> void:
	if _agent.is_navigation_finished():
		velocity = Vector2.ZERO
	else:
		var next_path_pos: Vector2 = _agent.get_next_path_position()
		var direction: Vector2 = global_position.direction_to(next_path_pos)

		velocity = direction * movement_speed

	move_and_slide()


func _on_navigation_finished() -> void:
	move_finished.emit()

	_animated_sprite.stop()
	_animated_sprite.play("idle")


func _on_report_added(data: ReportData) -> void:
	_reports.append(data)


func _on_report_sent(data: ReportData) -> void:
	_reports.erase(data)


func _on_frame_changed() -> void:
	if _animated_sprite.is_playing() and _animated_sprite.animation == "walk":
		var frame = _animated_sprite.frame
		if frame % 2 == 0:
			var stream: AudioStream = steps.pick_random()
			var pitch := randf_range(0, 0.15)
			_audio.stream = stream
			_audio.pitch_scale += pitch
			_audio.play()
