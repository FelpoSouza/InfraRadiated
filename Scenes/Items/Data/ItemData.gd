extends Resource
class_name ItemData

@export_category("Identificação")
@export var item_name: String
@export var item_id: String

@export_category("Visual")
@export var inventory_sprite: Texture2D

@export_category("Objeto 3D")
@export var item_model: PackedScene # usa esse na maioria dos casos
@export var item_mesh: Mesh # Se null, usa o inventory_sprite Texture2D
@export var item_material: Material

@export_category("Comportamento")
@export var consumable: bool = true
