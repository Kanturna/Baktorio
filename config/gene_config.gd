class_name GeneConfig
extends Resource

@export var clamp_values: bool = true
@export var schemas: Array[GeneSchema] = []


func _init() -> void:
	if schemas.is_empty():
		schemas = _default_schemas()


func get_schema(gene_id: String) -> GeneSchema:
	for schema in schemas:
		if schema.gene_id == gene_id:
			return schema
	return null


func default_values() -> Dictionary:
	var values := {}
	for schema in schemas:
		values[schema.gene_id] = schema.default_value
	return values


func clamp_gene_values(values: Dictionary) -> Dictionary:
	var clamped := {}
	for schema in schemas:
		var value := float(values.get(schema.gene_id, schema.default_value))
		clamped[schema.gene_id] = schema.clamp_value(value) if clamp_values else value
	return clamped


static func _make_schema(gene_id: String, label: String, default_value: float = 0.5) -> GeneSchema:
	var schema := GeneSchema.new()
	schema.gene_id = gene_id
	schema.label = label
	schema.min_value = 0.0
	schema.max_value = 1.0
	schema.default_value = default_value
	return schema


static func _default_schemas() -> Array[GeneSchema]:
	return [
		_make_schema("size", "Size", 0.55),
		_make_schema("shape_bias", "Shape Bias", 0.45),
		_make_schema("shell_strength", "Shell Strength", 0.55),
		_make_schema("shell_layers", "Shell Layers", 0.35),
		_make_schema("interior_fluid_ratio", "Interior Fluid Ratio", 0.6),
		_make_schema("structural_ratio", "Structural Ratio", 0.35),
		_make_schema("intake_affinity", "Intake Affinity", 0.25),
		_make_schema("photosynthesis_affinity", "Photosynthesis Affinity", 0.25),
		_make_schema("pigment_hue", "Pigment Hue", 0.48),
		_make_schema("asymmetry", "Asymmetry", 0.2),
		_make_schema("complexity_bias", "Complexity Bias", 0.35),
	]
