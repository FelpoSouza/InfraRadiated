extends BaseCharacter

@export var npc_texture: Texture2D

const THERMAL_NPC_MATERIAL = preload("res://Materials/Thermal/ThermalNPCMaterial.tres")

@onready var sprite: Sprite3D = $Sprite3D

func _ready() -> void:
	add_to_group("NPCs")
	
	target_position = global_position
	is_moving = false
	
	if npc_texture != null:
		sprite.texture = npc_texture
		var mat = sprite.material_override
		mat.set_shader_parameter("sprite_texture", sprite.texture)

func pick_random_movement():
	return [
		self.try_move_forward,
		self.try_move_backward,
		self.try_move_left,
		self.try_move_right
	].pick_random()

func _on_movement_timer_timeout() -> void:
	var random_movement: Callable = pick_random_movement()
	
	while not random_movement.call():
		random_movement = pick_random_movement()

func set_thermal_mode(is_active: bool) -> void:
	if is_active:
		var current_tex = sprite.texture
		THERMAL_NPC_MATERIAL.set_shader_parameter("sprite_texture", current_tex)
		sprite.material_override = THERMAL_NPC_MATERIAL
	else:
		sprite.material_override = null
