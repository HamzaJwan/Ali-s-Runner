## harbor_ambient_sway.gd
## Attach to any Node2D (rope, flag, palm leaf, mast) for gentle wind sway.
## No collision, no gameplay effect, purely decorative.
class_name HarborAmbientSway
extends Node2D

@export var max_angle_deg: float = 5.0   # peak swing in degrees
@export var period: float        = 1.9   # seconds per full cycle
@export var phase_offset: float  = 0.0   # stagger independent elements

var _time: float = 0.0


func _ready() -> void:
	_time = phase_offset


func _process(delta: float) -> void:
	_time += delta
	rotation_degrees = sin(_time * TAU / period) * max_angle_deg
