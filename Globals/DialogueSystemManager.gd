extends Node

const default_voice_sfx: AudioStream = preload("res://Assets/SFX/Npc/Voices/Velha/VelhaVoice1.wav")
const default_seconds_per_step: float = 0.02
var npc_dialogue_data_dict: Dictionary[Constants.NPC_IDS, NpcDialogueData] = {}

const DIALOGUE_BALLOON = preload("res://Dialogues/DialogueBalloon/DialogueBalloon.tscn")

var is_dialogue_active: bool = false


## Função usada por NPC.gd para registrar os dados dos diálogos, de forma que fiquem acessíveis nesta classe Global de forma centralizada
func register_npc_data(npc_id: Constants.NPC_IDS, data: NpcDialogueData) -> void:
	if data == null: 
		return
	
	# Só adiciona se não estiver no dicionário
	if not npc_dialogue_data_dict.has(npc_id):
		npc_dialogue_data_dict[npc_id] = data


func show_dialog(data: NpcDialogueData, caller_node: Node) -> void:
	if data == null or data.dialogue_resource == null:
		push_warning("Dialogue Manager tried to start, but no valid data or resource was assigned!")
		return
	
	is_dialogue_active = true
	
	if "is_talking" in caller_node:
		caller_node.is_talking = true
		
	var balloon = DIALOGUE_BALLOON.instantiate()
	get_tree().current_scene.add_child(balloon)
	
	# Hand the balloon the data directly from the resource!
	balloon.start(data.dialogue_resource, data.dialogue_start_node, [caller_node])
	balloon.tree_exited.connect(_on_balloon_closed.bind(caller_node))


func _on_balloon_closed(caller_node: Node) -> void:
	is_dialogue_active = false
	
	if is_instance_valid(caller_node) and "is_talking" in caller_node:
		caller_node.is_talking = false


func get_data_for_id(npc_enum_id: Constants.NPC_IDS) -> NpcDialogueData:
	return npc_dialogue_data_dict.get(npc_enum_id, null)


func get_voice_sfxs_for_character(character_name: String) -> Array[AudioStream]:
	var enum_id = _get_enum_from_string(character_name)
	var data = get_data_for_id(enum_id)
	
	if data == null or data.voice_sfxs.is_empty():
		return [default_voice_sfx]
	return data.voice_sfxs 


func get_seconds_per_step_for_character(character_name: String) -> float:
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
