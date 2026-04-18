class_name Report
extends Panel

@export var report_data: ReportData

@onready var _texture: TextureRect = %TextureRect
@onready var _name: Label = %Name
@onready var _description: Label = %Description
@onready var _button: Button = %Button


func _ready() -> void:
	EventBus.report_opened.connect(_on_report_opened)

	_button.pressed.connect(_on_send_pressed)


func show_report() -> void:
	_texture.texture = report_data.texture
	_name.text = report_data.event_data.name
	_description.text = report_data.event_data.description

	visible = true


func _on_send_pressed() -> void:
	EventBus.emit_report_sent(report_data)
	visible = false
	report_data = null


func _on_report_opened(data: ReportData) -> void:
	report_data = data
	show_report()
