extends Node3D


@export var gunshot_sound: AudioStream

@onready var gunshot_ray: RayCast3D = $GunshotRay
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D


func _ready() -> void:
	audio_stream_player_3d.stream = gunshot_sound	

func shoot() -> void:
	if animation_player.is_playing():
		return
	
	animation_player.play("shoot")
	audio_stream_player_3d.play()
	if gunshot_ray.is_colliding():
		var collider = gunshot_ray.get_collider()
		
		if collider and collider.has_method("react_to_being_shot"):
			collider.react_to_being_shot()
