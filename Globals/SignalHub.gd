extends Node

signal player_is_at_risk
signal monster_is_active

func emit_player_is_at_risk():
	player_is_at_risk.emit()

func emit_monster_is_active():
	monster_is_active.emit()
	
