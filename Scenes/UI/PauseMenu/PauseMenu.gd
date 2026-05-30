extends Control

const MAIN_MENU_SCENE_NAME = "res://Scenes/UI/MainMenu/MainMenu.tscn"

func _ready() -> void:
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()


func toggle_pause() -> void:
	var is_paused = get_tree().paused
	
	if is_paused:
		print("Was Paused")
		resume_game()
	else:
		print("Wasn't Paused")
		pause_game()


func pause_game() -> void:
	get_tree().paused = true
	show()


func resume_game() -> void:
	get_tree().paused = false
	hide()


func _on_resume_button_pressed() -> void:
	resume_game()


func _on_quit_button_pressed() -> void:
	# Despausa antes the trocar de cena, senão o Menu Principal fica congelado
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_NAME)
