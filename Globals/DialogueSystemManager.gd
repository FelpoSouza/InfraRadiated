extends Node

const default_voice_sfx: AudioStream = preload("res://Assets/SFX/Character/Voices/PlayerVoice1.wav")
const default_seconds_per_step: float = 0.05
const player_voice_sfx: Array[AudioStream] = [
	preload("res://Assets/SFX/Character/Voices/PlayerVoice1.wav"),
	preload("res://Assets/SFX/Character/Voices/PlayerVoice2.wav"),
	preload("res://Assets/SFX/Character/Voices/PlayerVoice3.wav"),
	preload("res://Assets/SFX/Character/Voices/PlayerVoice4.wav"),
]
const player_seconds_per_step: float = 0.05
const DIALOGUE_BALLOON = preload("res://Dialogues/DialogueBalloon/DialogueBalloon.tscn")

var npc_dialogue_data_dict: Dictionary[Constants.NPC_IDS, NpcDialogueData] = {}
var active_npc_nodes: Dictionary = {}
var balloon = null

var is_dialogue_active: bool = false
var dialogue_caller_node: Node = null


## Função usada por NPC.gd para registrar os dados dos diálogos, de forma que fiquem acessíveis nesta classe Global de forma centralizada
func register_npc_data(npc_id: Constants.NPC_IDS, data: NpcDialogueData, npc_node: Node) -> void:
	if data == null: 
		return
	
	# Só adiciona se não estiver no dicionário
	if not npc_dialogue_data_dict.has(npc_id):
		npc_dialogue_data_dict[npc_id] = data
	
	var string_name = Constants.NPC_IDS.keys()[npc_id]
	active_npc_nodes[string_name.to_lower()] = npc_node


func show_dialog(data: NpcDialogueData, caller_node: Node) -> void:
	if data == null or data.dialogue_resource == null:
		push_warning("Dialogue Manager tried to start, but no valid data or resource was assigned!")
		return
		
	is_dialogue_active = true
	dialogue_caller_node = caller_node
	
	if "is_talking" in dialogue_caller_node:
		dialogue_caller_node.is_talking = true
		
	balloon = DIALOGUE_BALLOON.instantiate()
	get_tree().current_scene.add_child(balloon)
	
	balloon.start(data.dialogue_resource, data.dialogue_start_node, [dialogue_caller_node])
	balloon.tree_exited.connect(_on_balloon_closed) 


func force_close_dialog():
	if is_instance_valid(balloon):
		balloon.queue_free()


func force_close_especific_npc_dialog(caller_node: Node):
	if is_instance_valid(balloon) and caller_node == dialogue_caller_node:
		balloon.queue_free()


func _on_balloon_closed() -> void:
	balloon = null
	is_dialogue_active = false
	
	# Salva temporariamente quem chamou o diálogo antes de apagar
	var original_caller = dialogue_caller_node
	dialogue_caller_node = null
	
	if is_instance_valid(original_caller):
		if "is_talking" in original_caller:
			original_caller.is_talking = false
			
		if "movement_timer" in original_caller:
			original_caller.movement_timer.wait_time = randf_range(1.5, 3.0)
			original_caller.movement_timer.start()
			
		if original_caller.has_method("set_npc_texture") and "npc_texture" in original_caller:
			original_caller.set_npc_texture(original_caller.npc_texture)
		
		# Fecha o diálogo do player se ele que chamou
		if original_caller.is_in_group(Constants.PLAYER_GROUP_NAME) and original_caller.has_method("on_balloon_closed"):
			original_caller.on_balloon_closed()
		else:
			# Fecha o diálogo do player caso o diálogo tenha sido chamado de outro lugar
			var player_ref = get_tree().get_first_node_in_group(Constants.PLAYER_GROUP_NAME)
			if player_ref and player_ref.has_method("on_balloon_closed"):
				player_ref.on_balloon_closed()


func get_data_for_id(npc_enum_id: Constants.NPC_IDS) -> NpcDialogueData:
	return npc_dialogue_data_dict.get(npc_enum_id, null)


func get_voice_sfxs_for_character(character_name: String) -> Array[AudioStream]:
	if character_name == Constants.PLAYER_NAME and player_voice_sfx:
		return player_voice_sfx
	
	var enum_id = _get_enum_from_string(character_name)
	var data = get_data_for_id(enum_id)
	
	if data == null or data.voice_sfxs.is_empty():
		return [default_voice_sfx]
	return data.voice_sfxs 


func get_seconds_per_step_for_character(character_name: String) -> float:
	if character_name == Constants.PLAYER_NAME:
		return player_seconds_per_step
	
	var enum_id = _get_enum_from_string(character_name)
	var data = get_data_for_id(enum_id)
	
	if data == null:
		return default_seconds_per_step
	return data.seconds_per_step 


func _get_enum_from_string(character_name: String) -> int:
	for key in Constants.NPC_IDS.keys():
		if key.to_lower() == character_name.to_lower():
			return Constants.NPC_IDS[key]
	return -1


func set_npc_emotion(npc_name: String, emotion: String) -> void:
	var selected_npc = active_npc_nodes.get(npc_name.to_lower(), null)
	if selected_npc:
		selected_npc.set_emotion(emotion)
	
