class_name Player
extends CharacterBody2D

@export var speed = 100

@onready var _agent: NavigationAgent2D = %NavigationAgent2D

signal move_finished

var _reports: Array[ReportData]


func _ready() -> void:
	_agent.navigation_finished.connect(_on_navigation_finished)

	EventBus.report_added.connect(_on_report_added)
	EventBus.report_sent.connect(_on_report_sent)


func get_reports() -> Array[ReportData]:
	return _reports


func move_to(pos: Vector2) -> void:
	_agent.target_position = pos


func _physics_process(_delta: float) -> void:
	if _agent.is_navigation_finished():
		velocity = Vector2.ZERO
	else:
		var next_path_pos: Vector2 = _agent.get_next_path_position()
		var direction: Vector2 = global_position.direction_to(next_path_pos)

		velocity = direction * speed

	move_and_slide()


func _on_navigation_finished() -> void:
	move_finished.emit()


func _on_report_added(data: ReportData) -> void:
	_reports.append(data)


func _on_report_sent(data: ReportData) -> void:
	_reports.erase(data)
