extends Control

const MAIN_MENU: String = "res://Scenes/UI/MainMenu/MainMenu.tscn"

@onready var try_again_button: Button = $ColorRect/VBoxContainer/TryAgainButton
@onready var main_menu_button: Button = $ColorRect/VBoxContainer/MainMenuButton


func _on_try_again_button_pressed() -> void:
	SaveLoadManager.load_game()


func _on_main_menu_button_pressed() -> void:
	ScenesManager.change_scene(MAIN_MENU)
