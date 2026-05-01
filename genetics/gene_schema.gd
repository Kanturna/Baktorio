class_name GeneSchema
extends Resource

@export var gene_id: String = ""
@export var label: String = ""
@export var min_value: float = 0.0
@export var max_value: float = 1.0
@export var default_value: float = 0.5


func clamp_value(value: float) -> float:
	return clampf(value, min_value, max_value)


func random_value(rng: SeededRng) -> float:
	return lerpf(min_value, max_value, rng.randf())


func normalized_value(value: float) -> float:
	if is_equal_approx(max_value, min_value):
		return 0.0
	return inverse_lerp(min_value, max_value, clamp_value(value))
