extends BaseCharacter

enum PeekingDirections { NONE, LEFT, RIGHT, UP, DOWN }

var peek_distance: float = 1.5
var peek_duration: float = 0.1
var camera_offset: Vector3 = Vector3.ZERO

var current_peeking: PeekingDirections = PeekingDirections.NONE
var is_thermal_vision_on: bool = false
var is_facing_npc: bool = false

@onready var camera: Camera3D = $CanvasLayer/SubViewportContainer/SubViewport/Camera3D
@onready var shader_container: SubViewportContainer = $CanvasLayer/SubViewportContainer
@onready var crosshair: ColorRect = $CanvasLayer/UserInterface/Crosshair
@onready var forward_ray_for_areas: RayCast3D = $ForwardRayForAreas
@onready var pause_menu: Control = $CanvasLayer/PauseMenu

func _ready() -> void:
	super._ready()
	add_to_group(Constants.PLAYER_GROUP_NAME)
	camera.global_transform = global_transform
	
	
func _process(_delta: float) -> void:
	super._process(_delta)
	var smoothing_factor = 1.0 - exp(-15.0 * _delta)
	camera.global_position = camera.global_position.lerp(global_position + camera_offset, smoothing_factor)
	
	camera.rotation.y = rotation.y
		
	check_crosshair_interaction()
	
#-------------------------------------------------------------------------
# INTERAÇÃO
#-------------------------------------------------------------------------
func check_crosshair_interaction() -> void:
	if forward_ray_for_areas.is_colliding():
		var target = forward_ray_for_areas.get_collider()
		
		if target and target.is_in_group(Constants.NPC_GROUP_NAME): 
			crosshair.color = Color(0.91, 0.766, 0.0, 1.0)
			is_facing_npc = true
			return
	
	is_facing_npc = false
	crosshair.color = Color(1.0, 1.0, 1.0)

func try_talk_to_npc() -> void:
	if forward_ray_for_areas.is_colliding():
		var target = forward_ray_for_areas.get_collider()
		
		if target.is_in_group(Constants.NPC_GROUP_NAME) and target.has_method("show_dialog"):
			target.show_dialog()

#-------------------------------------------------------------------------
# INPUT
#-------------------------------------------------------------------------
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
			
		elif event.is_action_pressed("interact"):
			if is_facing_npc and not DialogueSystemManager.is_dialogue_active:
				try_talk_to_npc()
	
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
	get_tree().call_group(Constants.NPC_GROUP_NAME, "set_thermal_mode", is_thermal_vision_on)
	
#-------------------------------------------------------------------------
# DETEÇÃO DE MORTE
#-------------------------------------------------------------------------
func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group(Constants.MONSTER_GROUP_NAME):
		queue_free()
