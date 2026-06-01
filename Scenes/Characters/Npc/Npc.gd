extends BaseCharacter

@export var npc_texture: Texture2D
@export var npc_id: Constants.NPC_IDS
@export var npc_dialogue_data: NpcDialogueData

const THERMAL_NPC_MATERIAL = preload("res://Materials/Thermal/ThermalNPCMaterial.tres")

var npc_name: String = Constants.NPC_IDS.keys()[npc_id]
var is_player_near: bool = false
var is_talking: bool = false

var default_unique_material: Material

@onready var sprite: Sprite3D = $Sprite3D

func _ready() -> void:
	add_to_group(Constants.NPC_GROUP_NAME)
	
	target_position = global_position
	is_moving = false
	
	if npc_texture != null:
		sprite.texture = npc_texture
		
		default_unique_material = sprite.material_override.duplicate()
		default_unique_material.set_shader_parameter("sprite_texture", sprite.texture)
		sprite.material_override = default_unique_material
	
	DialogueSystemManager.register_npc_data(npc_id, npc_dialogue_data)

func pick_random_movement():
	return [
		self.try_move_forward,
		self.try_move_backward,
		self.try_move_left,
		self.try_move_right
	].pick_random()

func _on_movement_timer_timeout() -> void:
	if is_talking:
		return
		
	var random_movement: Callable = pick_random_movement()
	
	while not random_movement.call():
		random_movement = pick_random_movement()

func set_thermal_mode(is_active: bool) -> void:
	if is_active:
		var unique_thermal = THERMAL_NPC_MATERIAL.duplicate()
		unique_thermal.set_shader_parameter("sprite_texture", sprite.texture)
		sprite.material_override = unique_thermal
	else:
		sprite.material_override = default_unique_material

func show_dialog() -> void:
	DialogueSystemManager.show_dialog(npc_dialogue_data, self)
