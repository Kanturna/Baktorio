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
	_add_core_zone(blueprint, rng)
	_add_fluid_zones(blueprint, rng, config, fluid_ratio, complexity_gene)
	_add_structural_zones(blueprint, rng, config, structural_ratio, complexity_gene)
	_add_optional_modules(blueprint, rng, genome, config)

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


func _add_core_zone(blueprint: BodyBlueprint, rng: SeededRng) -> void:
	var zone := BodyZone.new()
	zone.zone_id = "core"
	zone.kind = BodyZone.Kind.CORE
	zone.material_id = "core"
	var core_offset_x := rng.signed_unit()
	var core_offset_y := rng.signed_unit()
	zone.local_position = Vector2(core_offset_x, core_offset_y) * blueprint.body_radius * blueprint.asymmetry * 0.35
	zone.radius = blueprint.body_radius * lerpf(0.13, 0.2, blueprint.complexity)
	var core_stretch_y := 0.92 + rng.randf() * 0.18
	zone.stretch = Vector2(1.0, core_stretch_y)
	zone.rotation = rng.randf_range(-0.35, 0.35)
	zone.strength = 1.0
	zone.module_tag = "core"
	blueprint.zones.append(zone)


func _add_fluid_zones(
	blueprint: BodyBlueprint,
	rng: SeededRng,
	config: BodyLabConfig,
	fluid_ratio: float,
	complexity: float
) -> void:
	var count := clampi(
		int(round(lerpf(float(config.min_fluid_zones), float(config.max_fluid_zones), (fluid_ratio + complexity) * 0.5))),
		config.min_fluid_zones,
		config.max_fluid_zones
	)

	for index in range(count):
		var angle := TAU * float(index) / float(count) + rng.randf_range(-0.35, 0.35)
		var distance := blueprint.body_radius * rng.randf_range(0.12, 0.46)
		var zone := BodyZone.new()
		zone.zone_id = "fluid_%02d" % index
		zone.kind = BodyZone.Kind.FLUID
		zone.material_id = "fluid"
		zone.local_position = _ellipse_offset(angle, distance, blueprint.body_scale)
		zone.radius = blueprint.body_radius * rng.randf_range(0.18, 0.28) * lerpf(0.78, 1.18, fluid_ratio)
		var fluid_stretch_x := rng.randf_range(0.82, 1.25)
		var fluid_stretch_y := rng.randf_range(0.82, 1.22)
		zone.stretch = Vector2(fluid_stretch_x, fluid_stretch_y)
		zone.rotation = angle + rng.randf_range(-0.6, 0.6)
		zone.strength = fluid_ratio
		blueprint.zones.append(zone)


func _add_structural_zones(
	blueprint: BodyBlueprint,
	rng: SeededRng,
	config: BodyLabConfig,
	structural_ratio: float,
	complexity: float
) -> void:
	var count := clampi(int(round(float(config.max_structural_zones) * structural_ratio * lerpf(0.65, 1.15, complexity))), 0, config.max_structural_zones)

	for index in range(count):
		var angle := TAU * rng.randf()
		var distance := blueprint.body_radius * rng.randf_range(0.08, 0.5)
		var zone := BodyZone.new()
		zone.zone_id = "structural_%02d" % index
		zone.kind = BodyZone.Kind.STRUCTURAL
		zone.material_id = "structural"
		zone.local_position = _ellipse_offset(angle, distance, blueprint.body_scale)
		zone.radius = blueprint.body_radius * rng.randf_range(0.055, 0.11)
		var structural_stretch_x := rng.randf_range(1.45, 2.65)
		var structural_stretch_y := rng.randf_range(0.35, 0.7)
		zone.stretch = Vector2(structural_stretch_x, structural_stretch_y)
		zone.rotation = angle + rng.randf_range(-0.5, 0.5)
		zone.strength = structural_ratio
		blueprint.zones.append(zone)


func _add_optional_modules(blueprint: BodyBlueprint, rng: SeededRng, genome: Genome, config: BodyLabConfig) -> void:
	if genome.get_gene("photosynthesis_affinity", 0.0) >= config.optional_module_threshold:
		blueprint.module_tags.append("photosynthesis")
		var zone := BodyZone.new()
		zone.zone_id = "photosynthesis"
		zone.kind = BodyZone.Kind.PHOTOSYNTHETIC
		zone.material_id = "photosynthetic"
		zone.local_position = _ellipse_offset(-PI * 0.5 + rng.randf_range(-0.35, 0.35), blueprint.body_radius * 0.72, blueprint.body_scale)
		zone.radius = blueprint.body_radius * 0.12
		zone.stretch = Vector2(1.6, 0.55)
		zone.rotation = rng.randf_range(-0.4, 0.4)
		zone.strength = genome.get_gene("photosynthesis_affinity", 0.0)
		zone.module_tag = "photosynthesis"
		blueprint.zones.append(zone)

	if genome.get_gene("intake_affinity", 0.0) >= config.optional_module_threshold:
		blueprint.module_tags.append("intake")
		var zone := BodyZone.new()
		zone.zone_id = "intake"
		zone.kind = BodyZone.Kind.INTAKE
		zone.material_id = "intake"
		zone.local_position = _ellipse_offset(rng.randf_range(-0.22, 0.22), blueprint.body_radius * 0.78, blueprint.body_scale)
		zone.radius = blueprint.body_radius * 0.13
		zone.stretch = Vector2(1.35, 0.52)
		zone.rotation = rng.randf_range(-0.18, 0.18)
		zone.strength = genome.get_gene("intake_affinity", 0.0)
		zone.module_tag = "intake"
		blueprint.zones.append(zone)


func _ellipse_offset(angle: float, distance: float, scale: Vector2) -> Vector2:
	return Vector2(cos(angle) * distance * scale.x, sin(angle) * distance * scale.y)


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
