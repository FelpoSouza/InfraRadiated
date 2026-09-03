extends Interactable
class_name Pickable3D

const TURN_SPEED: float = 6.0
const BOB_HEIGHT: float = 0.25
const BOB_SPEED: float = 2.0

@export var item_data: ItemData

var is_collected: bool = false

@onready var visual: Node3D = $Visual


func _ready() -> void:
	super._ready()

	add_to_group(Constants.DATA_PERSISTENCE_GROUP_NAME)
	
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
		is_collected = true
		
		# Em vez de queue_free(), vira um nó fantasma
		# Ele continua na árvore para salvar seu estado depois
		hide()
		process_mode = Node.PROCESS_MODE_DISABLED
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

#-------------------------------------------------------------------------
# FUNÇÕES DE PERSISTÊNCIA DE DADOS
#-------------------------------------------------------------------------
func save_to_state(state: Dictionary) -> void:
	var data_dict: Dictionary = {}
	data_dict["is_collected"] = is_collected
	
	# Usa o caminho exato do nó na cena como uma chave única.
	var unique_id = str(get_path())
	
	# Pega o dicionário existente (se existir), ou cria um novo se for o primeiro item.
	var pickable_dict: Dictionary = state.get("PickableItems3D", {})
	
	# Adiciona este item específico ao dicionário de Pickables
	pickable_dict[unique_id] = data_dict
	
	# Salva de volta no estado global
	state["PickableItems3D"] = pickable_dict

func load_from_state(state: Dictionary) -> void:
	var unique_id = str(get_path())
	
	# Se a categoria PickableItems3D não existir, não faz nada
	if not state.has("PickableItems3D"):
		return
		
	var data_dict = state["PickableItems3D"].get(unique_id, {})
	is_collected = data_dict.get("is_collected", false)
	
	# Se carregar o jogo e ele já tiver sido coletado, vira fantasma
	if is_collected:
		hide()
		process_mode = Node.PROCESS_MODE_DISABLED
	
