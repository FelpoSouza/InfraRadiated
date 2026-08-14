extends Area3D

const TURN_SPEED: float = 6.0
const BOB_HEIGHT: float = 0.25
const BOB_SPEED: float = 2.0

@onready var mesh_3d: MeshInstance3D = $MeshInstance3D

@export var item_mesh: Mesh
@export var item_material: Material


func _ready() -> void:
	# Define o Mesh escolhido no Inspector
	if item_mesh:
		mesh_3d.mesh = item_mesh

	# Define o Material escolhido no Inspector
	if item_material:
		mesh_3d.material_override = item_material

	play_animation()


func play_animation() -> void:
	# --- ROTATION ---
	var rot_tween := create_tween().set_loops()

	rot_tween.tween_property(
		mesh_3d,
		"rotation:y",
		TAU,
		TURN_SPEED
	).as_relative()

	# --- BOBBING ---
	var bob_tween := create_tween().set_loops()
	bob_tween.set_trans(Tween.TRANS_SINE)

	var start_y := mesh_3d.position.y

	bob_tween.tween_property(
		mesh_3d,
		"position:y",
		start_y + BOB_HEIGHT,
		BOB_SPEED
	)

	bob_tween.tween_property(
		mesh_3d,
		"position:y",
		start_y,
		BOB_SPEED
	)
