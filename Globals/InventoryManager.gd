extends Node

signal inventory_changed
signal selection_changed
signal inventory_full

# talvez uma mochila mais para frente que adiciona espaço?
var MAX_ITEMS : int = 5

var items: Array[ItemData] = []
var selected_index: int = -1

func _ready() -> void:
	add_to_group(Constants.DATA_PERSISTENCE_GROUP_NAME)

func add_item(item: ItemData) -> bool:
	if item == null:
		return false

	if items.size() >= MAX_ITEMS:
		inventory_full.emit()
		return false

	items.append(item)

	inventory_changed.emit()

	return true


func remove_item(index: int) -> void:
	if index < 0 or index >= items.size():
		return

	items.remove_at(index)

	# Se o item removido estava selecionado
	if selected_index == index:
		selected_index = -1

	# Se um item anterior ao selecionado foi removido,
	# o índice do selecionado diminui.
	elif selected_index > index:
		selected_index -= 1

	inventory_changed.emit()
	selection_changed.emit()


func get_item(index: int) -> ItemData:
	if index < 0 or index >= items.size():
		return null

	return items[index]


func get_selected_item() -> ItemData:
	if selected_index < 0:
		return null

	if selected_index >= items.size():
		return null

	return items[selected_index]


func select_slot(index: int) -> void:
	if index < 0 or index >= items.size():
		return
	if selected_index == index:
		selected_index = -1
	else:
		selected_index = index

	selection_changed.emit()


func deselect_item() -> void:
	selected_index = -1
	selection_changed.emit()


func consume_selected_item() -> void:
	if selected_index < 0:
		return

	if selected_index >= items.size():
		return

	var item := items[selected_index]

	if not item.consumable:
		return

	remove_item(selected_index)
	
func change_size(ammount: int):
	MAX_ITEMS = ammount
	
	
func use_selected_item() -> bool:
	if selected_index < 0:
		return false

	if selected_index >= items.size():
		return false

	var item: ItemData = items[selected_index]

	if item.consumable:
		print("Item consumido: %s" % item.item_name)
		remove_item(selected_index)
		return true

	return false


#-------------------------------------------------------------------------
# FUNÇÕES DE PERSISTÊNCIA DE DADOS
#-------------------------------------------------------------------------
func save_to_state(state: Dictionary) -> void:
	var inventory_manager_dict: Dictionary = {}
	
	var saved_item_paths: Array[String] = []
	for item in items:
		if item and item.resource_path != "":
			saved_item_paths.append(item.resource_path)
			
	inventory_manager_dict["saved_item_paths"] = saved_item_paths
	inventory_manager_dict["selected_index"] = selected_index
	
	inventory_manager_dict["max_items"] = MAX_ITEMS 
	
	state["InventoryManager"] = inventory_manager_dict

func load_from_state(state: Dictionary) -> void:
	var inventory_manager_dict = state.get("InventoryManager", {})
	
	var saved_item_paths = inventory_manager_dict.get("saved_item_paths", [])
	MAX_ITEMS = inventory_manager_dict.get("max_items", 5)
	selected_index = inventory_manager_dict.get("selected_index", -1)
	
	items.clear()
	for path in saved_item_paths:
		if ResourceLoader.exists(path):
			var loaded_item = load(path) as ItemData
			if loaded_item:
				items.append(loaded_item)
				
	inventory_changed.emit()
	selection_changed.emit()
