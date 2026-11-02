class_name GeneratorInteractable
extends Interactable
var generatorStatus = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	interact_message = interact_action + " '" + interactable_name + "'"


func interact() -> void:
	print("Parece precisar de uma chave para usar o %s" % interactable_name)

func switchGenerator() -> void:
	generatorStatus = !generatorStatus
	if generatorStatus == true:
		print("gerador ligado") #acende luz, muda rotina de personagens
	else:
		print("gerador desligado") #luz apagada, muda rotina de personagens
			
