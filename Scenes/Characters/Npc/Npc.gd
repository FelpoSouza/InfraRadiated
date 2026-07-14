extends BaseCharacter

@export_group("NPC Properties")
@export var npc_texture: Texture2D
@export var npc_id: Constants.NPC_IDS
@export var random_noise_data: Array[RandomNoiseData] = []
@export var npc_dialogue_data: NpcDialogueData

@export_group("Monster Properties")
@export var is_monster: bool = false
@export var monster_scene: PackedScene
@export var monster_texture: Texture2D

const THERMAL_NPC_MATERIAL = preload("res://Resources/Materials/Thermal/ThermalNPCMaterial.tres")

var npc_name: String

var is_talking: bool = false

var default_unique_material: Material

@onready var sprite: Sprite3D = $Sprite3D
@onready var movement_timer: Timer = $MovementTimer
@onready var transform_to_monster_timer: Timer = $TransformToMonsterTimer

func _ready() -> void:
	add_to_group(Constants.NPC_GROUP_NAME)
	add_to_group(Constants.DATA_PERSISTENCE_GROUP_NAME)
	
	if is_monster:
		SignalHub.player_is_at_risk.connect(on_player_is_at_risk)
	
	npc_name = Constants.NPC_IDS.keys()[npc_id]
	target_position = global_position
	is_moving = false
	
	movement_timer.wait_time = randf_range(1.5, 3)
	movement_timer.start()
	
	if sprite.material_override:
		default_unique_material = sprite.material_override.duplicate()
		sprite.material_override = default_unique_material
	
	set_npc_texture(npc_texture)
	
	DialogueSystemManager.register_npc_data(npc_id, npc_dialogue_data, self)

func set_npc_texture(texture: Texture2D) -> void:
	if texture == null: return
	
	sprite.texture = texture
	
	if default_unique_material:
		default_unique_material.set_shader_parameter("sprite_texture", texture)
	
	if sprite.material_override:
		sprite.material_override.set_shader_parameter("sprite_texture", texture)

#-------------------------------------------------------------------------
# REALIZAR MOVIMENTOS ALEATÓRIOS
#-------------------------------------------------------------------------
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


#-------------------------------------------------------------------------
# VISÃO TÉRMICA
#-------------------------------------------------------------------------
func set_thermal_mode(is_active: bool) -> void:
	if is_active:
		var unique_thermal = THERMAL_NPC_MATERIAL.duplicate()
		unique_thermal.set_shader_parameter("sprite_texture", sprite.texture)
		sprite.material_override = unique_thermal
	else:
		sprite.material_override = default_unique_material

func show_dialog() -> void:
	DialogueSystemManager.show_dialog(npc_dialogue_data, self)


#-------------------------------------------------------------------------
# DIÁLOGO
#-------------------------------------------------------------------------
func set_emotion(emotion: String) -> void:
	var target_texture: Texture2D = npc_texture 
	
	if emotion == Constants.EMOTIONS.Neutral:
		target_texture = npc_texture
	elif npc_dialogue_data:
		var expression_texture = npc_dialogue_data.get(emotion)
		if expression_texture:
			target_texture = expression_texture

	set_npc_texture(target_texture)

#-------------------------------------------------------------------------
# EMITIR DETERMINADO SOM EM INTERVALO DE TEMPO ALEATÓRIO
#-------------------------------------------------------------------------
func _on_random_noise_timer_timeout() -> void:
	for noise in random_noise_data:
		if randf_range(0, 100) <= noise.random_noise_chance:
			play_sound(audio_center, noise.random_noise, true)

	
#-------------------------------------------------------------------------
# É ATIRADO PELO PLAYER
#-------------------------------------------------------------------------
func react_to_being_shot():
	if is_monster:
		transform_to_monster(true)
		return
	queue_free()

#-------------------------------------------------------------------------
# VIRAR MONSTRO
#-------------------------------------------------------------------------
func on_player_is_at_risk():
	transform_to_monster_timer.start()

func _on_transform_to_monster_timer_timeout() -> void:
	transform_to_monster(false)

func transform_to_monster(is_dead: bool = false) -> void:
	if not is_monster or monster_scene == null:
		return
	
	while is_moving or is_turning:
		await get_tree().process_frame
	
	var monster_instance = monster_scene.instantiate()
	
	monster_instance.initialize(
		global_transform, 
		target_position, 
		target_rotation, 
		monster_texture if monster_texture else npc_texture
	)
	
	get_parent().add_child(monster_instance)
	
	if is_dead:
		if monster_instance.has_method("react_to_being_shot"):
			monster_instance.react_to_being_shot()
	
	queue_free()
	

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
	
