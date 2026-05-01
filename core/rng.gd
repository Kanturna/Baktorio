class_name SeededRng
extends RefCounted

const MODULUS_I: int = 4294967296
const MODULUS_F: float = 4294967296.0
const MULTIPLIER: int = 1664525
const INCREMENT: int = 1013904223

var seed_value: int = 1
var _state: int = 1


func _init(initial_seed: int = 1) -> void:
	reseed(initial_seed)


func reseed(new_seed: int) -> void:
	seed_value = max(1, abs(new_seed))
	_state = mix_seed(seed_value, INCREMENT)


func fork(salt: int) -> SeededRng:
	return SeededRng.new(mix_seed(seed_value, salt))


func randf() -> float:
	var next_state: int = int((MULTIPLIER * _state + INCREMENT) % MODULUS_I)
	_state = next_state
	return float(_state) / MODULUS_F


func randf_range(min_value: float, max_value: float) -> float:
	return lerpf(min_value, max_value, self.randf())


func randi_range(min_value: int, max_value: int) -> int:
	var span: int = max(1, max_value - min_value + 1)
	return min_value + int(floor(self.randf() * float(span))) % span


func signed_unit() -> float:
	return self.randf_range(-1.0, 1.0)


static func mix_seed(base_seed: int, salt: int) -> int:
	var mixed: int = (abs(base_seed) % MODULUS_I) ^ (abs(salt) % MODULUS_I)
	mixed = int((1103515245 * mixed + 12345) % MODULUS_I)
	return max(1, abs(mixed))
