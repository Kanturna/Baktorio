class_name BodyBlueprint
extends Resource

@export var seed: int = 1
@export var body_radius: float = 96.0
@export var body_scale: Vector2 = Vector2.ONE
@export var body_axis: Vector2 = Vector2.RIGHT
@export_range(0.0, 1.0, 0.01) var symmetry: float = 1.0
@export_range(0.0, 1.0, 0.01) var asymmetry: float = 0.0
@export_range(0.0, 1.0, 0.01) var complexity: float = 0.0
@export var shell_layers: int = 1
@export var pigment_hue: float = 0.5
@export var module_tags: Array[String] = []
@export var zones: Array[BodyZone] = []
@export var hull_cells: Array[BodyHullCell] = []
@export var material_balance: Dictionary = {}
@export var gene_snapshot: Dictionary = {}


func has_module(module_tag: String) -> bool:
	return module_tags.has(module_tag)


func zones_by_kind(kind: BodyZone.Kind) -> Array[BodyZone]:
	var matches: Array[BodyZone] = []
	for zone in zones:
		if zone.kind == kind:
			matches.append(zone)
	return matches


func to_debug_text() -> String:
	var lines: Array[String] = []
	lines.append("Blueprint seed: %d" % seed)
	lines.append("radius: %.1f scale: %s" % [body_radius, body_scale])
	lines.append("shell layers: %d" % shell_layers)
	lines.append("symmetry: %.2f asymmetry: %.2f complexity: %.2f" % [symmetry, asymmetry, complexity])
	lines.append("modules: %s" % ", ".join(module_tags))
	lines.append("")
	lines.append("Material balance:")
	var material_keys := material_balance.keys()
	material_keys.sort()
	for key in material_keys:
		lines.append("  %s: %.2f" % [str(key), float(material_balance[key])])
	lines.append("")
	lines.append("Zones:")
	for zone in zones:
		lines.append("  %s" % zone.summary())
	lines.append("")
	lines.append("Hull cells: %d" % hull_cells.size())
	for cell in hull_cells:
		if not cell.module_tag.is_empty() or cell.linked_zone_ids.size() > 1:
			lines.append("  %s" % cell.summary())
	return "\n".join(lines)
