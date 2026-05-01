class_name CellRenderer
extends Node2D

@export var blueprint: BodyBlueprint:
	set(value):
		blueprint = value
		queue_redraw()

@export var runtime_state: OrganismRuntimeState:
	set(value):
		runtime_state = value
		queue_redraw()

@export var render_config: RenderConfig:
	set(value):
		render_config = value
		queue_redraw()

var _animation_time: float = 0.0


func _ready() -> void:
	if render_config == null:
		render_config = RenderConfig.new()


func configure(
	new_blueprint: BodyBlueprint,
	new_runtime_state: OrganismRuntimeState,
	new_render_config: RenderConfig
) -> void:
	blueprint = new_blueprint
	runtime_state = new_runtime_state
	render_config = new_render_config if new_render_config != null else RenderConfig.new()
	queue_redraw()


func _process(delta: float) -> void:
	_animation_time += delta
	if blueprint != null:
		queue_redraw()


func _draw() -> void:
	if blueprint == null:
		return
	if render_config == null:
		render_config = RenderConfig.new()

	var pulse := 1.0 + sin(_animation_time * 1.8) * render_config.pulse_strength
	_draw_shell_fill(pulse)
	_draw_zones_by_kind(BodyZone.Kind.FLUID, pulse)
	_draw_zones_by_kind(BodyZone.Kind.STRUCTURAL, pulse)
	_draw_zones_by_kind(BodyZone.Kind.PHOTOSYNTHETIC, pulse)
	_draw_zones_by_kind(BodyZone.Kind.INTAKE, pulse)
	_draw_zones_by_kind(BodyZone.Kind.CORE, pulse)
	_draw_shell_lines(pulse)

	if runtime_state != null:
		_draw_runtime_state(pulse)

	if render_config.show_debug_overlay:
		_draw_debug_overlay()


func _draw_shell_fill(pulse: float) -> void:
	var color := _with_alpha(_material_color("shell"), render_config.shell_fill_alpha)
	draw_colored_polygon(_silhouette_points(0.0, pulse), color)


func _draw_shell_lines(pulse: float) -> void:
	var shell_color := _material_color("shell")
	for layer in range(blueprint.shell_layers):
		var offset := -float(layer) * render_config.shell_width * 1.45
		var width: float = max(1.0, render_config.shell_width - float(layer) * 0.9)
		var color := _with_alpha(shell_color, 0.95 - float(layer) * 0.16)
		draw_polyline(_closed_points(_silhouette_points(offset, pulse)), color, width, true)


func _draw_zones_by_kind(kind: BodyZone.Kind, pulse: float) -> void:
	for zone in blueprint.zones:
		if zone.kind == kind:
			_draw_zone(zone, pulse)


func _draw_zone(zone: BodyZone, pulse: float) -> void:
	if zone.kind == BodyZone.Kind.SHELL:
		return

	var color := _with_alpha(_material_color(zone.material_id), _zone_alpha(zone))
	var points := _zone_points(zone, pulse)
	draw_colored_polygon(points, color)

	var outline := _with_alpha(color, min(1.0, color.a + 0.22))
	draw_polyline(_closed_points(points), outline, 1.4, true)

	if not zone.module_tag.is_empty():
		var marker_color := _with_alpha(outline, 0.9)
		draw_circle(zone.local_position, max(3.0, zone.radius * 0.12), marker_color)


func _draw_runtime_state(pulse: float) -> void:
	if runtime_state.energy <= 0.0:
		return

	var color := Color(0.98, 0.9, 0.42, 0.16 * runtime_state.energy)
	var radius := blueprint.body_radius * 0.24 * pulse
	draw_circle(Vector2.ZERO, radius, color)


func _draw_debug_overlay() -> void:
	var color := _with_alpha(render_config.debug_color, 0.8)
	var axis_length := blueprint.body_radius * blueprint.body_scale.x
	draw_line(Vector2.ZERO, Vector2.RIGHT * axis_length, color, 1.0, true)
	draw_line(Vector2.ZERO, Vector2.LEFT * axis_length * 0.35, _with_alpha(color, 0.35), 1.0, true)
	_draw_surface_segments_debug()

	for zone in blueprint.zones:
		if zone.kind == BodyZone.Kind.SHELL:
			continue
		draw_circle(zone.local_position, 2.5, color)
		draw_polyline(_closed_points(_zone_points(zone, 1.0)), _with_alpha(color, 0.42), 1.0, true)


func _draw_surface_segments_debug() -> void:
	if blueprint.surface_segments.is_empty():
		return

	var base_color := _with_alpha(render_config.debug_color, 0.34)
	for segment in blueprint.surface_segments:
		var marker_color := base_color
		if not segment.module_tag.is_empty():
			marker_color = _with_alpha(_module_debug_color(segment.module_tag), 0.86)
		var outer := segment.center_position
		var inner := outer - segment.normal * 7.0
		var normal_end := outer + segment.normal * 11.0
		draw_line(inner, outer, marker_color, 1.0, true)
		if not segment.module_tag.is_empty():
			draw_line(outer, normal_end, marker_color, 1.8, true)
			draw_circle(outer, 3.0, marker_color)


func _silhouette_points(radius_offset: float, pulse: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	var segments := 96
	var radius: float = max(8.0, blueprint.body_radius + radius_offset)
	for index in range(segments):
		var angle := TAU * float(index) / float(segments)
		var wobble := sin(angle * 3.0 + _animation_time * 1.25 + float(blueprint.seed) * 0.01) * render_config.wobble_strength
		wobble += sin(angle * 7.0 - _animation_time * 0.65) * render_config.wobble_strength * 0.32
		var radial: float = radius + wobble
		var point := Vector2(
			cos(angle) * radial * blueprint.body_scale.x,
			sin(angle) * radial * blueprint.body_scale.y
		) * pulse
		points.append(point)
	return points


func _zone_points(zone: BodyZone, pulse: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	var segments := 40
	if zone.kind == BodyZone.Kind.STRUCTURAL:
		segments = 24

	for index in range(segments):
		var angle := TAU * float(index) / float(segments)
		var wobble := 0.0
		if zone.kind == BodyZone.Kind.FLUID:
			wobble = sin(angle * 2.0 + _animation_time * 1.5 + float(blueprint.seed) * 0.03) * render_config.wobble_strength * 0.18
		var local_radius: float = max(2.0, zone.radius + wobble)
		var point := Vector2(
			cos(angle) * local_radius * zone.stretch.x,
			sin(angle) * local_radius * zone.stretch.y
		)
		point = point.rotated(zone.rotation)
		point = zone.local_position + point * pulse
		points.append(point)
	return points


func _closed_points(points: PackedVector2Array) -> PackedVector2Array:
	var closed := PackedVector2Array()
	for point in points:
		closed.append(point)
	if points.size() > 0:
		closed.append(points[0])
	return closed


func _zone_alpha(zone: BodyZone) -> float:
	match zone.kind:
		BodyZone.Kind.FLUID:
			return render_config.interior_alpha
		BodyZone.Kind.STRUCTURAL:
			return 0.72
		BodyZone.Kind.CORE:
			return 0.82
		BodyZone.Kind.PHOTOSYNTHETIC:
			return 0.76
		BodyZone.Kind.INTAKE:
			return 0.78
		_:
			return 0.65


func _material_color(material_id: String) -> Color:
	var color := render_config.fluid_color
	match material_id:
		"shell":
			color = render_config.shell_color
		"fluid":
			color = render_config.fluid_color
		"structural":
			color = render_config.structural_color
		"core":
			color = render_config.core_color
		"photosynthetic":
			color = render_config.photosynthesis_color
		"intake":
			color = render_config.intake_color

	if render_config.use_blueprint_hue and material_id in ["shell", "fluid", "structural"]:
		var hue_color := Color.from_hsv(wrapf(blueprint.pigment_hue, 0.0, 1.0), 0.58, 0.92, color.a)
		color = color.lerp(hue_color, render_config.hue_blend)
	return color


func _module_debug_color(module_tag: String) -> Color:
	match module_tag:
		"photosynthesis":
			return render_config.photosynthesis_color
		"intake":
			return render_config.intake_color
		_:
			return render_config.debug_color


func _with_alpha(color: Color, alpha: float) -> Color:
	var copy := color
	copy.a = clampf(alpha, 0.0, 1.0)
	return copy
