extends BaseCharacter

enum PeekingDirections { NONE, LEFT, RIGHT, UP, DOWN }

const GAME_OVER = "res://Scenes/UI/GameOver/GameOver.tscn"

const thermal_vision_on_battery_decay = 0.2
const thermal_vision_off_battery_decay = 0.04

var peek_distance: float = 1.5
var peek_duration: float = 0.1
var camera_offset: Vector3 = Vector3.ZERO
var thermal_vision_battery: float = 35.0
var ammo_amount: int = 1
var camera_basis_before_dialogue: Basis
var is_camera_locked_on_npc: bool = false

var current_peeking: PeekingDirections = PeekingDirections.NONE
var is_thermal_vision_on: bool = false
var is_facing_npc: bool = false
var is_facing_interactable: bool = false
var is_gun_active: bool = false

var interactables: Array[Area3D]
var selected_interactable_index: int = -1
var interact_key_text: String
var next_interactable_key_text: String

@onready var camera: Camera3D = $CanvasLayer/SubViewportContainer/SubViewport/Camera3D
@onready var shader_container: SubViewportContainer = $CanvasLayer/SubViewportContainer
@onready var forward_ray_for_areas: RayCast3D = $ForwardRayForAreas
@onready var forward_ray_for_interact: RayCast3D = $ForwardRayForInteract
@onready var area_for_interactable_up: Area3D = $AreaForInteractableUp
@onready var area_for_interactable_none: Area3D = $AreaForInteractableNone
@onready var area_for_interactable_down: Area3D = $AreaForInteractableDown
@onready var pause_menu: Control = $CanvasLayer/PauseMenu
@onready var gun: Node3D = $CanvasLayer/SubViewportContainer/SubViewport/Camera3D/Gun

@onready var crosshair: ColorRect = $CanvasLayer/UserInterface/Crosshair
@onready var thermal_battery_label: Label = $CanvasLayer/UserInterface/ThermalBatteryLabel
@onready var ammo_label: Label = $CanvasLayer/UserInterface/AmmoHBoxContainer/AmmoLabel
@onready var interact_label: Label = $CanvasLayer/UserInterface/InteractLabel
@onready var next_interactable_label: Label = $CanvasLayer/UserInterface/NextInteractableLabel

#func click(): # comentado pois pode ser útil
#	if event is InputEventMouseButton and event.is_pressed():
#   	var viewport = camera.get_viewport()
#		var click_position = viewport.get_mouse_position()
#		if click_position.x < =ajuste aqui para definir pos=: #removível no nosso caso...
#			var space_state = camera.get_world_3d().direct_space_state
#			var ray_origin = camera.project_ray_origin(click_position)
#			var ray_end = ray_origin + camera.project_ray_normal(click_position) * 2.0
#			var query = PhysicsRayQueryParameter3D.create(ray_origin, ray_end)
#			var result = space_state.intersect_ray(query)
#			if result:
#				var object = result.collider
#				if object.has_method("click_on"):
#					object.clicked_on()

func _ready() -> void:
	super._ready()
	add_to_group(Constants.PLAYER_GROUP_NAME)
	add_to_group(Constants.DATA_PERSISTENCE_GROUP_NAME)
	
	ammo_label.text = "%d" % ammo_amount
	
	camera.global_transform = global_transform
	
	interact_key_text = get_action_key_text("interact")
	next_interactable_key_text = get_action_key_text("next_interactable")
	
	
func _process(_delta: float) -> void:
	super._process(_delta)
	var smoothing_factor = 1.0 - exp(-15.0 * _delta)
	camera.global_position = camera.global_position.lerp(global_position + camera_offset, smoothing_factor)
	
	if not is_camera_locked_on_npc:
		camera.rotation.y = rotation.y
	
	check_crosshair_interaction()
	check_available_interactions()
	
	decrease_thermal_vision_battery(_delta)
	
#-------------------------------------------------------------------------
# INTERAÇÃO
#-------------------------------------------------------------------------
func check_crosshair_interaction() -> void:
	if forward_ray_for_areas.is_colliding():
		var target = forward_ray_for_areas.get_collider()
		
		if target and target.is_in_group(Constants.NPC_GROUP_NAME): 
			#crosshair.color = Color(0.91, 0.766, 0.0, 1.0)
			crosshair.color = Color(0.0, 0.922, 0.0, 1.0)
			is_facing_npc = true
			return
	
	is_facing_npc = false
	
	#if forward_ray_for_interact.is_colliding():
		#var target = forward_ray_for_interact.get_collider()
		#
		#if target and target.is_in_group(Constants.INTERACTABLE_GROUP_NAME ): 
			#crosshair.color = Color(0.91, 0.766, 0.0, 1.0)
			#is_facing_interactable = true
			#return
	
	crosshair.color = Color(1.0, 1.0, 1.0)

func item_interaction(item_type: ItemData.ItemType) -> int:
	if item_type == ItemData.ItemType.FREE_USE:
		if InventoryManager.use_selected_item():
			return 1 # retorna de imediato se item usado com sucesso 
	#EXPANDIR
	# Retorna 1 se NPC_USE, então no NPC use InventoryManager.use_selected_item()		
	# Retorne 2 para uso em objeto		
	return 0

func look_at_npc_face(npc_node: Node3D) -> void:
	var target_pos: Vector3 = npc_node.global_position
	var head_marker = npc_node.get_node_or_null("HeadMarker3D")
	
	if head_marker:
		# Pega aonde o NPC vai estar no mapa e soma com a altura da cabeça dele.
		# Não usa head_marker.global_position porque o player pode iniciar uma conversa quando o NPC está se movendo. Se usar head_marker.global_position, a câmera olhará 
		target_pos = Vector3(
			npc_node.target_position.x, 
			head_marker.global_position.y, 
			npc_node.target_position.z
		)
	
	var target_transform = camera.global_transform.looking_at(target_pos, Vector3.UP)
	
	var tween = create_tween()
	tween.tween_property(camera, "global_transform:basis", target_transform.basis, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)	

func try_talk_to_npc() -> void:
	if forward_ray_for_areas.is_colliding():
		var target = forward_ray_for_areas.get_collider()
		
		if target.is_in_group(Constants.NPC_GROUP_NAME) and target.has_method("show_dialog"):
			var forward_dir: Vector3 = -camera.global_transform.basis.z
			forward_dir.y = 0.0
			forward_dir = forward_dir.normalized()
			
			camera_basis_before_dialogue = Basis.looking_at(forward_dir, Vector3.UP)
			
			is_camera_locked_on_npc = true
			
			look_at_npc_face(target)
			target.show_dialog()

func on_balloon_closed() -> void:
	var tween = create_tween()
	tween.tween_property(camera, "global_transform:basis", camera_basis_before_dialogue, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.tween_callback(func(): is_camera_locked_on_npc = false)
	
#----------------------------------------
# INTERAÇÃO GERAL 
#----------------------------------------	
func try_interact():
	#var object = forward_ray_for_interact.get_collider() #esse raio tambem rastreia InterPoints
	#
	#if object != null:
		#print_debug("colisao com objeto")
	#else:
		#print_debug("sem colidir!")
	#if object:
		#if object.has_method("interact"):
			#object.interact()
	
	if interactables.size() > 0 and selected_interactable_index >= 0 and selected_interactable_index < interactables.size():
		var target = interactables[selected_interactable_index]
		if target.has_method("interact"):
			target.interact()

func check_available_interactions() -> void:
	if is_facing_npc:
		interact_label.visible = false
		next_interactable_label.visible = false
		return
	
	var current_area_for_interactable: Area3D
	if current_peeking == PeekingDirections.UP:
		current_area_for_interactable = area_for_interactable_up
	elif current_peeking == PeekingDirections.DOWN: 
		current_area_for_interactable = area_for_interactable_down
	else:
		current_area_for_interactable = area_for_interactable_none
	
	var raw_interactables = current_area_for_interactable.get_overlapping_areas()
	
	interactables = raw_interactables.filter(has_line_of_sight)
	
	if interactables.size() > 0:
		if selected_interactable_index < 0 or selected_interactable_index >= interactables.size():
			selected_interactable_index = 0
			
		if interactables[selected_interactable_index].interact_message:
			interact_label.text = "Pressione '%s' %s" % [get_action_key_text("interact"), interactables[selected_interactable_index].interact_message]
		else:
			interact_label.text = "Pressione '%s' para interagir" % get_action_key_text("interact")
		interact_label.visible = true
		
		if interactables.size() > 1:
			if interactables[(selected_interactable_index+1)%interactables.size()].interactable_name:
				next_interactable_label.text = "('%s' para selecionar '%s')" % [get_action_key_text("next_interactable"), interactables[(selected_interactable_index+1)%interactables.size()].interactable_name]
			else:
				next_interactable_label.text = "('%s' para selecionar o próximo interagível)" % get_action_key_text("next_interactable")
			next_interactable_label.visible = true
	else:
		interact_label.visible = false
		next_interactable_label.visible = false

func has_line_of_sight(target_area: Area3D) -> bool:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(camera.global_position, target_area.global_position)
	
	query.collision_mask = 1
	query.exclude = [self.get_rid(), target_area.get_rid()]
	var result = space_state.intersect_ray(query)
	
	return result.is_empty()


#-------------------------------------------------------------------------
# INPUT
#-------------------------------------------------------------------------
func _unhandled_input(event: InputEvent) -> void:
	if is_moving or is_turning: return
	
	var is_shifting = Input.is_action_pressed("modifier")
	
	if interactables.size() > 1 and event.is_action_pressed("next_interactable"):
			selected_interactable_index = (selected_interactable_index + 1) % interactables.size()
			
	elif event.is_action_pressed("interact"):
		var item_code = -1
		if InventoryManager.selected_index >= 0 and InventoryManager.selected_index < InventoryManager.items.size():
			item_code = item_interaction(InventoryManager.items[InventoryManager.selected_index].item_type)
		if item_code == 1:
			return	# Uso de consumivel
		if is_facing_npc and not DialogueSystemManager.is_dialogue_active:
			try_talk_to_npc()
		else:
			try_interact()
	
	if event.is_action_pressed("fire_gun") and is_gun_active:
		fire_gun()
		
	if is_shifting:
		if event.is_action_pressed("heatvision"):
			toggle_thermal_vision()
		elif event.is_action_pressed("gun"):
			toggle_gun()
		elif event.is_action_pressed("peek_down"):
			peek_down()
		elif event.is_action_pressed("peek_up"):
			peek_up()
		elif event.is_action_pressed("peek_left"):
			peek_left()
		elif event.is_action_pressed("peek_right"):
			peek_right()
			
	else:
		if event.is_action_pressed("move_forward"):
			try_move_forward()
		elif event.is_action_pressed("move_backward"):
			try_move_backward()
		elif event.is_action_pressed("move_left"):
			try_move_left()
		elif event.is_action_pressed("move_right"):
			try_move_right()
		elif event.is_action_pressed("turn_left"):
			turn_left()
		elif event.is_action_pressed("turn_right"):
			turn_right()
		
		
	
	if current_peeking != PeekingDirections.NONE:
		if ((current_peeking == PeekingDirections.DOWN and event.is_action_released("peek_down")) or 
			(current_peeking == PeekingDirections.UP and event.is_action_released("peek_up")) or 
			(current_peeking == PeekingDirections.LEFT and event.is_action_released("peek_left")) or 
			(current_peeking == PeekingDirections.RIGHT and event.is_action_released("peek_right")) or 
			event.is_action_released("modifier")):
				peek_forward()


#-------------------------------------------------------------------------
# PEEKING
#-------------------------------------------------------------------------
func perform_peek(target_rot_x: float, target_rot_z: float, offset: Vector3 = Vector3.ZERO) -> void:
	is_moving = true
	camera_offset = offset
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(camera, "rotation:x", target_rot_x, peek_duration)
	tween.tween_property(camera, "rotation:z", target_rot_z, peek_duration)
	tween.chain().tween_callback(func(): is_moving = false)
	
	interactables = []
	selected_interactable_index = -1
	interact_label.visible = false
	next_interactable_label.visible = false

func peek_down() -> void:
	if current_peeking != PeekingDirections.DOWN:
		current_peeking = PeekingDirections.DOWN
		perform_peek(-PI/6.0, 0.0)

func peek_up() -> void:
	if current_peeking != PeekingDirections.UP:
		current_peeking = PeekingDirections.UP
		perform_peek(PI/6.0, 0.0)

func peek_right() -> void:
	right_ray.force_raycast_update()
	if not right_ray.is_colliding() and current_peeking != PeekingDirections.RIGHT:
		current_peeking = PeekingDirections.RIGHT
		perform_peek(0.0, -PI/6.0, transform.basis.x.normalized() * peek_distance)

func peek_left() -> void:
	left_ray.force_raycast_update()
	if not left_ray.is_colliding() and current_peeking != PeekingDirections.LEFT:
		current_peeking = PeekingDirections.LEFT
		perform_peek(0.0, PI/6.0, -transform.basis.x.normalized() * peek_distance)

func peek_forward() -> void:
	perform_peek(0.0, 0.0, Vector3.ZERO)
	current_peeking = PeekingDirections.NONE

#-------------------------------------------------------------------------
# VISÃO TÉRMICA
#-------------------------------------------------------------------------
func toggle_thermal_vision() -> void:
	is_thermal_vision_on = not is_thermal_vision_on
	if thermal_vision_battery <= 0.0:
		is_thermal_vision_on = false
	shader_container.material.set_shader_parameter("thermal_vision", is_thermal_vision_on)
	get_tree().call_group(Constants.NPC_GROUP_NAME, "set_thermal_mode", is_thermal_vision_on)
	
	if is_thermal_vision_on:
		thermal_battery_label.show()
	else:
		thermal_battery_label.hide()

func decrease_thermal_vision_battery(delta: float) -> void:
	if thermal_vision_battery > 0.0:
		if is_thermal_vision_on:
			thermal_vision_battery -= thermal_vision_on_battery_decay * delta
		else:
			thermal_vision_battery -= thermal_vision_off_battery_decay * delta
		
		thermal_vision_battery = max(0.0, thermal_vision_battery)
		
		if thermal_vision_battery <= 0.0:
			if is_thermal_vision_on:
				toggle_thermal_vision()
			SignalHub.emit_player_is_at_risk()
	
	thermal_battery_label.text = "%.1f %%" % thermal_vision_battery

#-------------------------------------------------------------------------
# DETEÇÃO DE MORTE
#-------------------------------------------------------------------------
func _on_area_for_death_entered(area: Area3D) -> void:
	if area.is_in_group(Constants.MONSTER_GROUP_NAME):
		DialogueSystemManager.force_close_dialog()
		ScenesManager.change_scene(GAME_OVER)
		queue_free()

#-------------------------------------------------------------------------
# ARMA
#-------------------------------------------------------------------------
func toggle_gun() -> void:
	is_gun_active = !is_gun_active
	if is_gun_active:
		gun.show()
	else:
		gun.hide()
	
func fire_gun() -> void:
	if ammo_amount <= 0:
		return
	
	gun.shoot()
	ammo_amount -= 1
	ammo_label.text = "%d" % ammo_amount
	
	if ammo_amount <= 0:
		SignalHub.emit_player_is_at_risk()

#-------------------------------------------------------------------------
# FUNÇÕES DE PERSISTÊNCIA DE DADOS
#-------------------------------------------------------------------------
func save_to_state(state: Dictionary) -> void:
	var player_state: Dictionary = get_base_character_dict()
	
	player_state["thermal_battery"] = thermal_vision_battery
	player_state["thermal_on"] = is_thermal_vision_on
	player_state["ammo_amount"] = ammo_amount
	player_state["is_gun_active"] = is_gun_active
	
	state["Player"] = player_state
	
func load_from_state(state: Dictionary) -> void:
	var player_state: Dictionary = state.get("Player", {})
	set_attributes_from_dict(player_state)
	
	thermal_vision_battery = player_state.get("thermal_battery", 100.0)
	is_thermal_vision_on = player_state.get("thermal_on", false)
	
	if is_thermal_vision_on:
		thermal_battery_label.show()
	else:
		thermal_battery_label.hide()
		
	shader_container.material.set_shader_parameter("thermal_vision", is_thermal_vision_on)
	get_tree().call_group(Constants.NPC_GROUP_NAME, "set_thermal_mode", is_thermal_vision_on)
	
	ammo_amount = player_state.get("ammo_amount", 1)
	is_gun_active = player_state.get("is_gun_active", false)
	gun.visible = is_gun_active
	ammo_label.text = "%d" % ammo_amount
	thermal_battery_label.visible = is_thermal_vision_on
	
	camera.global_position = global_position

#-------------------------------------------------------------------------
# MISCELÂNEA
#-------------------------------------------------------------------------
func get_action_key_text(action_name: String) -> String:
	var events = InputMap.action_get_events(action_name)
	
	for event in events:
		if event is InputEventKey:
			return event.as_text().split(" ")[0]
			
	return "No Key Bound"
