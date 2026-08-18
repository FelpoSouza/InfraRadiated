@tool # roda no proprio editor
class_name Interactable
extends Area3D

@export var interactable_name: String
@export var interact_action: String = "para interagir"

var interact_message: String

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	interact_message = interact_action + " '" + interactable_name + "'"


func interact() -> void:
	print("Interagindo com %s" % interactable_name)
