extends Node

const SAVE_PATH = "user://savegame.data"

var met_npcs: Dictionary = {}

func save_game() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(met_npcs)
		file.store_line(json_string)
		file.close()
		print("Game Saved Successfully!")

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_line()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			met_npcs = json.get_data()
			print("Game Loaded Successfully!")
			return true
			
	return false
	
func has_met_npc(npc_id: String):
	return met_npcs.get(npc_id, false)
