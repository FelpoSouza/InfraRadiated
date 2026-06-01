extends BaseCharacter

@export var monster_texture: Texture2D

const MONSTER_CHASE_RADIUS: int = 16
const MINIMUM_MOVEMENT_TIMER_WAIT_TIME: float = 0.5
const SPEED_UP_FACTOR: float = 0.3

var astar_grid: AStarGrid2D
var player_ref: Node3D
var grid_map_ref: GridMap

@onready var movement_timer: Timer = $MovementTimer
@onready var speed_up_timer: Timer = $SpeedUpTimer
@onready var sprite: Sprite3D = $Sprite3D

func _ready() -> void:
	super._ready()
	
	add_to_group(Constants.MONSTER_GROUP_NAME)
	
	player_ref = get_tree().get_first_node_in_group(Constants.PLAYER_GROUP_NAME)
	grid_map_ref = get_tree().get_first_node_in_group(Constants.GRIDMAP_GROUP_NAME)
	
	if monster_texture != null:
		sprite.texture = monster_texture
		var mat = sprite.material_override
		mat.set_shader_parameter("sprite_texture", sprite.texture)
	
	astar_grid = AStarGrid2D.new()
	
	astar_grid.region = Rect2i(-50, -50, 100, 100) 
	astar_grid.cell_size = Vector2(1, 1) 
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	
	global_rotation = Vector3.ZERO
	
	bake_grid_map_to_astar()
	
	movement_timer.start()
	speed_up_timer.start()

func bake_grid_map_to_astar() -> void:
	await get_tree().process_frame
	
	if not grid_map_ref:
		push_warning("GridMap reference missing from group!")
		return
	
	# Pega um array de cada coordanada usada no mapa
	var used_cells = grid_map_ref.get_used_cells()
	

	
	for cell in used_cells:
		# cell é um Vector3i (x, y, z) represntando os espaços da grid
		
		# Os obstáculos estão apenas na camada 1
		if cell.y != 1:
			continue
			
		# Projeta as coordandas 3D da grid para a 2D do A*
		var grid_x = cell.x
		var grid_z = cell.z
		
		# Checa se a coordenada está dentro da grid
		if astar_grid.region.has_point(Vector2i(grid_x, grid_z)):
			# Senão, marca ela como um obstáculo
			astar_grid.set_point_solid(Vector2i(grid_x, grid_z), true)
		

func _on_movement_timer_timeout() -> void:
	if not is_instance_valid(player_ref):
		return
		
	# Pergunta para o GridMap em qual célula o Monstro está
	var monster_local_pos = grid_map_ref.to_local(global_position)
	var monster_map_pos_3d = grid_map_ref.local_to_map(monster_local_pos)
	var monster_grid_pos = Vector2i(monster_map_pos_3d.x, monster_map_pos_3d.z)
	
	# Pergunta para o GridMap em qual célula o Player está
	var player_local_pos = grid_map_ref.to_local(player_ref.global_position)
	var player_map_pos_3d = grid_map_ref.local_to_map(player_local_pos)
	var player_grid_pos = Vector2i(player_map_pos_3d.x, player_map_pos_3d.z)
	
	var chase_path = astar_grid.get_id_path(monster_grid_pos, player_grid_pos)
	
	if chase_path.is_empty():
		# Nenhum caminho foi encontrado
		return
	
	if chase_path.size() == 1:
		# O monstro está em cima do jogador
		# A detecção de morte está no script do jogador
		return
		
	var direction = chase_path[1] - chase_path[0]
	
	
	match direction:
		Vector2i(0, -1):
			try_move_forward()
		Vector2i(0, 1):
			try_move_backward()
		Vector2i(1, 0):
			try_move_right()
		Vector2i(-1, 0):
			try_move_left()
		_:
			print("Invalid direction")


func _on_speed_up_timer_timeout() -> void:
	var new_time = movement_timer.wait_time - SPEED_UP_FACTOR
	movement_timer.wait_time = max(MINIMUM_MOVEMENT_TIMER_WAIT_TIME, new_time)
