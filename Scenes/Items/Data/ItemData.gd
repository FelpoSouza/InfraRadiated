extends Resource
class_name ItemData

enum ItemType {
	FREE_USE,
	NPC_USE,
	OBJECT_USE
}

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
@export var item_type: ItemType = ItemType.FREE_USE 

# Função base para uso livre
func use_free(player: Node) -> bool:
	InventoryManager.use_selected_item()
	return false
	
# Função base para uso em npc
func use_npc(player: Node, Npc: Node) -> bool:
	InventoryManager.use_selected_item()
	return false
	
# Função base para em objetos
func use_object(player: Node) -> bool:
	InventoryManager.use_selected_item()
	return false
