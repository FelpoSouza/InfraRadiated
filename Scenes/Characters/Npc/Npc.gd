extends BaseCharacter

@export var npc_texture: Texture2D
@export var npc_id: Constants.NPC_IDS
@export var random_noise_data: Array[RandomNoiseData] = []
@export var npc_dialogue_data: NpcDialogueData

const THERMAL_NPC_MATERIAL = preload("res://Resources/Materials/Thermal/ThermalNPCMaterial.tres")

var npc_name: String

var is_talking: bool = false

var default_unique_material: Material

@onready var sprite: Sprite3D = $Sprite3D
@onready var movement_timer: Timer = $MovementTimer

func _ready() -> void:
	add_to_group(Constants.NPC_GROUP_NAME)
	add_to_group(Constants.DATA_PERSISTENCE_GROUP_NAME)
	
	npc_name = Constants.NPC_IDS.keys()[npc_id]
	target_position = global_position
	is_moving = false
	
	movement_timer.wait_time = randf_range(1.5, 3)
	movement_timer.start()
	
	if npc_texture != null:
		sprite.texture = npc_texture
		
		default_unique_material = sprite.material_override.duplicate()
		default_unique_material.set_shader_parameter("sprite_texture", sprite.texture)
		sprite.material_override = default_unique_material
	
	DialogueSystemManager.register_npc_data(npc_id, npc_dialogue_data)

func pick_random_movement():
	return [
		self.try_move_forward,
		self.try_move_backward,
		self.try_move_left,
		self.try_move_right
	].pick_random()

func _on_movement_timer_timeout() -> void:
	if is_talking:
		return
		
	var random_movement: Callable = pick_random_movement()
	
	# Fica tentando um movimento aleatório enquanto ele não tem sucesso
	while not random_movement.call():
		random_movement = pick_random_movement()
	
	movement_timer.wait_time = randf_range(1.5, 3)
	movement_timer.start()

func set_thermal_mode(is_active: bool) -> void:
	if is_active:
		var unique_thermal = THERMAL_NPC_MATERIAL.duplicate()
		unique_thermal.set_shader_parameter("sprite_texture", sprite.texture)
		sprite.material_override = unique_thermal
	else:
		sprite.material_override = default_unique_material

func show_dialog() -> void:
	DialogueSystemManager.show_dialog(npc_dialogue_data, self)


func _on_random_noise_timer_timeout() -> void:
	for noise in random_noise_data:
		if randf_range(0, 100) <= noise.random_noise_chance:
			play_sound(audio_center, noise.random_noise, true)


#-------------------------------------------------------------------------
# FUNÇÕES DE PERSISTÊNCIA DE DADOS
#-------------------------------------------------------------------------
func save_to_state(state: Dictionary) -> void:
	var npc_state: Dictionary = get_base_character_dict()
	npc_state["remaining_movement_time"] = movement_timer.time_left
	
	state[npc_name] = npc_state
	
func load_from_state(state: Dictionary) -> void:
	var npc_state: Dictionary = state.get(npc_name, {})
	set_attributes_from_dict(npc_state)
	
	movement_timer.wait_time = npc_state.get("remaining_movement_time", randf_range(1.5, 3))
	
