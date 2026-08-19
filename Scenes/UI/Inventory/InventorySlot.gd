extends Control
class_name InventorySlot


@onready var item_icon: TextureRect = $TextureRect
@onready var select_slot: Control = $SelectSlot
@onready var item_name: Label = $nomeItem


func _ready() -> void:
	clear()


func set_item(item: ItemData) -> void:

	if item == null:
		clear()
		return

	item_icon.texture = item.inventory_sprite
	item_icon.visible = true

	item_name.text = item.item_name
	item_name.visible = true


func clear() -> void:

	item_icon.texture = null
	item_icon.visible = false

	item_name.text = ""
	item_name.visible = false

	select_slot.visible = false
