class_name MainScene
extends Node2D

@onready var _lab: Lab = %Lab
@onready var _telescope: Telescope = %Telescope
@onready var _camera: Camera2D = %Camera2D


func _ready() -> void:
	assert(_lab != null, "lab is not set")
	assert(_telescope != null, "telescope is not set")
	assert(_camera != null, "camera is not set")

	_telescope.visible = false
	_telescope.process_mode = Node.PROCESS_MODE_DISABLED

	_lab.looked_into_telescope.connect(_on_looked_into_telescope)
	_lab.new_event.connect(_on_new_event)
	_telescope.report_added.connect(_on_report_added)
	_telescope.closed.connect(_on_look_stopped)

	_camera.make_current()
	_lab.enter()


func _on_looked_into_telescope() -> void:
	_telescope.visible = true
	_telescope.process_mode = Node.PROCESS_MODE_INHERIT

	_lab.visible = false
	_lab.process_mode = Node.PROCESS_MODE_DISABLED

	_telescope.enter()


func _on_look_stopped() -> void:
	_telescope.visible = false
	_telescope.process_mode = Node.PROCESS_MODE_DISABLED

	_lab.visible = true
	_lab.process_mode = Node.PROCESS_MODE_INHERIT

	_lab.enter()


func _on_report_added(report_data: ReportData) -> void:
	_lab.add_report(report_data)


func _on_new_event(event_data: EventData) -> void:
	_telescope.register_new_event(event_data)
