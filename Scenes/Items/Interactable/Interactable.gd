@tool # 1. This tells Godot to run this script inside the editor
class_name Interactable
extends Area3D

@export var interactable_name: String
@export var interact_action: String = "para coletar"

@export var mesh: Mesh:
	set(value):
		mesh = value
		var mesh_node = get_node_or_null("MeshInstance3D")
		if mesh_node:
			mesh_node.mesh = mesh

var interact_message: String

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	if mesh_instance_3d:
		mesh_instance_3d.mesh = mesh
		
	if Engine.is_editor_hint():
		return
		
	interact_message = interact_action + " '" + interactable_name + "'"

func interact() -> void:
	print("This is interactable %s" % interactable_name)
