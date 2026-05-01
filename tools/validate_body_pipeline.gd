extends SceneTree


func _init() -> void:
	var body_config := load("res://resources/config/body_lab_config.tres") as BodyLabConfig
	var gene_config := load("res://resources/config/gene_config.tres") as GeneConfig

	if body_config == null or gene_config == null:
		push_error("Failed to load body pipeline configs.")
		quit(1)
		return

	var seed: int = body_config.seed
	if not _rng_is_deterministic(seed):
		push_error("SeededRng check failed for seed %d." % seed)
		quit(1)
		return

	var first: BodyBlueprint = BlueprintBuilder.new().build(GenomeFactory.from_seed(seed, gene_config), body_config)
	var second: BodyBlueprint = BlueprintBuilder.new().build(GenomeFactory.from_seed(seed, gene_config), body_config)

	if first.to_debug_text() != second.to_debug_text():
		print("--- first ---")
		print(first.to_debug_text())
		print("--- second ---")
		print(second.to_debug_text())
		push_error("Determinism check failed for seed %d." % seed)
		quit(1)
		return

	var variant_count: int = max(1, body_config.preview_variant_count)
	var summaries: Dictionary = {}
	for offset in range(variant_count):
		var variant_seed: int = seed + offset
		var blueprint: BodyBlueprint = BlueprintBuilder.new().build(GenomeFactory.from_seed(variant_seed, gene_config), body_config)
		if not _has_required_modules(blueprint):
			push_error("Required module check failed for seed %d." % variant_seed)
			quit(1)
			return
		if not _has_required_materials(blueprint):
			push_error("Required material check failed for seed %d." % variant_seed)
			quit(1)
			return
		summaries[blueprint.to_debug_text()] = true

	if summaries.size() < min(variant_count, 4):
		push_error("Variant check produced too few unique blueprints.")
		quit(1)
		return

	print("Body pipeline validation passed: %d variants, %d unique summaries." % [variant_count, summaries.size()])
	quit(0)


func _has_required_modules(blueprint: BodyBlueprint) -> bool:
	return blueprint.has_module("core") and blueprint.has_module("shell") and blueprint.has_module("metabolism")


func _has_required_materials(blueprint: BodyBlueprint) -> bool:
	var materials: Array = blueprint.material_balance.keys()
	return materials.has("shell") and materials.has("fluid") and materials.has("core")


func _rng_is_deterministic(seed: int) -> bool:
	var first := SeededRng.new(seed)
	var second := SeededRng.new(seed)
	for index in range(24):
		var left: float = first.randf_range(-1.0, 1.0) if index % 2 == 0 else first.signed_unit()
		var right: float = second.randf_range(-1.0, 1.0) if index % 2 == 0 else second.signed_unit()
		if not is_equal_approx(left, right):
			print("rng mismatch at %d: %.8f != %.8f" % [index, left, right])
			return false
	return true
