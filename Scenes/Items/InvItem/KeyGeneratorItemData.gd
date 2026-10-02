extends ItemData
class_name KeyGeneratorItemData

func use_object(player: Node, interObj: Interactable) -> bool:
	
	if interObj is GeneratorInteractable:
		print("O Gerador Ronca! Abrubrubrum! Brubrum! TÁTÁ!!")
		interObj.switchGenerator()
		#chamaria uma função switchGenerator() da classe "InteractableGenerator"
	else:
		print("A chave não fez nada...")
	InventoryManager.use_selected_item()
	return true
