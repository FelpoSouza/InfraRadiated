extends Node

const SAVE_PATH = "user://savegame.data"
const BEGINNING_SCENE_PATH = "res://Scenes/Environment/casa1/Node3d.tscn"

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
			var game_state = json.get_data()
			
			var saved_scene = game_state.get("current_scene", BEGINNING_SCENE_PATH)
			
			ScenesManager.change_scene_then_load_data(saved_scene, true, game_state)
			return true
			
	return false

func start_new_game() -> void:	
	StoryState.reset_state()
	var game_state = capture_game_state()
	ScenesManager.change_scene_then_load_data(BEGINNING_SCENE_PATH, false, game_state)

func game_save_exists() -> bool:
	if FileAccess.file_exists(SAVE_PATH):
		return true
	return false

# Acionado depois que o mapa foi completamente carregado para RAM
func _on_level_ready_to_populate(should_save_game: bool, is_loading_from_save: bool, game_state: Dictionary) -> void:
	if is_loading_from_save:
		apply_game_state(game_state)
		print("Game State Distributed Successfully!")
	
	if should_save_game:
		save_game()
		print("Game Successfully Saved After Scene Transition!")

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
	var dynamic_entities = data.get("dynamic_entities", {})
	
	for node in get_tree().get_nodes_in_group(Constants.DATA_PERSISTENCE_GROUP_NAME):
		if node.has_method("load_from_state"):
			node.load_from_state(data)
			
	for entity_name in dynamic_entities.keys():
		var entity_data = dynamic_entities[entity_name]
		var scene_path = entity_data.get("scene_filepath", "")
		
		
		if scene_path != "":
			var packed_scene = load(scene_path)
			if packed_scene:
				var new_entity = packed_scene.instantiate()
				new_entity.name = entity_name
				
				get_tree().current_scene.add_child(new_entity)
				
				if new_entity.has_method("load_from_state"):
					new_entity.load_from_state(entity_data)
