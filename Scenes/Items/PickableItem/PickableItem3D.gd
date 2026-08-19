extends Interactable
class_name Pickable3D

const TURN_SPEED: float = 6.0
const BOB_HEIGHT: float = 0.25
const BOB_SPEED: float = 2.0

@export var item_data: ItemData

@onready var visual: Node3D = $Visual


func _ready() -> void:
	super._ready()

	if not item_data:
		return

	# Define o nome automaticamente
	if interactable_name.is_empty():
		interactable_name = item_data.item_name

	create_item_model()

	play_animation()


func create_item_model() -> void:
	if not item_data.item_model:
		return

	var model := item_data.item_model.instantiate()

	visual.add_child(model)

	# Aplica o material opcionalmente
	if item_data.item_material:
		apply_material(model)


func apply_material(node: Node) -> void:
	if node is MeshInstance3D:
		node.material_override = item_data.item_material

	for child in node.get_children():
		apply_material(child)


func interact() -> void:
	if not item_data:
		return

	if InventoryManager.add_item(item_data):
		print("Item coletado: %s" % item_data.item_name)
		queue_free()
	else:
		print("Inventário cheio!")


func play_animation() -> void:
	# ROTATION
	var rot_tween := create_tween().set_loops()

	rot_tween.tween_property(
		visual,
		"rotation:y",
		TAU,
		TURN_SPEED
	).as_relative()

	# BOBBING
	var bob_tween := create_tween().set_loops()
	bob_tween.set_trans(Tween.TRANS_SINE)

	var start_y := visual.position.y

	bob_tween.tween_property(
		visual,
		"position:y",
		start_y + BOB_HEIGHT,
		BOB_SPEED
	)

	bob_tween.tween_property(
		visual,
		"position:y",
		start_y,
		BOB_SPEED
	)
