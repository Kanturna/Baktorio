class_name BodyLabPanel
extends Control

@export var body_lab_config: BodyLabConfig
@export var gene_config: GeneConfig
@export var render_config: RenderConfig

@export var renderer_path: NodePath
@export var inspector_path: NodePath
@export var seed_spin_path: NodePath
@export var generate_button_path: NodePath
@export var previous_button_path: NodePath
@export var next_button_path: NodePath
@export var random_button_path: NodePath
@export var variant_label_path: NodePath
@export var debug_overlay_check_path: NodePath

var current_seed: int = 1
var review_index: int = 0
var current_genome: Genome
var current_blueprint: BodyBlueprint
var current_runtime_state: OrganismRuntimeState

var _renderer: CellRenderer
var _inspector: BlueprintInspector
var _seed_spin: SpinBox
var _generate_button: Button
var _previous_button: Button
var _next_button: Button
var _random_button: Button
var _variant_label: Label
var _debug_overlay_check: CheckBox
var _runtime_render_config: RenderConfig
var _syncing_controls: bool = false


func _ready() -> void:
	if body_lab_config == null:
		body_lab_config = BodyLabConfig.new()
	if gene_config == null:
		gene_config = GeneConfig.new()
	if render_config == null:
		render_config = RenderConfig.new()
	_runtime_render_config = render_config.duplicate(true) as RenderConfig

	_resolve_nodes()
	_connect_controls()
	review_index = 0
	current_seed = _seed_for_review_index(review_index)
	_sync_controls()
	regenerate()


func regenerate() -> void:
	current_genome = GenomeFactory.from_seed(current_seed, gene_config)
	current_blueprint = BlueprintBuilder.new().build(current_genome, body_lab_config)
	current_runtime_state = OrganismRuntimeState.from_blueprint(current_blueprint)

	if _renderer != null:
		_renderer.configure(current_blueprint, current_runtime_state, _runtime_render_config)
	if _inspector != null:
		_inspector.display(current_genome, current_blueprint, current_runtime_state)
	_update_variant_label()
	_sync_navigation_controls()


func _resolve_nodes() -> void:
	_renderer = get_node_or_null(renderer_path) as CellRenderer
	_inspector = get_node_or_null(inspector_path) as BlueprintInspector
	_seed_spin = get_node_or_null(seed_spin_path) as SpinBox
	_generate_button = get_node_or_null(generate_button_path) as Button
	_previous_button = get_node_or_null(previous_button_path) as Button
	_next_button = get_node_or_null(next_button_path) as Button
	_random_button = get_node_or_null(random_button_path) as Button
	_variant_label = get_node_or_null(variant_label_path) as Label
	_debug_overlay_check = get_node_or_null(debug_overlay_check_path) as CheckBox


func _connect_controls() -> void:
	if _seed_spin != null:
		_seed_spin.min_value = 1.0
		_seed_spin.max_value = 999999999.0
		_seed_spin.step = 1.0
		_seed_spin.value_changed.connect(_on_seed_value_changed)
	if _generate_button != null:
		_generate_button.pressed.connect(_on_generate_pressed)
	if _previous_button != null:
		_previous_button.pressed.connect(_on_previous_pressed)
	if _next_button != null:
		_next_button.pressed.connect(_on_next_pressed)
	if _random_button != null:
		_random_button.pressed.connect(_on_random_pressed)
	if _debug_overlay_check != null:
		_debug_overlay_check.toggled.connect(_on_debug_overlay_toggled)


func _sync_controls() -> void:
	_syncing_controls = true
	if _seed_spin != null:
		_seed_spin.value = current_seed
	if _debug_overlay_check != null:
		_debug_overlay_check.button_pressed = _runtime_render_config.show_debug_overlay
	_syncing_controls = false
	_sync_navigation_controls()


func _sync_seed_spin() -> void:
	_syncing_controls = true
	if _seed_spin != null:
		_seed_spin.value = current_seed
	_syncing_controls = false


func _sync_navigation_controls() -> void:
	var in_review_range := _is_current_seed_in_review_range()
	if _previous_button != null:
		_previous_button.disabled = not in_review_range or review_index <= 0
	if _next_button != null:
		_next_button.disabled = not in_review_range or review_index >= _review_seed_count() - 1


func _set_seed(seed_value: int) -> void:
	current_seed = max(1, seed_value)
	var matching_index := _review_index_for_seed(current_seed)
	if matching_index >= 0:
		review_index = matching_index
	_sync_seed_spin()
	regenerate()


func _set_review_index(new_review_index: int) -> void:
	review_index = clampi(new_review_index, 0, _review_seed_count() - 1)
	current_seed = _seed_for_review_index(review_index)
	_sync_seed_spin()
	regenerate()


func _seed_for_review_index(index: int) -> int:
	return _review_seed_start() + clampi(index, 0, _review_seed_count() - 1)


func _review_index_for_seed(seed_value: int) -> int:
	var offset := seed_value - _review_seed_start()
	if offset < 0 or offset >= _review_seed_count():
		return -1
	return offset


func _is_current_seed_in_review_range() -> bool:
	return _review_index_for_seed(current_seed) >= 0


func _review_seed_start() -> int:
	return max(1, body_lab_config.review_seed_start)


func _review_seed_count() -> int:
	return max(1, body_lab_config.review_seed_count)


func _update_variant_label() -> void:
	if _variant_label == null or current_blueprint == null:
		return

	var review_state := "off-review"
	if _is_current_seed_in_review_range():
		review_state = "Review %02d/%02d" % [review_index + 1, _review_seed_count()]

	_variant_label.text = "%s | Seed %d | Modules: %s | Zones: %d | Materials: %s" % [
		review_state,
		current_seed,
		", ".join(current_blueprint.module_tags),
		current_blueprint.zones.size(),
		_material_balance_summary(current_blueprint.material_balance)
	]


func _material_balance_summary(material_balance: Dictionary) -> String:
	var parts: Array[String] = []
	var keys := material_balance.keys()
	keys.sort()
	for key in keys:
		parts.append("%s %.0f%%" % [str(key), float(material_balance[key]) * 100.0])
	return ", ".join(parts)


func _on_seed_value_changed(value: float) -> void:
	if _syncing_controls:
		return
	_set_seed(int(value))


func _on_generate_pressed() -> void:
	if _seed_spin != null:
		_set_seed(int(_seed_spin.value))


func _on_previous_pressed() -> void:
	if _is_current_seed_in_review_range():
		_set_review_index(review_index - 1)


func _on_next_pressed() -> void:
	if _is_current_seed_in_review_range():
		_set_review_index(review_index + 1)


func _on_random_pressed() -> void:
	var mixed := SeededRng.mix_seed(Time.get_ticks_msec(), current_seed + 31)
	_set_seed(1 + mixed % 999999998)


func _on_debug_overlay_toggled(button_pressed: bool) -> void:
	if _syncing_controls:
		return
	_runtime_render_config.show_debug_overlay = button_pressed
	if _renderer != null:
		_renderer.configure(current_blueprint, current_runtime_state, _runtime_render_config)
