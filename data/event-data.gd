class_name EventData
extends Resource

@export var texture: Texture
@export var name: String
@export var description: String
@export var is_anomaly: bool


func analyze() -> void:
  if is_anomaly:
    EventBus.emit_anomaly_analyzed(self )
  else:
    EventBus.emit_event_analyzed(self )
