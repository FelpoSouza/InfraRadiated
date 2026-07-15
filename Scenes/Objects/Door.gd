extends CharacterBody3D
var is_open: bool = false
var open_position: Vector3 #trocar para rotation
var close_position: Vector3 #trocar para rotation
const MOVE_SPEED: float = 0.5
@export var door_switch: StaticBody3D 

func _ready() -> void:
	close_position = position
	open_position = position + Vector3(0, 2, 0)
	door_switch.switch_toggled.connect(_toggle_door)

func _toggle_door() -> void:
	if is_open:
		var tween = create_tween()
		tween.tween_property(self, "position", close_position, MOVE_SPEED)
		is_open = false
	else:
		var tween = create_tween()
		tween.tween_property(self, "position", open_position, MOVE_SPEED)
		is_open = true
