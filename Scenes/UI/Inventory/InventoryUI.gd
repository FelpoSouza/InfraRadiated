extends Control


@onready var full_message: Label = $"../FullMessage"

@onready var selected_item: TextureRect = $"../Crosshair/SelectedItem"


var slots: Array[Control] = []


func _ready() -> void:
	# Guarda os cinco slots
	slots = [
		$Slot1,
		$Slot2,
		$Slot3,
		$Slot4,
		$Slot5
	]

	# Conecta aos eventos do InventoryManager
	InventoryManager.inventory_changed.connect(update_inventory)
	InventoryManager.selection_changed.connect(update_selection)
	InventoryManager.inventory_full.connect(show_inventory_full)

	# Estado inicial
	selected_item.visible = false
	full_message.visible = false

	update_inventory()
	update_selection()


func _process(_delta: float) -> void:

	if Input.is_action_just_pressed("inventory_1"):
		InventoryManager.select_slot(0)

	elif Input.is_action_just_pressed("inventory_2"):
		InventoryManager.select_slot(1)

	elif Input.is_action_just_pressed("inventory_3"):
		InventoryManager.select_slot(2)

	elif Input.is_action_just_pressed("inventory_4"):
		InventoryManager.select_slot(3)

	elif Input.is_action_just_pressed("inventory_5"):
		InventoryManager.select_slot(4)


func update_inventory() -> void:

	for i in range(slots.size()):

		var slot: Control = slots[i]

		var item_icon: TextureRect = slot.get_node("TextureRect")
		var item_name: Label = slot.get_node("nomeItem")

		# Slot possui um item
		if i < InventoryManager.items.size():

			var item: ItemData = InventoryManager.items[i]

			item_icon.texture = item.inventory_sprite
			item_icon.visible = true

			item_name.text = item.item_name
			item_name.visible = true

		# Slot vazio
		else:

			item_icon.texture = null
			item_icon.visible = false

			item_name.text = ""
			item_name.visible = false

	update_selection()


func update_selection() -> void:

	var selected_index: int = InventoryManager.selected_index

	for i in range(slots.size()):

		var slot: Control = slots[i]

		var select_slot: Control = slot.get_node("SelectSlot")

		if i == selected_index:
			# Mostra o indicador de seleção
			select_slot.visible = true
		else:
			select_slot.visible = false


	# -------------------------
	# ITEM NO CENTRO DA TELA
	# -------------------------

	if selected_index >= 0:

		var item: ItemData = InventoryManager.get_selected_item()

		if item and item.inventory_sprite:

			selected_item.texture = item.inventory_sprite
			selected_item.visible = true

		else:
			selected_item.texture = null
			selected_item.visible = false
	else:
		selected_item.texture = null
		selected_item.visible = false

func show_inventory_full() -> void:

	full_message.text = "Inventário cheio!"
	full_message.visible = true
	var tween := create_tween()
	tween.tween_interval(1.5)
	tween.tween_callback(func():full_message.visible = false)
