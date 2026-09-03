class_name Monster
extends BaseCharacter

const SCENE_FILEPATH = "res://Scenes/Characters/Monster/Monster.tscn"
const MONSTER_CHASE_RADIUS: int = 16
const MINIMUM_MOVEMENT_TIMER_WAIT_TIME: float = 0.5
const SPEED_UP_FACTOR: float = 0.3

var astar_grid: AStarGrid2D
var player_ref: Node3D
var grid_map_ref: GridMap
var former_npc_id: Constants.NPC_IDS

var speed_up_stage: int = 0

@onready var movement_timer: Timer = $MovementTimer
@onready var speed_up_timer: Timer = $SpeedUpTimer
@onready var sprite: Sprite3D = $Sprite3D

func _ready() -> void:
	super._ready()
	
	add_to_group(Constants.MONSTER_GROUP_NAME)
	add_to_group(Constants.DATA_PERSISTENCE_GROUP_NAME)
	
	player_ref = get_tree().get_first_node_in_group(Constants.PLAYER_GROUP_NAME)
	grid_map_ref = get_tree().get_first_node_in_group(Constants.GRIDMAP_GROUP_NAME)
		
	astar_grid = AStarGrid2D.new()
	
	astar_grid.region = Rect2i(-50, -50, 100, 100) 
	astar_grid.cell_size = Vector2(1, 1) 
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	
	bake_grid_map_to_astar()
	
	movement_timer.start()
	speed_up_timer.start()

func initialize(global_transf: Transform3D, pos: Vector3, rot: float, monster_tex: Texture2D, former_npc: Constants.NPC_IDS):
	global_transform = global_transf
	target_position = pos
	target_rotation = rot
	former_npc_id = former_npc
	
	if sprite == null:
		sprite = $Sprite3D
	
	sprite.texture = monster_tex
	if sprite.material_override:
		sprite.material_override = sprite.material_override.duplicate()
		sprite.material_override.set_shader_parameter("sprite_texture", sprite.texture)


#-------------------------------------------------------------------------
# TRANSFORMA O GRIDMAP DO JOGO NUM MAPA ESPECÍFICO PARA O ALGORITMO A*
#-------------------------------------------------------------------------
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
		

#-------------------------------------------------------------------------
# MOVIMENTAÇÃO
#-------------------------------------------------------------------------
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

#-------------------------------------------------------------------------
# É ATIRADO PELO PLAYER
#-------------------------------------------------------------------------
func react_to_being_shot():
	GameManager.decrease_monsters_count()
	queue_free()

#-------------------------------------------------------------------------
# FUNÇÕES DE PERSISTÊNCIA DE DADOS
#-------------------------------------------------------------------------
func save_to_state(state: Dictionary) -> void:
	var monster_state: Dictionary = get_base_character_dict()
	
	monster_state["movement_wait_time"] = movement_timer.wait_time
	monster_state["movement_time_left"] = movement_timer.time_left
	
	monster_state["speed_up_wait_time"] = speed_up_timer.wait_time
	monster_state["speed_up_time_left"] = speed_up_timer.time_left
	
	monster_state["scene_filepath"] = SCENE_FILEPATH
	monster_state["former_npc_id"] = former_npc_id
	monster_state["texture"] = sprite.texture.resource_path
	
	if not state.has("dynamic_entities"):
		state["dynamic_entities"] = {}
		
	var npc_name_string = Constants.NPC_IDS.find_key(former_npc_id).to_lower()
	state["dynamic_entities"]["monster_%s" % npc_name_string] = monster_state

func resume_movement_timer(move_wait) -> void:
	movement_timer.stop()
	movement_timer.start(move_wait)
	
func resume_speed_up_timer(speed_wait) -> void:
	speed_up_timer.stop()
	speed_up_timer.start(speed_wait)
	
func load_from_state(monster_state: Dictionary) -> void:
	set_attributes_from_dict(monster_state)
	former_npc_id = monster_state.get("former_npc_id", Constants.NPC_IDS.Louco)
	
	# --- MOVEMENT TIMER ---
	movement_timer.stop()
	var move_wait = monster_state.get("movement_wait_time", movement_timer.wait_time) 
	var move_left = monster_state.get("movement_time_left", move_wait)
	# Garantir que não é zero
	move_left = max(0.0001, move_left)
	
	# Na próxima vez que o timer roda, o wait_time é atualizado para ser o tempo na íntegra
	movement_timer.timeout.connect(resume_movement_timer.bind(move_wait) , CONNECT_ONE_SHOT)
	# Inicia o timer de onde parou da última vez
	movement_timer.start(move_left)
	
	# --- SPEED UP TIMER ---
	speed_up_timer.stop()
	var speed_wait = monster_state.get("speed_up_wait_time", speed_up_timer.wait_time) 
	var speed_left = monster_state.get("speed_up_time_left", speed_wait)
	# Garantir que não é zero
	speed_left = max(0.0001, speed_left)

	speed_up_timer.timeout.connect(resume_speed_up_timer.bind(speed_wait), CONNECT_ONE_SHOT)
	speed_up_timer.start(speed_left)
	
	var tex_path = monster_state.get("texture", "")
	if tex_path != "" and ResourceLoader.exists(tex_path):
		sprite.texture = load(tex_path)
	else:
		push_warning("Monster texture missing or invalid path: " + str(tex_path))
		
	if sprite.material_override:
		sprite.material_override = sprite.material_override.duplicate()
		if sprite.material_override is ShaderMaterial:
			sprite.material_override.set_shader_parameter("sprite_texture", sprite.texture)
