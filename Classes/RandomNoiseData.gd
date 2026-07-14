class_name RandomNoiseData
extends Resource

@export var random_noise: AudioStream
@export_range(0, 100, 0.1, "suffix:%") var random_noise_chance: float = 1.0
