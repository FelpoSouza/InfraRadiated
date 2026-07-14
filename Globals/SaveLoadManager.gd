extends Node

const SAVE_PATH = "user://savegame.data"


func _ready() -> void:
	# Escuta o sinal de quando ScenesManager termina de criar a cena
	ScenesManager.scene_change_completed.connect(_on_level_ready_to_populate)
	
func save_game() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var game_state = capture_game_state()
		
		var json_string = JSON.stringify(game_state)
		file.store_line(json_string)
		file.close()
		print("Game Saved Successfully!")

func load_game(beggining_scene_path: String) -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_line()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var game_state = json.get_data()
			
			var saved_scene = game_state.get("current_scene", beggining_scene_path)
			
			ScenesManager.change_scene_then_load_data(saved_scene, game_state)
			return true
			
	return false

func game_save_exists() -> bool:
	if FileAccess.file_exists(SAVE_PATH):
		return true
	return false

# Acionado depois que o mapa foi completamente carregado para RAM
func _on_level_ready_to_populate(game_state: Dictionary) -> void:
	apply_game_state(game_state) 
	print("Game State Distributed Successfully!")

# Pega dados dos nodes instanciados
func capture_game_state() -> Dictionary:
	var state: Dictionary = {
		"version": 1,
		"data": {}
	}
	
	for node in get_tree().get_nodes_in_group(Constants.DATA_PERSISTENCE_GROUP_NAME):
		if node.has_method("save_to_state"):
			node.save_to_state(state["data"])
			
	return state

# Aplica dados salvos para os nodes instanciados
func apply_game_state(state: Dictionary) -> void:
	var data = state.get("data", {})
	
	for node in get_tree().get_nodes_in_group(Constants.DATA_PERSISTENCE_GROUP_NAME):
		if node.has_method("load_from_state"):
			node.load_from_state(data)
