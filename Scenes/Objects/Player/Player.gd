extends Area3D

@export var footstep_hard_sounds: Array[AudioStream] = []
@export var woosh_sound: AudioStream

var move_distance: float = 2.0
var move_speed: float = 0.2
var strafe_speed: float = 0.14
var turn_speed: float = 0.1
var target_position: Vector3
var target_rotation: float
var is_moving: bool #não interpolar em movimento atual
var is_strafing: bool # mvimento lateral e para trás é mais lento
var is_thermal_vision_on: bool

@onready var backward_ray: RayCast3D = $BackwardRay
@onready var forward_ray: RayCast3D = $ForwardRay
@onready var left_ray: RayCast3D = $LeftRay
@onready var right_ray: RayCast3D = $RightRay
@onready var camera: Camera3D = $CanvasLayer/SubViewportContainer/SubViewport/Camera3D
@onready var audio_stream_player_3d_bottom: AudioStreamPlayer3D = $AudioStreamPlayer3DBottom
@onready var audio_stream_player_3d_left: AudioStreamPlayer3D = $AudioStreamPlayer3DLeft
@onready var audio_stream_player_3d_right: AudioStreamPlayer3D = $AudioStreamPlayer3DRight
@onready var shader_container: SubViewportContainer = $CanvasLayer/SubViewportContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target_position = global_position
	camera.global_transform = global_transform
	is_moving = false
	is_strafing = false
	is_thermal_vision_on = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	camera.global_transform = global_transform
	
	if not is_moving:
		if Input.is_action_just_pressed("move_forward"):
			move_forward()
		elif Input.is_action_just_pressed("move_backward"):
			move_backward()
		elif Input.is_action_just_pressed("move_left"):
			move_left()
		elif Input.is_action_just_pressed("move_right"):
			move_right()
		elif Input.is_action_just_pressed("turn_left"):
			turn_left()
		elif Input.is_action_just_pressed("turn_right"):
			turn_right()
	
	if Input.is_action_just_pressed("heatvision"):
		toggle_thermal_vision()
		
func _physics_process(_delta: float) -> void:
	if is_moving:
		var speed: float
		if is_strafing:
			speed = strafe_speed
		else:
			speed = move_speed
		if not global_position == target_position:
			global_position = lerp(global_position, target_position, speed)	
			if global_position.distance_to(target_position) < 0.05:
				global_position = target_position
				is_moving = false
				is_strafing = false
		
	
	if global_position.distance_to(target_position) < 0.05:
		global_position = target_position
		is_moving = false
		is_strafing = false

func play_sound_bottom(sound: AudioStream, randomize: bool):
	audio_stream_player_3d_bottom.stream = sound
	if randomize:
		audio_stream_player_3d_bottom.pitch_scale = randf_range(0.9, 1.15)
	audio_stream_player_3d_bottom.play()

func play_footstep_sound()	:
	if footstep_hard_sounds.size() > 0:
		play_sound_bottom(footstep_hard_sounds.pick_random(), true)
	
func move_forward():
	#global_transform.basis.z -> onde é o z em relação a você?
	if not forward_ray.is_colliding():
		target_position -= global_transform.basis.z * move_distance
		is_moving = true
		play_footstep_sound()
	
func move_backward():
	if not backward_ray.is_colliding():
		target_position += global_transform.basis.z * move_distance	
		is_moving = true
		is_strafing = true
		play_footstep_sound()
	
func move_left():
	if not left_ray.is_colliding():
		target_position -= global_transform.basis.x * move_distance	
		is_moving = true
		is_strafing = true
		play_footstep_sound()
	
func move_right():
	if not right_ray.is_colliding():
		target_position += global_transform.basis.x * move_distance
		is_moving = true
		is_strafing = true
		play_footstep_sound()
		
		
func play_sound_left_ear(sound: AudioStream, randomize: bool):
	if not sound: return
	audio_stream_player_3d_left.stream = sound
	if randomize:
		audio_stream_player_3d_left.pitch_scale = randf_range(0.9, 1.15)
	else:
		audio_stream_player_3d_left.pitch_scale = 1.0
	audio_stream_player_3d_left.play()
		
func play_sound_right_ear(sound: AudioStream, randomize: bool):
	if not sound: return
	audio_stream_player_3d_right.stream = sound
	if randomize:
		audio_stream_player_3d_right.pitch_scale = randf_range(0.9, 1.15)
	else:
		audio_stream_player_3d_right.pitch_scale = 1.0
	audio_stream_player_3d_right.play()
	
func turn_left():
	is_moving = true
	target_rotation = rotation.y + PI/2.0
	var tween = create_tween()
	tween.tween_property(self, "rotation:y", target_rotation, turn_speed)
	tween.finished.connect(func(): is_moving = false)
	
	play_sound_left_ear(woosh_sound, true)
	
	
func turn_right():
	is_moving = true
	target_rotation = rotation.y - PI/2.0
	var tween = create_tween()
	tween.tween_property(self, "rotation:y", target_rotation, turn_speed)
	tween.finished.connect(func(): is_moving = false)
	
	play_sound_right_ear(woosh_sound, true)


func toggle_thermal_vision():
	is_thermal_vision_on = !is_thermal_vision_on
	shader_container.material.set_shader_parameter("thermal_vision", is_thermal_vision_on)
	
	get_tree().call_group("NPCs", "set_thermal_mode", is_thermal_vision_on)
	
