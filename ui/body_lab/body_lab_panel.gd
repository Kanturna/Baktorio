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

var current_seed: int = 1
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


func _ready() -> void:
	if body_lab_config == null:
		body_lab_config = BodyLabConfig.new()
	if gene_config == null:
		gene_config = GeneConfig.new()
	if render_config == null:
		render_config = RenderConfig.new()

	_resolve_nodes()
	_connect_controls()
	current_seed = body_lab_config.seed
	_sync_seed_spin()
	regenerate()


func regenerate() -> void:
	current_genome = GenomeFactory.from_seed(current_seed, gene_config)
	current_blueprint = BlueprintBuilder.new().build(current_genome, body_lab_config)
	current_runtime_state = OrganismRuntimeState.from_blueprint(current_blueprint)

	if _renderer != null:
		_renderer.configure(current_blueprint, current_runtime_state, render_config)
	if _inspector != null:
		_inspector.display(current_genome, current_blueprint, current_runtime_state)
	if _variant_label != null:
		_variant_label.text = "Seed %d | Modules: %s | Zones: %d" % [
			current_seed,
			", ".join(current_blueprint.module_tags),
			current_blueprint.zones.size()
		]


func _resolve_nodes() -> void:
	_renderer = get_node_or_null(renderer_path) as CellRenderer
	_inspector = get_node_or_null(inspector_path) as BlueprintInspector
	_seed_spin = get_node_or_null(seed_spin_path) as SpinBox
	_generate_button = get_node_or_null(generate_button_path) as Button
	_previous_button = get_node_or_null(previous_button_path) as Button
	_next_button = get_node_or_null(next_button_path) as Button
	_random_button = get_node_or_null(random_button_path) as Button
	_variant_label = get_node_or_null(variant_label_path) as Label


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


func _sync_seed_spin() -> void:
	if _seed_spin != null:
		_seed_spin.value = current_seed


func _set_seed(seed: int) -> void:
	current_seed = max(1, seed)
	_sync_seed_spin()
	regenerate()


func _on_seed_value_changed(value: float) -> void:
	current_seed = int(value)


func _on_generate_pressed() -> void:
	if _seed_spin != null:
		current_seed = int(_seed_spin.value)
	regenerate()


func _on_previous_pressed() -> void:
	_set_seed(current_seed - 1)


func _on_next_pressed() -> void:
	_set_seed(current_seed + 1)


func _on_random_pressed() -> void:
	var mixed := SeededRng.mix_seed(Time.get_ticks_msec(), current_seed + 31)
	_set_seed(1 + mixed % 999999998)
