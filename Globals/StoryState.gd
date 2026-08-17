extends Node

var is_new_game: bool
var current_scene: String
var met_npcs = {}
var dialogue_conditions = {
	"dad_lore": false
}


func _ready() -> void:
	add_to_group(Constants.DATA_PERSISTENCE_GROUP_NAME)

func reset_state() -> void:
	is_new_game = true
	met_npcs.clear()
	dialogue_conditions = {
		"dad_lore": false
	}


func has_met_npc(npc_id: Constants.NPC_IDS):
	return met_npcs.get(str(npc_id), false)
	
func mark_npc_as_met(npc_id):
	met_npcs[str(npc_id)] = true


func unlock_dialogue_condition(condition: String, value: bool = true):
	dialogue_conditions.set(condition, value)
	print(get_dialogue_condition(condition))

func get_dialogue_condition(condition: String):
	return dialogue_conditions.get(condition, false)

#-------------------------------------------------------------------------
# FUNÇÕES DE PERSISTÊNCIA DE DADOS
#-------------------------------------------------------------------------
func save_to_state(state: Dictionary) -> void:
	state["is_new_game"] = is_new_game
	state["current_scene"] = get_tree().current_scene.scene_file_path
	state["met_npcs"] = met_npcs
	state["dialogue_conditions"] = dialogue_conditions
	
func load_from_state(state: Dictionary) -> void:
	is_new_game = state.get("is_new_game", true)
	met_npcs = state.get("met_npcs", {})
	dialogue_conditions = state.get("dialogue_conditions", {
		"dad_lore_unlocked": false
	})
