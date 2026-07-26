extends Node3D

const TURN_SPEED: float = 6.0
const BOB_HEIGHT: float = 0.25
const BOB_SPEED: float = 2

@onready var sprite_3d: Sprite3D = $Sprite3D

@export var item_texture: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if item_texture:
		sprite_3d.texture = item_texture
	play_animation()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func play_animation() -> void:
	# --- ROTATION TWEEN ---
	var rot_tween = create_tween().set_loops()
	rot_tween.tween_property(sprite_3d, "rotation:y", TAU, TURN_SPEED).as_relative()


	# --- BOBBING (UP AND DOWN) TWEEN ---
	var bob_tween = create_tween().set_loops()
	bob_tween.set_trans(Tween.TRANS_SINE)

	var start_y = sprite_3d.position.y

	bob_tween.tween_property(sprite_3d, "position:y", start_y + BOB_HEIGHT, BOB_SPEED)
	bob_tween.tween_property(sprite_3d, "position:y", start_y, BOB_SPEED)
