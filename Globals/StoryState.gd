extends Node

var current_scene: String
var met_npcs = {}


func _ready() -> void:
	add_to_group(Constants.DATA_PERSISTENCE_GROUP_NAME)


func has_met_npc(npc_id: Constants.NPC_IDS):
	return met_npcs.get(str(npc_id), false)
	
func mark_npc_as_met(npc_id):
	met_npcs[str(npc_id)] = true
	

#-------------------------------------------------------------------------
# FUNÇÕES DE PERSISTÊNCIA DE DADOS
#-------------------------------------------------------------------------
func save_to_state(state: Dictionary) -> void:
	state["current_scene"] = get_tree().current_scene.scene_file_path
	state["met_npcs"] = met_npcs
	
func load_from_state(state: Dictionary) -> void:
	met_npcs = state.get("met_npcs", {})
