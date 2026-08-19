extends Node

signal inventory_changed
signal selection_changed
signal inventory_full

# talvez uma mochila mais para frente que adiciona espaço?
var MAX_ITEMS : int = 5

var items: Array[ItemData] = []
var selected_index: int = -1


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
