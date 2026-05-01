class_name Genome
extends Resource

@export var seed: int = 1
@export var gene_values: Dictionary = {}


func get_gene(gene_id: String, fallback: float = 0.0) -> float:
	return float(gene_values.get(gene_id, fallback))


func set_gene(gene_id: String, value: float) -> void:
	gene_values[gene_id] = value


func to_debug_text() -> String:
	var lines: Array[String] = ["Genome seed: %d" % seed]
	var keys := gene_values.keys()
	keys.sort()
	for key in keys:
		lines.append("%s: %.3f" % [str(key), float(gene_values[key])])
	return "\n".join(lines)
