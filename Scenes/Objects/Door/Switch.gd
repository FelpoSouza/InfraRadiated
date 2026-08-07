extends StaticBody3D

signal switch_toggled

func interact()->void:
	switch_toggled.emit()
