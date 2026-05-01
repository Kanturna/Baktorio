class_name BodyZone
extends Resource

enum Kind {
	SHELL,
	FLUID,
	STRUCTURAL,
	CORE,
	PHOTOSYNTHETIC,
	INTAKE,
}

@export var zone_id: String = ""
@export var kind: Kind = Kind.FLUID
@export var material_id: String = "fluid"
@export var local_position: Vector2 = Vector2.ZERO
@export var radius: float = 16.0
@export var stretch: Vector2 = Vector2.ONE
@export var rotation: float = 0.0
@export_range(0.0, 1.0, 0.01) var strength: float = 1.0
@export var module_tag: String = ""


func kind_label() -> String:
	return kind_to_label(kind)


func summary() -> String:
	var module_suffix := ""
	if not module_tag.is_empty():
		module_suffix = " module=%s" % module_tag
	var rounded_position := Vector2(roundf(local_position.x), roundf(local_position.y))
	return "%s %s pos=%s r=%.1f%s" % [zone_id, kind_label(), rounded_position, radius, module_suffix]


static func kind_to_label(value: Kind) -> String:
	match value:
		Kind.SHELL:
			return "shell"
		Kind.FLUID:
			return "fluid"
		Kind.STRUCTURAL:
			return "structural"
		Kind.CORE:
			return "core"
		Kind.PHOTOSYNTHETIC:
			return "photosynthetic"
		Kind.INTAKE:
			return "intake"
		_:
			return "unknown"
