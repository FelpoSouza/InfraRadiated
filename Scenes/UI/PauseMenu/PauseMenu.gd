extends Control

const MAIN_MENU_SCENE_PATH = "res://Scenes/UI/MainMenu/MainMenu.tscn"

func _ready() -> void:
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()


func toggle_pause() -> void:
	var is_paused = get_tree().paused
	
	if is_paused:
		resume_game()
	else:
		pause_game()


func pause_game() -> void:
	if DialogueSystemManager.is_dialogue_active:
		return
	get_tree().paused = true
	show()


func resume_game() -> void:
	get_tree().paused = false
	hide()


func _on_resume_button_pressed() -> void:
	resume_game()


func _on_quit_button_pressed() -> void:
	SaveLoadManager.save_game()
	
	# Despausa antes the trocar de cena, senão o Menu Principal fica congelado
	get_tree().paused = false
	
	ScenesManager.change_scene(MAIN_MENU_SCENE_PATH)
