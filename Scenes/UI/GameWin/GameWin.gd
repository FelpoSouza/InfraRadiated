extends Control

const MAIN_MENU: String = "res://Scenes/UI/MainMenu/MainMenu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_main_menu_button_pressed() -> void:
	ScenesManager.change_scene(MAIN_MENU)
