extends Control


const LEVEL_SCENE_NAME = "res://Scenes/Environment/Playground/Playground.tscn"

@onready var load_game_button: Button = $VBoxContainer/LoadGameButton


func _ready() -> void:
	if not FileAccess.file_exists(StoryState.SAVE_PATH):
		load_game_button.disabled = true


func _on_new_game_button_pressed() -> void:
	StoryState.met_npcs.clear()
	
	get_tree().change_scene_to_file(LEVEL_SCENE_NAME)


func _on_load_game_button_pressed() -> void:
	var success = StoryState.load_game()
	
	if success:
		get_tree().change_scene_to_file(LEVEL_SCENE_NAME)
	else:
		push_error("Failed to load save file!")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
