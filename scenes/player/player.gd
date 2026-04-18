class_name Player
extends CharacterBody2D

@export var speed = 100

@onready var _agent: NavigationAgent2D = %NavigationAgent2D

signal move_finished


func _ready() -> void:
	_agent.navigation_finished.connect(_on_navigation_finished)


func move_to(pos: Vector2) -> void:
	_agent.target_position = pos


func _physics_process(_delta: float) -> void:
	if _agent.is_navigation_finished():
		velocity = Vector2.ZERO
	else:
		var next_path_pos: Vector2 = _agent.get_next_path_position()
		var direction: Vector2 = global_position.direction_to(next_path_pos)

		velocity = direction * speed

	if not is_inside_tree():
			return

	move_and_slide()


func _on_navigation_finished() -> void:
	move_finished.emit()
