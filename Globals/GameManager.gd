extends Node

const GAME_WIN = "res://Scenes/UI/GameWin/GameWin.tscn"

var number_of_monsters: int = 0

func increase_monsters_count() -> void:
	number_of_monsters += 1

func decrease_monsters_count() -> void:
	number_of_monsters -= 1
	check_game_win()

func check_game_win():
	if number_of_monsters <= 0:
		ScenesManager.change_scene(GAME_WIN)
