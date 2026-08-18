
extends Interactable
class_name Pickable3D

const TURN_SPEED: float = 6.0
const BOB_HEIGHT: float = 0.25
const BOB_SPEED: float = 2.0

@export var item_data: ItemData

@onready var mesh_3d: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	super._ready()

	if item_data:
		# Define o nome do Interactable automaticamente
		if interactable_name.is_empty():
			interactable_name = item_data.item_name
		# Define o Mesh
		if item_data.item_mesh:
			mesh_3d.mesh = item_data.item_mesh
		# Define o Material específico do item
		if item_data.item_material:
			mesh_3d.material_override = item_data.item_material

	play_animation()


func interact() -> void:
	if not item_data:
		return
	if InventoryManager.add_item(item_data):
		queue_free()
	else:
		print("Inventário cheio!")


func play_animation() -> void:
	# ROTATION
	var rot_tween := create_tween().set_loops()
	rot_tween.tween_property(mesh_3d, "rotation:y", TAU, TURN_SPEED).as_relative()

	# BOBBING
	var bob_tween := create_tween().set_loops()
	bob_tween.set_trans(Tween.TRANS_SINE)

	var start_y := mesh_3d.position.y

	bob_tween.tween_property(mesh_3d, "position:y", start_y + BOB_HEIGHT, BOB_SPEED)

	bob_tween.tween_property(mesh_3d, "position:y", start_y, BOB_SPEED)
