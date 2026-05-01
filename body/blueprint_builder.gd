class_name BlueprintBuilder
extends RefCounted


func build(genome: Genome, config: BodyLabConfig) -> BodyBlueprint:
	var rng := SeededRng.new(genome.seed)
	var blueprint := BodyBlueprint.new()
	blueprint.seed = genome.seed
	blueprint.gene_snapshot = genome.gene_values.duplicate(true)

	var size := genome.get_gene("size", 0.5)
	var shape_bias := genome.get_gene("shape_bias", 0.5)
	var shell_strength := genome.get_gene("shell_strength", 0.5)
	var shell_layers_gene := genome.get_gene("shell_layers", 0.0)
	var fluid_ratio := genome.get_gene("interior_fluid_ratio", 0.5)
	var structural_ratio := genome.get_gene("structural_ratio", 0.3)
	var asymmetry_gene := genome.get_gene("asymmetry", 0.0)
	var complexity_gene := genome.get_gene("complexity_bias", 0.35)

	blueprint.body_radius = lerpf(config.min_body_radius, config.max_body_radius, size)
	blueprint.body_scale = Vector2(
		lerpf(0.82, 1.58, shape_bias),
		lerpf(1.18, 0.78, shape_bias)
	)
	blueprint.body_axis = Vector2.RIGHT
	blueprint.asymmetry = clampf(asymmetry_gene * config.asymmetry_strength, 0.0, 1.0)
	blueprint.symmetry = 1.0 - blueprint.asymmetry
	blueprint.complexity = complexity_gene
	blueprint.shell_layers = clampi(1 + int(round(shell_layers_gene * float(max(0, config.max_shell_layers - 1)))), 1, config.max_shell_layers)
	blueprint.pigment_hue = genome.get_gene("pigment_hue", 0.5)
	blueprint.module_tags = ["core", "shell", "metabolism"]

	_add_shell_zone(blueprint, shell_strength)
	var core_zone := _add_core_zone(blueprint, rng, config)
	var fluid_zones := _add_fluid_zones(blueprint, rng, config, fluid_ratio, complexity_gene, core_zone)
	var module_zones := _add_optional_modules(blueprint, rng, genome, config)
	_add_structural_zones(blueprint, rng, config, structural_ratio, complexity_gene, core_zone, fluid_zones, module_zones)
	_add_surface_segments(blueprint, config)

	blueprint.material_balance = _calculate_material_balance(blueprint.zones)
	return blueprint


func _add_shell_zone(blueprint: BodyBlueprint, shell_strength: float) -> void:
	var zone := BodyZone.new()
	zone.zone_id = "shell"
	zone.kind = BodyZone.Kind.SHELL
	zone.material_id = "shell"
	zone.radius = blueprint.body_radius
	zone.stretch = blueprint.body_scale
	zone.strength = shell_strength
	zone.module_tag = "shell"
	blueprint.zones.append(zone)


func _add_core_zone(blueprint: BodyBlueprint, rng: SeededRng, _config: BodyLabConfig) -> BodyZone:
	var zone := BodyZone.new()
	zone.zone_id = "core"
	zone.kind = BodyZone.Kind.CORE
	zone.material_id = "core"
	var core_offset_x := rng.signed_unit()
	var core_offset_y := rng.signed_unit()
	zone.local_position = Vector2(core_offset_x, core_offset_y) * blueprint.body_radius * blueprint.asymmetry * 0.16
	zone.radius = blueprint.body_radius * lerpf(0.13, 0.2, blueprint.complexity)
	var core_stretch_y := 0.92 + rng.randf() * 0.18
	zone.stretch = Vector2(1.0, core_stretch_y)
	zone.rotation = rng.randf_range(-0.35, 0.35)
	zone.strength = 1.0
	zone.module_tag = "core"
	blueprint.zones.append(zone)
	return zone


func _add_fluid_zones(
	blueprint: BodyBlueprint,
	rng: SeededRng,
	config: BodyLabConfig,
	fluid_ratio: float,
	complexity: float,
	core_zone: BodyZone
) -> Array[BodyZone]:
	var count := clampi(
		int(round(lerpf(float(config.min_fluid_zones), float(config.max_fluid_zones), (fluid_ratio + complexity) * 0.5))),
		config.min_fluid_zones,
		config.max_fluid_zones
	)

	var fluid_zones: Array[BodyZone] = []
	var core_reserve: float = core_zone.radius * config.core_reserve_radius_factor
	for index in range(count):
		var angle_jitter := rng.randf_range(-0.28, 0.28)
		var distance_draw := rng.randf()
		var radius_draw := rng.randf()
		var stretch_x_draw := rng.randf()
		var stretch_y_draw := rng.randf()
		var rotation_draw := rng.randf()

		var angle := TAU * float(index) / float(count) + angle_jitter
		var zone := BodyZone.new()
		zone.zone_id = "fluid_%02d" % index
		zone.kind = BodyZone.Kind.FLUID
		zone.material_id = "fluid"
		zone.radius = blueprint.body_radius * lerpf(0.18, 0.28, radius_draw) * lerpf(0.78, 1.18, fluid_ratio)
		var min_distance: float = core_reserve + zone.radius * 0.82
		var max_distance: float = max(min_distance + 4.0, blueprint.body_radius * 0.52)
		var distance: float = lerpf(min_distance, max_distance, distance_draw)
		zone.local_position = _resolve_interior_position(angle, distance, zone.radius, blueprint, fluid_zones, core_zone, core_reserve)
		var fluid_stretch_x := lerpf(0.86, 1.2, stretch_x_draw)
		var fluid_stretch_y := lerpf(0.86, 1.18, stretch_y_draw)
		zone.stretch = Vector2(fluid_stretch_x, fluid_stretch_y)
		zone.rotation = angle + lerpf(-0.45, 0.45, rotation_draw)
		zone.strength = fluid_ratio
		blueprint.zones.append(zone)
		fluid_zones.append(zone)
	return fluid_zones


func _add_structural_zones(
	blueprint: BodyBlueprint,
	rng: SeededRng,
	config: BodyLabConfig,
	structural_ratio: float,
	complexity: float,
	core_zone: BodyZone,
	fluid_zones: Array[BodyZone],
	module_zones: Array[BodyZone]
) -> void:
	var count := clampi(int(round(float(config.max_structural_zones) * structural_ratio * lerpf(0.65, 1.15, complexity))), 0, config.max_structural_zones)
	var targets: Array[BodyZone] = []
	targets.append_array(fluid_zones)
	targets.append_array(module_zones)
	if targets.is_empty():
		return

	for index in range(count):
		var target := targets[index % targets.size()]
		var offset_draw := rng.randf()
		var radius_draw := rng.randf()
		var stretch_draw := rng.randf()
		var target_vector := target.local_position - core_zone.local_position
		var direction := target_vector.normalized()
		if direction == Vector2.ZERO:
			direction = Vector2.RIGHT
		var tangent := Vector2(-direction.y, direction.x)
		var center := core_zone.local_position.lerp(target.local_position, 0.58)
		center += tangent * lerpf(-0.08, 0.08, offset_draw) * blueprint.body_radius
		var zone := BodyZone.new()
		zone.zone_id = "structural_%02d" % index
		zone.kind = BodyZone.Kind.STRUCTURAL
		zone.material_id = "structural"
		zone.local_position = center
		zone.radius = blueprint.body_radius * lerpf(0.045, 0.085, radius_draw)
		var structural_stretch_x := lerpf(1.85, 3.15, stretch_draw)
		zone.stretch = Vector2(structural_stretch_x, 0.34)
		zone.rotation = direction.angle()
		zone.strength = structural_ratio
		blueprint.zones.append(zone)


func _add_optional_modules(blueprint: BodyBlueprint, rng: SeededRng, genome: Genome, config: BodyLabConfig) -> Array[BodyZone]:
	var module_zones: Array[BodyZone] = []
	if genome.get_gene("photosynthesis_affinity", 0.0) >= config.optional_module_threshold:
		blueprint.module_tags.append("photosynthesis")
		var zone := BodyZone.new()
		zone.zone_id = "photosynthesis"
		zone.kind = BodyZone.Kind.PHOTOSYNTHETIC
		zone.material_id = "photosynthetic"
		var angle := -PI * 0.5 + rng.randf_range(-0.28, 0.28)
		zone.local_position = _ellipse_offset(angle, blueprint.body_radius * 0.82, blueprint.body_scale)
		zone.radius = blueprint.body_radius * 0.12
		zone.stretch = Vector2(1.6, 0.55)
		zone.rotation = angle + PI * 0.5
		zone.strength = genome.get_gene("photosynthesis_affinity", 0.0)
		zone.module_tag = "photosynthesis"
		blueprint.zones.append(zone)
		module_zones.append(zone)

	if genome.get_gene("intake_affinity", 0.0) >= config.optional_module_threshold:
		blueprint.module_tags.append("intake")
		var zone := BodyZone.new()
		zone.zone_id = "intake"
		zone.kind = BodyZone.Kind.INTAKE
		zone.material_id = "intake"
		var angle := rng.randf_range(-0.18, 0.18)
		zone.local_position = _ellipse_offset(angle, blueprint.body_radius * 0.86, blueprint.body_scale)
		zone.radius = blueprint.body_radius * 0.13
		zone.stretch = Vector2(1.35, 0.52)
		zone.rotation = angle
		zone.strength = genome.get_gene("intake_affinity", 0.0)
		zone.module_tag = "intake"
		blueprint.zones.append(zone)
		module_zones.append(zone)
	return module_zones


func _add_surface_segments(blueprint: BodyBlueprint, config: BodyLabConfig) -> void:
	var segment_count: int = max(8, config.surface_segment_count)
	var angle_step: float = TAU / float(segment_count)
	for index in range(segment_count):
		var angle_start: float = angle_step * float(index)
		var angle_end: float = angle_step * float(index + 1)
		var center_angle: float = (angle_start + angle_end) * 0.5
		var segment := BodySurfaceSegment.new()
		segment.segment_id = "surface_%02d" % index
		segment.index = index
		segment.angle_start = angle_start
		segment.angle_end = angle_end
		segment.normal = Vector2(cos(center_angle), sin(center_angle)).normalized()
		segment.center_position = _ellipse_offset(center_angle, blueprint.body_radius, blueprint.body_scale)
		segment.linked_zone_ids = ["shell"]
		blueprint.surface_segments.append(segment)

	for zone in blueprint.zones:
		if zone.kind == BodyZone.Kind.SHELL:
			continue
		var segment: BodySurfaceSegment = _nearest_surface_segment(blueprint, zone.local_position)
		if segment == null:
			continue
		if not segment.linked_zone_ids.has(zone.zone_id):
			segment.linked_zone_ids.append(zone.zone_id)
		if not zone.module_tag.is_empty() and zone.module_tag != "core":
			segment.module_tag = zone.module_tag


func _ellipse_offset(angle: float, distance: float, scale: Vector2) -> Vector2:
	return Vector2(cos(angle) * distance * scale.x, sin(angle) * distance * scale.y)


func _resolve_interior_position(
	angle: float,
	distance: float,
	radius: float,
	blueprint: BodyBlueprint,
	fluid_zones: Array[BodyZone],
	core_zone: BodyZone,
	core_reserve: float
) -> Vector2:
	var segment_count: int = max(1, fluid_zones.size() + 1)
	var best_position: Vector2 = _ellipse_offset(angle, distance, blueprint.body_scale)
	for attempt in range(6):
		var candidate_angle: float = angle + TAU * float(attempt) / float(segment_count + 4)
		var candidate_distance: float = distance + float(attempt % 3) * radius * 0.28
		var candidate: Vector2 = _ellipse_offset(candidate_angle, candidate_distance, blueprint.body_scale)
		if _is_interior_position_clear(candidate, radius, fluid_zones, core_zone, core_reserve):
			return candidate
		best_position = candidate
	return _shrink_position_from_core(best_position, radius, core_zone, core_reserve)


func _is_interior_position_clear(
	position: Vector2,
	radius: float,
	fluid_zones: Array[BodyZone],
	core_zone: BodyZone,
	core_reserve: float
) -> bool:
	var core_distance := position.distance_to(core_zone.local_position)
	if core_distance < core_reserve + radius * 0.55:
		return false
	for zone in fluid_zones:
		var min_distance := (radius + zone.radius) * 0.72
		if position.distance_to(zone.local_position) < min_distance:
			return false
	return true


func _shrink_position_from_core(position: Vector2, radius: float, core_zone: BodyZone, core_reserve: float) -> Vector2:
	var direction := (position - core_zone.local_position).normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	var min_distance := core_reserve + radius * 0.72
	if position.distance_to(core_zone.local_position) < min_distance:
		return core_zone.local_position + direction * min_distance
	return position


func _nearest_surface_segment(blueprint: BodyBlueprint, position: Vector2) -> BodySurfaceSegment:
	if blueprint.surface_segments.is_empty():
		return null
	var angle: float = _surface_angle_for_position(position, blueprint.body_scale)
	var best_segment: BodySurfaceSegment = blueprint.surface_segments[0]
	var best_distance: float = TAU
	for segment in blueprint.surface_segments:
		var center_angle: float = (segment.angle_start + segment.angle_end) * 0.5
		var distance: float = abs(angle_difference(angle, center_angle))
		if distance < best_distance:
			best_distance = distance
			best_segment = segment
	return best_segment


func _surface_angle_for_position(position: Vector2, scale: Vector2) -> float:
	var normalized := Vector2(position.x / max(0.001, scale.x), position.y / max(0.001, scale.y))
	return wrapf(atan2(normalized.y, normalized.x), 0.0, TAU)


func _calculate_material_balance(zones: Array[BodyZone]) -> Dictionary:
	var totals := {}
	var total_area := 0.0
	for zone in zones:
		var area: float = zone.radius * zone.radius * max(0.1, zone.stretch.x) * max(0.1, zone.stretch.y)
		totals[zone.material_id] = float(totals.get(zone.material_id, 0.0)) + area
		total_area += area

	if total_area <= 0.0:
		return totals

	for key in totals.keys():
		totals[key] = float(totals[key]) / total_area
	return totals
