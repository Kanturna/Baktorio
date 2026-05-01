class_name OrganismRuntimeState
extends Resource

@export var alive: bool = true
@export_range(0.0, 1.0, 0.01) var energy: float = 0.75
@export_range(0.0, 1.0, 0.01) var stress: float = 0.0
@export var module_activity: Dictionary = {}


static func from_blueprint(blueprint: BodyBlueprint) -> OrganismRuntimeState:
	var state := OrganismRuntimeState.new()
	for module_tag in blueprint.module_tags:
		state.module_activity[module_tag] = 1.0
	return state


func to_debug_text() -> String:
	var lines: Array[String] = []
	lines.append("Runtime")
	lines.append("alive: %s" % str(alive))
	lines.append("energy: %.2f" % energy)
	lines.append("stress: %.2f" % stress)
	var module_keys := module_activity.keys()
	module_keys.sort()
	for key in module_keys:
		lines.append("%s activity: %.2f" % [str(key), float(module_activity[key])])
	return "\n".join(lines)
