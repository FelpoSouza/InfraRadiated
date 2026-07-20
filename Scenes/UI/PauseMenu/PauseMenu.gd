extends Control

const MAIN_MENU_SCENE_PATH = "res://Scenes/UI/MainMenu/MainMenu.tscn"


@onready var save_button: Button = $VBoxContainer/SaveButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready() -> void:
	SignalHub.monster_is_active.connect(on_monster_is_active)
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


func _on_save_button_pressed() -> void:
	SaveLoadManager.save_game()


func _on_quit_button_pressed() -> void:
	SaveLoadManager.save_game()
	ScenesManager.change_scene(MAIN_MENU_SCENE_PATH)


func on_monster_is_active() -> void:
	#save_button.disabled = true
	#quit_button.disabled = true
	pass
