class_name NpcDialogueData
extends Resource

@export var dialogue_start_node: String = "start"
@export var dialogue_resource: DialogueResource
@export var voice_sfxs: Array[AudioStream]
@export var seconds_per_step: float = 0.02

## Precisam estar em letras minúsculas e seguir exatamente o padrão em Constants.gd
@export_group("Emotions Textures")
@export var happy: Texture2D
@export var sad: Texture2D
@export var angry: Texture2D
