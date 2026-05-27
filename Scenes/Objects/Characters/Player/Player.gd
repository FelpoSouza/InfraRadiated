extends BaseCharacter

enum PeekingDirections { NONE, LEFT, RIGHT, UP, DOWN }

var peek_distance: float = 1.5
var peek_duration: float = 0.1
var camera_offset: Vector3 = Vector3.ZERO

var current_peeking: PeekingDirections = PeekingDirections.NONE
var is_thermal_vision_on: bool = false

@onready var camera: Camera3D = $CanvasLayer/SubViewportContainer/SubViewport/Camera3D
@onready var shader_container: SubViewportContainer = $CanvasLayer/SubViewportContainer

func _ready() -> void:
	super._ready()
	camera.global_transform = global_transform

func _process(_delta: float) -> void:
	super._process(_delta)
	var smoothing_factor = 1.0 - exp(-15.0 * _delta)
	camera.global_position = camera.global_position.lerp(global_position + camera_offset, smoothing_factor)
	
	camera.rotation.y = rotation.y

func _unhandled_input(event: InputEvent) -> void:
	if is_moving: return
	var is_shifting = Input.is_action_pressed("modifier")
	
	if is_shifting:
		if event.is_action_pressed("heatvision"):
			toggle_thermal_vision()
		elif event.is_action_pressed("peek_down"):
			peek_down()
		elif event.is_action_pressed("peek_up"):
			peek_up()
		elif event.is_action_pressed("peek_left"):
			peek_left()
		elif event.is_action_pressed("peek_right"):
			peek_right()
			
	else:
		if event.is_action_pressed("move_forward"):
			try_move_forward()
		elif event.is_action_pressed("move_backward"):
			try_move_backward()
		elif event.is_action_pressed("move_left"):
			try_move_left()
		elif event.is_action_pressed("move_right"):
			try_move_right()
		elif event.is_action_pressed("turn_left"):
			turn_left()
		elif event.is_action_pressed("turn_right"):
			turn_right()
	
	if current_peeking != PeekingDirections.NONE:
		if (event.is_action_released("peek_down") or 
			event.is_action_released("peek_up") or 
			event.is_action_released("peek_left") or 
			event.is_action_released("peek_right") or 
			event.is_action_released("modifier")):
				peek_forward()


#-------------------------------------------------------------------------
# PEEKING
#-------------------------------------------------------------------------
func perform_peek(target_rot_x: float, target_rot_z: float, offset: Vector3 = Vector3.ZERO) -> void:
	is_moving = true
	camera_offset = offset
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(camera, "rotation:x", target_rot_x, peek_duration)
	tween.tween_property(camera, "rotation:z", target_rot_z, peek_duration)
	tween.chain().tween_callback(func(): is_moving = false)

func peek_down() -> void:
	if current_peeking != PeekingDirections.DOWN:
		current_peeking = PeekingDirections.DOWN
		perform_peek(-PI/6.0, 0.0)

func peek_up() -> void:
	if current_peeking != PeekingDirections.UP:
		current_peeking = PeekingDirections.UP
		perform_peek(PI/6.0, 0.0)

func peek_right() -> void:
	right_ray.force_raycast_update()
	if not right_ray.is_colliding() and current_peeking != PeekingDirections.RIGHT:
		current_peeking = PeekingDirections.RIGHT
		perform_peek(0.0, -PI/6.0, transform.basis.x.normalized() * peek_distance)

func peek_left() -> void:
	left_ray.force_raycast_update()
	if not left_ray.is_colliding() and current_peeking != PeekingDirections.LEFT:
		current_peeking = PeekingDirections.LEFT
		perform_peek(0.0, PI/6.0, -transform.basis.x.normalized() * peek_distance)

func peek_forward() -> void:
	perform_peek(0.0, 0.0, Vector3.ZERO)
	current_peeking = PeekingDirections.NONE

#-------------------------------------------------------------------------
# VISÃO TÉRMICA
#-------------------------------------------------------------------------
func toggle_thermal_vision() -> void:
	is_thermal_vision_on = not is_thermal_vision_on
	shader_container.material.set_shader_parameter("thermal_vision", is_thermal_vision_on)
	get_tree().call_group("NPCs", "set_thermal_mode", is_thermal_vision_on)
