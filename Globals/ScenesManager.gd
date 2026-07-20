extends Node

# --- Sinanis ---
# Sinais da UI de "Carregando..."
signal progress_changed(progress)
signal load_finished
# Save/Load Sinal de Dados
signal scene_change_completed(save_data)

# --- Variáveis da tela de carregamento ---
var loading_screen: PackedScene = preload("res://Scenes/UI/LoadingScreen/LoadingScreen.tscn")
var loaded_resource: PackedScene
var scene_path: String
var progress: Array = []
var use_sub_threads: bool = true

# --- Variáveis de persistência de dados ---
var pending_save_data: Dictionary = {}
var is_loading_from_save: bool = false


func _ready() -> void:
	set_process(false)
	process_mode = Node.PROCESS_MODE_ALWAYS

## Para trocas de cena comuns (por exemplo, passar por uma porta)
func change_scene(target_scene_path: String) -> void:
	is_loading_from_save = false
	_start_async_load(target_scene_path)

## Para trocas de cena com carregamento de dados salvos
func change_scene_then_load_data(target_scene_path: String, save_data: Dictionary) -> void:
	is_loading_from_save = true
	pending_save_data = save_data
	_start_async_load(target_scene_path)

func _start_async_load(_scene_path: String) -> void:
	scene_path = _scene_path
	
	# Instantiate and connect the loading screen UI
	var new_load_screen = loading_screen.instantiate()
	add_child(new_load_screen)
	progress_changed.connect(new_load_screen._on_progress_changed)
	load_finished.connect(new_load_screen._on_load_finished)
	
	await new_load_screen.loading_screen_ready
	
	# Begin the background loading process
	var state = ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)
	else:
		push_error("ScenesManager: Could not start loading scene at path: " + scene_path)

func _process(_delta: float) -> void:
	var load_status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	progress_changed.emit(progress[0])
	
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
			push_error("ScenesManager: Thread load failed for scene at path: " + scene_path)
			
		ResourceLoader.THREAD_LOAD_LOADED:
			set_process(false)
			loaded_resource = ResourceLoader.load_threaded_get(scene_path)
			_perform_switch()

func _perform_switch() -> void:
	# Manualmente dá free na cena anterior
	if get_tree().current_scene:
		get_tree().current_scene.queue_free()
	   
	# Cria uma instância da cena baixada da thread
	var new_scene_instance = loaded_resource.instantiate()
	
	get_tree().root.add_child(new_scene_instance)
	get_tree().current_scene = new_scene_instance
	
	get_tree().paused = false
	print("PAUSED FALSE")
	
	if is_loading_from_save:
		is_loading_from_save = false
		scene_change_completed.emit(pending_save_data)
		pending_save_data.clear()
	
	# Diz para a tela de carregamento sumir/animar fechamento
	load_finished.emit()
