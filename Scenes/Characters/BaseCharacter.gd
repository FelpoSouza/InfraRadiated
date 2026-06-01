extends Area3D
class_name BaseCharacter

@export var footstep_wood_sounds: Array[AudioStream] = []
@export var footstep_grass_sounds: Array[AudioStream] = []
@export var woosh_sound: AudioStream

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
@onready var bottom_ray: RayCast3D = $BottomRay
@onready var audio_center: AudioStreamPlayer3D = $AudioStreamPlayer3DCenter
@onready var audio_left: AudioStreamPlayer3D = $AudioStreamPlayer3DLeft
@onready var audio_right: AudioStreamPlayer3D = $AudioStreamPlayer3DRight
@onready var audio_top: AudioStreamPlayer3D = $AudioStreamPlayer3DTop
@onready var audio_bottom: AudioStreamPlayer3D = $AudioStreamPlayer3DBottom

func _ready() -> void:
	target_position = global_position
	target_rotation = rotation.y

func _process(delta: float) -> void:
	pass


#-------------------------------------------------------------------------
# ÁUDIO E SFX
#-------------------------------------------------------------------------

func play_footstep_sound() -> void:
	if not bottom_ray.is_colliding(): return
	
	var collider = bottom_ray.get_collider()
	
	# Checa se está pisando no GridMap
	if collider is GridMap:
		var gridmap: GridMap = collider
		
		# Pega o local exato da colisão do raio
		var hit_point = bottom_ray.get_collision_point()
		var hit_normal = bottom_ray.get_collision_normal()
		
		# Desloca o ponto de colisão um pouco para dentro do tile (evita erros de ponto flutante)
		var target_inside_tile = hit_point - (hit_normal * 0.1)
		
		# Converte a posição 3D numa coordenada da grid (ex.: Vector3i(0, -1, 4))
		var map_coords = gridmap.local_to_map(gridmap.to_local(target_inside_tile))
		
		# Pega o id numérico interno do tile naquela coordenada
		var tile_id = gridmap.get_cell_item(map_coords)
		
		# Se for vazio, não toca nenhum som
		if tile_id == GridMap.INVALID_CELL_ITEM: return
		
		# Busca o nome o tile
		var tile_name = gridmap.mesh_library.get_item_name(tile_id)
		
		
		match tile_name:
			"GrassFloorMesh", "GrassTile":
				if not footstep_grass_sounds.is_empty():
					play_sound(audio_bottom, footstep_grass_sounds.pick_random(), true)
			"FloorMesh", "WallMesh":
				if not footstep_wood_sounds.is_empty():
					play_sound(audio_bottom, footstep_wood_sounds.pick_random(), true)
			_:
				if not footstep_wood_sounds.is_empty():
					play_sound(audio_bottom, footstep_wood_sounds.pick_random(), true)
			
	else:
		# Fallback caso o raio atinga um StaticBody ao invvés do GridMap
		if collider:
			play_sound(audio_bottom, footstep_wood_sounds.pick_random(), true)
			

func play_sound(audio_player: AudioStreamPlayer3D, sound: AudioStream, make_random: bool = false) -> void:
	if not sound: return
	
	audio_player.stream = sound
	audio_player.pitch_scale = randf_range(0.9, 1.15) if make_random else 1.0
	audio_player.play()


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
	
func turn(angle_offset: float, audio_player: AudioStreamPlayer3D) -> void:
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
	play_sound(audio_player, woosh_sound, true)

func turn_left() -> void:
	turn(PI/2.0, audio_left)

func turn_right() -> void:
	turn(-PI/2.0, audio_right)


func _on_movement_timer_timeout() -> void:
	pass # Replace with function body.
