extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("inventory1"):
		select_slot(0)

	if Input.is_action_just_pressed("inventory2"):
		select_slot(1)

	if Input.is_action_just_pressed("inventory3"):
		select_slot(2)

	if Input.is_action_just_pressed("inventory4"):
		select_slot(3)

	if Input.is_action_just_pressed("inventory5"):
		select_slot(4)
	
func update_slots() -> void:
	for i in range(5):
		if i < InventoryManager.items.size():
			slots[i].set_item(
				InventoryManager.items[i]
			)
		else:
			slots[i].clear()
			
func select_slot(index: int) -> void:
	if index >= InventoryManager.items.size():
		return

	if InventoryManager.selected_index == index:
		# Já estava selecionado
		InventoryManager.selected_index = -1
		hide_selected_item()
	else:
		InventoryManager.selected_index = index
		show_selected_item(
			InventoryManager.items[index]
		)

	update_selection_visuals()
	
func show_selected_item(item: ItemData) -> void:
	selected_item.texture = item.inventory_sprite
	selected_item.visible = true
	
func hide_selected_item() -> void:
	selected_item.visible = false
	
# PARA ITENS DE CONSUMO DIRETO	
#func interact_with_item(item: ItemData) -> bool:
#	return false

# EXEMPLO PARA ITENS QUE É APLICADO A OUTRO
#func interact_with_item(item: ItemData) -> bool:
#	if item.item_name != "Chave":
#		return false
#	open_door()
#	return true
