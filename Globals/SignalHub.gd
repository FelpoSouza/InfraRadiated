extends Node

signal player_is_at_risk

func emit_player_is_at_risk():
	player_is_at_risk.emit()
