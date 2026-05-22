extends Area3D

@export var npc_texture: Texture2D
@export var footstep_hard_sounds: Array[AudioStream] = []

var move_distance: float = 2.0
var move_speed: float = 0.2
var turn_speed: float = 0.1
var target_position: Vector3
var target_rotation: float
var is_moving: bool #não interpolar em movimento atual

@onready var forward_ray: RayCast3D = $ForwardRay
@onready var sprite: Sprite3D = $Sprite3D
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

const THERMAL_NPC_MATERIAL = preload("res://Materials/Thermal/ThermalNPCMaterial.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("NPCs")
	
	target_position = global_position
	is_moving = false
	
	if npc_texture != null:
		sprite.texture = npc_texture
		var mat = sprite.material_override
		mat.set_shader_parameter("sprite_texture", sprite.texture)

		
func _physics_process(_delta: float) -> void:
	if is_moving:
		var speed: float
		if not global_position == target_position:
			global_position = lerp(global_position, target_position, move_speed)	
			if global_position.distance_to(target_position) < 0.05:
				global_position = target_position
				is_moving = false
		
	
	if global_position.distance_to(target_position) < 0.05:
		global_position = target_position
		is_moving = false
		
func play_footstep_sound():
	if footstep_hard_sounds.size() > 0:
		audio_stream_player_3d.stream = footstep_hard_sounds.pick_random()
		audio_stream_player_3d.pitch_scale = randf_range(0.9, 1.15)
		audio_stream_player_3d.play()
		
func move_forward():
	#global_transform.basis.z -> onde é o z em relação a você?
	if not forward_ray.is_colliding():
		target_position -= global_transform.basis.z * move_distance
		is_moving = true
		play_footstep_sound()
		return true
	return false
	
	
func turn_left():
	is_moving = true
	target_rotation = rotation.y + PI/2.0
	var tween = create_tween()
	tween.tween_property(self, "rotation:y", target_rotation, turn_speed)
	tween.finished.connect(func(): is_moving = false)
	
	
func turn_right():
	is_moving = true
	target_rotation = rotation.y - PI/2.0
	var tween = create_tween()
	tween.tween_property(self, "rotation:y", target_rotation, turn_speed)
	tween.finished.connect(func(): is_moving = false)


func _on_movement_timer_timeout() -> void:
	var random_movement = randi() % 2
	
	if random_movement == 0:
		if not move_forward():
			print("PAREDE NA FRENTE")
			turn_left()
	elif random_movement == 1:
		turn_left()
	elif random_movement == 2:
		turn_right()
		

func set_thermal_mode(is_active: bool) -> void:
	if is_active:
		var current_tex = sprite.texture
		THERMAL_NPC_MATERIAL.set_shader_parameter("sprite_texture", current_tex)
		sprite.material_override = THERMAL_NPC_MATERIAL
	else:
		sprite.material_override = null
	
