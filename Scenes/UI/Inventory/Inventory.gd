extends Control


@onready var slots: Array[InventorySlot] = [
	$Slot1,
	$Slot2,
	$Slot3,
	$Slot4,
	$Slot5
]

@onready var selected_item: TextureRect = $"../Crosshair/SelectedItem"
@onready var full_message: Label = $"../FullMessage"


func _ready() -> void:
	InventoryManager.inventory_changed.connect(update_slots)
	InventoryManager.selection_changed.connect(update_selection_visuals)
	InventoryManager.inventory_full.connect(show_inventory_full)

	update_slots()
	update_selection_visuals()

	selected_item.visible = false
	full_message.visible = false


func _process(_delta: float) -> void:

	if Input.is_action_just_pressed("inventory1"):
		select_slot(0)

	elif Input.is_action_just_pressed("inventory2"):
		select_slot(1)

	elif Input.is_action_just_pressed("inventory3"):
		select_slot(2)

	elif Input.is_action_just_pressed("inventory4"):
		select_slot(3)

	elif Input.is_action_just_pressed("inventory5"):
		select_slot(4)
	# trocar mais para frente, para evitar ação dupla do jogador	
	#elif Input.is_action_just_pressed("interact"):
	#	InventoryManager.use_selected_item()


func update_slots() -> void:

	for i in range(5):

		if i < InventoryManager.items.size():

			slots[i].set_item(
				InventoryManager.items[i]
			)

		else:

			slots[i].clear()


func select_slot(index: int) -> void:
	InventoryManager.select_slot(index)


func show_selected_item(item: ItemData) -> void:

	if item == null:
		return

	selected_item.texture = item.inventory_sprite
	selected_item.visible = true


func hide_selected_item() -> void:

	selected_item.texture = null
	selected_item.visible = false


func update_selection_visuals() -> void:
	var selected_index: int = InventoryManager.selected_index

	for i in range(slots.size()):
		var select_slot = slots[i].get_node("SelectSlot")

		if i == selected_index:
			select_slot.visible = true
		else:
			select_slot.visible = false

	# Atualiza o item mostrado no centro da tela
	var item := InventoryManager.get_selected_item()

	if item:
		show_selected_item(item)
	else:
		hide_selected_item()


func show_inventory_full() -> void:

	full_message.text = "Inventário cheio!"
	full_message.visible = true

	var tween := create_tween()

	tween.tween_interval(1.5)

	tween.tween_callback(func():
		full_message.visible = false
	)
	
# PARA ITENS DE CONSUMO DIRETO	
#func interact_with_item(item: ItemData) -> bool:
#	return false

# EXEMPLO PARA ITENS QUE É APLICADO A OUTRO
#func interact_with_item(item: ItemData) -> bool:
#	if item.item_name != "Chave":
#		return false
#	open_door()
#	return true
