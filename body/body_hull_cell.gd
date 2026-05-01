class_name BodyHullCell
extends Resource

@export var cell_id: String = ""
@export var index: int = 0
@export var angle_start: float = 0.0
@export var angle_end: float = 0.0
@export var center_position: Vector2 = Vector2.ZERO
@export var normal: Vector2 = Vector2.RIGHT
@export var module_tag: String = ""
@export var linked_zone_ids: Array[String] = []


func summary() -> String:
	var module_suffix := ""
	if not module_tag.is_empty():
		module_suffix = " module=%s" % module_tag
	var link_suffix := ""
	if not linked_zone_ids.is_empty():
		link_suffix = " links=%s" % ", ".join(linked_zone_ids)
	return "%s idx=%d angle=%.2f..%.2f%s%s" % [
		cell_id,
		index,
		angle_start,
		angle_end,
		module_suffix,
		link_suffix,
	]
