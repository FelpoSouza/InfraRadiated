extends Control

const BEGINNING_SCENE_PATH = "res://Scenes/Environment/casa1/Node3d.tscn"
@onready var load_game_button: Button = $VBoxContainer/LoadGameButton
@onready var music_player: AudioStreamPlayer = $MusicPlayer


func _ready() -> void:
	if not SaveLoadManager.game_save_exists():
		load_game_button.disabled = true


func _on_new_game_button_pressed() -> void:	
	SaveLoadManager.start_new_game()


func _on_load_game_button_pressed() -> void:
	var success = SaveLoadManager.load_game()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
