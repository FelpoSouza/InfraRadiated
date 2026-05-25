extends Area3D
class_name BaseCharacter

@export var footstep_hard_sounds: Array[AudioStream] = []
@export var woosh_sound: AudioStream

enum SoundDirections { CENTER, LEFT, RIGHT, TOP, BOTTOM }

var move_distance: float = 2.0

var move_duration: float = 0.2   
var strafe_duration: float = 0.4
var turn_duration: float = 0.15

var target_position: Vector3
var target_rotation: float

var is_moving: bool = false

@onready var backward_ray: RayCast3D = $BackwardRay
@onready var forward_ray: RayCast3D = $ForwardRay
@onready var left_ray: RayCast3D = $LeftRay
@onready var right_ray: RayCast3D = $RightRay
@onready var audio_stream_player_3d_center: AudioStreamPlayer3D = $AudioStreamPlayer3DCenter
@onready var audio_stream_player_3d_left: AudioStreamPlayer3D = $AudioStreamPlayer3DLeft
@onready var audio_stream_player_3d_right: AudioStreamPlayer3D = $AudioStreamPlayer3DRight
@onready var audio_stream_player_3d_top: AudioStreamPlayer3D = $AudioStreamPlayer3DTop
@onready var audio_stream_player_3d_bottom: AudioStreamPlayer3D = $AudioStreamPlayer3DBottom

func _ready() -> void:
	target_position = global_position
	target_rotation = rotation.y

func _process(delta: float) -> void:
	pass


#-------------------------------------------------------------------------
# ÁUDIO E SFX
#-------------------------------------------------------------------------

func play_footstep_sound() -> void:
	if not footstep_hard_sounds.is_empty():
		play_sound(SoundDirections.BOTTOM, footstep_hard_sounds.pick_random(), true)

func play_sound(direction: SoundDirections, sound: AudioStream, make_random: bool = false) -> void:
	if not sound: return
	
	var player: AudioStreamPlayer3D
	if direction == SoundDirections.CENTER:
		player = audio_stream_player_3d_center
	elif direction == SoundDirections.LEFT:
		player = audio_stream_player_3d_left
	elif direction == SoundDirections.RIGHT:
		player = audio_stream_player_3d_right
	elif direction == SoundDirections.TOP:
		player = audio_stream_player_3d_top
	elif direction == SoundDirections.BOTTOM:
		player = audio_stream_player_3d_bottom
		
	player.stream = sound
	player.pitch_scale = randf_range(0.9, 1.15) if make_random else 1.0
	player.play()


#-------------------------------------------------------------------------
# MOVIMENTAÇÃO
#-------------------------------------------------------------------------
func move_to(delta_pos: Vector3, duration: float) -> void:
	is_moving = true
	target_position += delta_pos
	play_footstep_sound()
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_position, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.finished.connect(func(): is_moving = false)

func try_move_forward() -> bool:
	forward_ray.force_raycast_update()
	if not forward_ray.is_colliding():
		move_to(-global_transform.basis.z * move_distance, move_duration)
		return true
	return false

func try_move_backward() -> bool:
	backward_ray.force_raycast_update()
	if not backward_ray.is_colliding():
		move_to(global_transform.basis.z * move_distance, strafe_duration)
		return true
	return false
	
func try_move_left() -> bool:
	left_ray.force_raycast_update()
	if not left_ray.is_colliding():
		move_to(-global_transform.basis.x * move_distance, strafe_duration)
		return true
	return false
	
func try_move_right() -> bool:
	right_ray.force_raycast_update()
	if not right_ray.is_colliding():
		move_to(global_transform.basis.x * move_distance, strafe_duration)
		return true
	return false
	
func turn(angle_offset: float, sound_direction: SoundDirections) -> void:
	is_moving = true
	rotation.y = target_rotation
	target_rotation += angle_offset
	
	var tween = create_tween()
	tween.tween_property(self, "rotation:y", target_rotation, turn_duration)
	tween.finished.connect(func(): 
		rotation.y = wrapf(rotation.y, -PI, PI)
		rotation.y = snapped(rotation.y , PI/2.0)
		target_rotation = rotation.y 
		is_moving = false
	)
	play_sound(sound_direction, woosh_sound, true)

func turn_left() -> void:
	turn(PI/2.0, SoundDirections.LEFT)

func turn_right() -> void:
	turn(-PI/2.0, SoundDirections.RIGHT)


func _on_movement_timer_timeout() -> void:
	pass # Replace with function body.
