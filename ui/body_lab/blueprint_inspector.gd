class_name BlueprintInspector
extends RichTextLabel


func _ready() -> void:
	fit_content = true
	scroll_active = true
	bbcode_enabled = false


func display(genome: Genome, blueprint: BodyBlueprint, runtime_state: OrganismRuntimeState) -> void:
	var sections: Array[String] = []
	if genome != null:
		sections.append(genome.to_debug_text())
	if blueprint != null:
		sections.append(blueprint.to_debug_text())
	if runtime_state != null:
		sections.append(runtime_state.to_debug_text())
	text = "\n\n".join(sections)
