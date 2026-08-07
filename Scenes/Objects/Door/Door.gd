extends CharacterBody3D
var is_open: bool = false
var closed_rotation: float
var open_rotation: float
const MOVE_SPEED: float = 0.5
@export var door_switch: StaticBody3D 

func _ready() -> void:
	closed_rotation = rotation.y
	open_rotation = closed_rotation + PI / 2.0
	door_switch.switch_toggled.connect(_toggle_door)

func _toggle_door() -> void:
	if is_open:
		var tween = create_tween()
		tween.tween_property(self, "rotation:y", closed_rotation, MOVE_SPEED)
		is_open = false
	else:
		var tween = create_tween()
		tween.tween_property(self, "rotation:y", open_rotation, MOVE_SPEED)
		is_open = true
