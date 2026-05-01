extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var body_config := load("res://resources/config/body_lab_config.tres") as BodyLabConfig
	var gene_config := load("res://resources/config/gene_config.tres") as GeneConfig
	var render_config := load("res://resources/config/render_config.tres") as RenderConfig

	if body_config == null or gene_config == null or render_config == null:
		push_error("Failed to load body pipeline configs.")
		quit(1)
		return

	var seed: int = body_config.review_seed_start
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

	var variant_count: int = max(1, body_config.review_seed_count)
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

	var configs_unchanged: bool = await _body_lab_keeps_configs_unchanged(body_config, render_config)
	if not configs_unchanged:
		quit(1)
		return

	print("Body pipeline validation passed: %d review variants, %d unique summaries." % [variant_count, summaries.size()])
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


func _body_lab_keeps_configs_unchanged(body_config: BodyLabConfig, render_config: RenderConfig) -> bool:
	var body_before: String = _body_config_snapshot(body_config)
	var render_before: String = _render_config_snapshot(render_config)
	var scene := load("res://scenes/body_lab.tscn") as PackedScene
	if scene == null:
		push_error("Failed to load Body Lab scene.")
		return false

	var body_lab := scene.instantiate()
	get_root().add_child(body_lab)
	await process_frame

	var next_button := body_lab.get_node_or_null("SidePanel/Margin/VBox/ButtonRow/NextButton") as Button
	var debug_check := body_lab.get_node_or_null("SidePanel/Margin/VBox/DebugOverlayCheck") as CheckBox
	if next_button == null or debug_check == null:
		push_error("Body Lab review controls are missing.")
		body_lab.queue_free()
		await process_frame
		return false

	var next_presses: int = max(0, body_config.review_seed_count - 1)
	for _index in range(next_presses):
		next_button.emit_signal("pressed")
		await process_frame

	debug_check.emit_signal("toggled", true)
	await process_frame
	debug_check.emit_signal("toggled", false)
	await process_frame

	body_lab.queue_free()
	await process_frame

	if _body_config_snapshot(body_config) != body_before:
		push_error("BodyLabConfig was mutated by the Body Lab scene.")
		return false
	if _render_config_snapshot(render_config) != render_before:
		push_error("RenderConfig was mutated by the Body Lab scene.")
		return false
	return true


func _body_config_snapshot(config: BodyLabConfig) -> String:
	return JSON.stringify({
		"review_seed_start": config.review_seed_start,
		"review_seed_count": config.review_seed_count,
		"min_body_radius": config.min_body_radius,
		"max_body_radius": config.max_body_radius,
		"max_shell_layers": config.max_shell_layers,
		"min_fluid_zones": config.min_fluid_zones,
		"max_fluid_zones": config.max_fluid_zones,
		"max_structural_zones": config.max_structural_zones,
		"optional_module_threshold": config.optional_module_threshold,
		"asymmetry_strength": config.asymmetry_strength,
	})


func _render_config_snapshot(config: RenderConfig) -> String:
	return JSON.stringify({
		"shell_color": config.shell_color.to_html(true),
		"fluid_color": config.fluid_color.to_html(true),
		"structural_color": config.structural_color.to_html(true),
		"core_color": config.core_color.to_html(true),
		"photosynthesis_color": config.photosynthesis_color.to_html(true),
		"intake_color": config.intake_color.to_html(true),
		"debug_color": config.debug_color.to_html(true),
		"shell_width": config.shell_width,
		"shell_fill_alpha": config.shell_fill_alpha,
		"interior_alpha": config.interior_alpha,
		"wobble_strength": config.wobble_strength,
		"pulse_strength": config.pulse_strength,
		"hue_blend": config.hue_blend,
		"use_blueprint_hue": config.use_blueprint_hue,
		"show_debug_overlay": config.show_debug_overlay,
	})
