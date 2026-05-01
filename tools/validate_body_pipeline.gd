extends SceneTree

const FLUID_MIN_DISTANCE_FACTOR := 0.72


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
		if not _has_valid_surface_segments(blueprint, body_config):
			push_error("Surface segment check failed for seed %d." % variant_seed)
			quit(1)
			return
		if not _has_valid_module_surface_links(blueprint):
			push_error("Module surface link check failed for seed %d." % variant_seed)
			quit(1)
			return
		if not _has_clear_core_reserve(blueprint, body_config):
			push_error("Core reserve check failed for seed %d." % variant_seed)
			quit(1)
			return
		if not _has_clear_fluid_spacing(blueprint):
			push_error("Fluid spacing check failed for seed %d." % variant_seed)
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


func _has_valid_surface_segments(blueprint: BodyBlueprint, body_config: BodyLabConfig) -> bool:
	var expected_count: int = max(8, body_config.surface_segment_count)
	if blueprint.surface_segments.size() != expected_count:
		push_error("Expected %d surface segments, got %d." % [expected_count, blueprint.surface_segments.size()])
		return false

	var zone_ids: Dictionary = _zone_ids(blueprint)
	var seen_ids: Dictionary = {}
	var angle_step: float = TAU / float(expected_count)
	for index in range(expected_count):
		var segment: BodySurfaceSegment = blueprint.surface_segments[index]
		var expected_id: String = "surface_%02d" % index
		if segment.index != index:
			push_error("Surface segment index mismatch at %d." % index)
			return false
		if segment.segment_id != expected_id:
			push_error("Surface segment id mismatch: %s != %s." % [segment.segment_id, expected_id])
			return false
		if seen_ids.has(segment.segment_id):
			push_error("Duplicate surface segment id: %s." % segment.segment_id)
			return false
		seen_ids[segment.segment_id] = true

		var expected_start: float = angle_step * float(index)
		var expected_end: float = angle_step * float(index + 1)
		if abs(segment.angle_start - expected_start) > 0.0001 or abs(segment.angle_end - expected_end) > 0.0001:
			push_error("Surface segment %s does not tile expected angle range." % segment.segment_id)
			return false
		if segment.normal.length() < 0.98 or segment.normal.length() > 1.02:
			push_error("Surface segment %s normal is not normalized." % segment.segment_id)
			return false
		var expected_normal: Vector2 = _expected_surface_normal(segment, blueprint.body_scale)
		if segment.normal.dot(expected_normal) < 0.999:
			push_error("Surface segment %s normal does not match ellipse normal." % segment.segment_id)
			return false
		for zone_id in segment.linked_zone_ids:
			if not zone_ids.has(zone_id):
				push_error("Surface segment %s links missing zone %s." % [segment.segment_id, zone_id])
				return false
	return true


func _has_valid_module_surface_links(blueprint: BodyBlueprint) -> bool:
	for zone in blueprint.zones:
		if not _is_base_module_tag(zone.module_tag) and not blueprint.module_tags.has(zone.module_tag):
			push_error("Zone %s has unknown module tag %s." % [zone.zone_id, zone.module_tag])
			return false

	for segment in blueprint.surface_segments:
		if not segment.module_tag.is_empty() and not blueprint.module_tags.has(segment.module_tag):
			push_error("Surface segment %s has unknown module tag %s." % [segment.segment_id, segment.module_tag])
			return false

	for module_tag in blueprint.module_tags:
		if _is_base_module_tag(module_tag):
			continue
		var zone_count: int = 0
		var segment_count: int = 0
		for zone in blueprint.zones:
			if zone.module_tag == module_tag:
				zone_count += 1
		for segment in blueprint.surface_segments:
			if segment.module_tag == module_tag:
				segment_count += 1
		if zone_count > 1:
			push_error("Module tag %s is assigned to too many zones." % module_tag)
			return false
		if segment_count < 1:
			push_error("Module tag %s has no surface segment." % module_tag)
			return false
	return true


func _is_base_module_tag(module_tag: String) -> bool:
	# Base module tags are Slice-1 capabilities; optional modules must have explicit zone and surface bindings.
	return module_tag.is_empty() or module_tag in ["core", "shell", "metabolism"]


func _has_clear_core_reserve(blueprint: BodyBlueprint, body_config: BodyLabConfig) -> bool:
	var core_zones: Array[BodyZone] = blueprint.zones_by_kind(BodyZone.Kind.CORE)
	if core_zones.size() != 1:
		push_error("Expected exactly one core zone, got %d." % core_zones.size())
		return false

	var core_zone: BodyZone = core_zones[0]
	var core_reserve: float = core_zone.radius * body_config.core_reserve_radius_factor
	for zone in blueprint.zones_by_kind(BodyZone.Kind.FLUID):
		var min_distance: float = core_reserve + zone.radius * 0.5
		if zone.local_position.distance_to(core_zone.local_position) < min_distance:
			push_error("Fluid zone %s is inside core reserve." % zone.zone_id)
			return false
	return true


func _has_clear_fluid_spacing(blueprint: BodyBlueprint) -> bool:
	var fluid_zones: Array[BodyZone] = blueprint.zones_by_kind(BodyZone.Kind.FLUID)
	for left_index in range(fluid_zones.size()):
		var left: BodyZone = fluid_zones[left_index]
		for right_index in range(left_index + 1, fluid_zones.size()):
			var right: BodyZone = fluid_zones[right_index]
			var min_distance: float = (left.radius + right.radius) * FLUID_MIN_DISTANCE_FACTOR
			if left.local_position.distance_to(right.local_position) < min_distance:
				push_error("Fluid zones %s and %s are too close." % [left.zone_id, right.zone_id])
				return false
	return true


func _expected_surface_normal(segment: BodySurfaceSegment, body_scale: Vector2) -> Vector2:
	var center_angle: float = (segment.angle_start + segment.angle_end) * 0.5
	return Vector2(
		cos(center_angle) / max(0.001, body_scale.x),
		sin(center_angle) / max(0.001, body_scale.y)
	).normalized()


func _zone_ids(blueprint: BodyBlueprint) -> Dictionary:
	var ids: Dictionary = {}
	for zone in blueprint.zones:
		ids[zone.zone_id] = true
	return ids


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
		"surface_segment_count": config.surface_segment_count,
		"core_reserve_radius_factor": config.core_reserve_radius_factor,
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
