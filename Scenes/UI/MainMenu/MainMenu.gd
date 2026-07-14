extends Control


const BEGINNING_SCENE_PATH = "res://Scenes/Environment/Playground/Playground.tscn"

@onready var load_game_button: Button = $VBoxContainer/LoadGameButton


func _ready() -> void:
	if not SaveLoadManager.game_save_exists():
		load_game_button.disabled = true


func _on_new_game_button_pressed() -> void:	
	get_tree().change_scene_to_file(BEGINNING_SCENE_PATH)


func _on_load_game_button_pressed() -> void:
	var success = SaveLoadManager.load_game(BEGINNING_SCENE_PATH)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
