extends Node

# Signal que diz para SaveLoadManager que o mundo está pronto para ter dados inseridos
signal scene_change_completed

var pending_save_data: Dictionary = {}
var is_loading_from_save: bool = false

## Para trocas de cena comuns (por exemplo, passar por uma porta)
func change_scene(target_scene_path: String) -> void:
	is_loading_from_save = false
	_perform_switch(target_scene_path)

## Para trocas de cena com carregamento de dados salvos
func change_scene_then_load_data(target_scene_path: String, save_data: Dictionary) -> void:
	is_loading_from_save = true
	pending_save_data = save_data
	_perform_switch(target_scene_path)

func _perform_switch(path: String) -> void:
	var packed_scene = load(path)
	if not packed_scene:
		push_error("ScenesManager: Could not load scene at path: " + path)
		return
		
	# Manualmente dá free na cena anterior
	if get_tree().current_scene:
		get_tree().current_scene.queue_free()
		
	# Cria uma instância da cena
	var new_scene_instance = packed_scene.instantiate()
	
	# Conecta _on_scene_loaded com a função ready da nova cena. Ou seja, assim que a cena fica pronta, a função _on_scene_loaded é rodada
	new_scene_instance.ready.connect(_on_scene_loaded, CONNECT_ONE_SHOT)
	
	get_tree().root.add_child(new_scene_instance)
	
	get_tree().current_scene = new_scene_instance

func _on_scene_loaded() -> void:
	if is_loading_from_save:
		is_loading_from_save = false
		# Emite o sinal para SaveLoadManager fazer o push dos dados para os nodes
		scene_change_completed.emit(pending_save_data)
		pending_save_data.clear()
