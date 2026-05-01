class_name BodyLabConfig
extends Resource

@export var seed: int = 1001
@export_range(1, 64, 1) var preview_variant_count: int = 24
@export_range(32.0, 220.0, 1.0) var min_body_radius: float = 72.0
@export_range(32.0, 260.0, 1.0) var max_body_radius: float = 132.0
@export_range(1, 5, 1) var max_shell_layers: int = 3
@export_range(1, 8, 1) var min_fluid_zones: int = 2
@export_range(1, 12, 1) var max_fluid_zones: int = 5
@export_range(0, 10, 1) var max_structural_zones: int = 4
@export_range(0.0, 1.0, 0.01) var optional_module_threshold: float = 0.62
@export_range(0.0, 1.0, 0.01) var asymmetry_strength: float = 0.28
