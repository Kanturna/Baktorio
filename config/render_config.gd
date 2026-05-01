class_name RenderConfig
extends Resource

@export var shell_color: Color = Color(0.57, 0.76, 0.73, 1.0)
@export var fluid_color: Color = Color(0.37, 0.76, 0.94, 1.0)
@export var structural_color: Color = Color(0.94, 0.67, 0.36, 1.0)
@export var core_color: Color = Color(0.72, 0.42, 0.92, 1.0)
@export var photosynthesis_color: Color = Color(0.47, 0.86, 0.38, 1.0)
@export var intake_color: Color = Color(0.94, 0.45, 0.39, 1.0)
@export var debug_color: Color = Color(0.96, 0.96, 0.78, 1.0)

@export_range(1.0, 16.0, 0.5) var shell_width: float = 5.0
@export_range(0.05, 0.8, 0.01) var shell_fill_alpha: float = 0.14
@export_range(0.05, 0.95, 0.01) var interior_alpha: float = 0.48
@export_range(0.0, 12.0, 0.1) var wobble_strength: float = 3.0
@export_range(0.0, 0.16, 0.005) var pulse_strength: float = 0.035
@export_range(0.0, 1.0, 0.01) var hue_blend: float = 0.25
@export var use_blueprint_hue: bool = true
@export var show_debug_overlay: bool = false
