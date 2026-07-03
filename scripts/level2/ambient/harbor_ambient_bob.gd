## harbor_ambient_bob.gd
## Attach to any Node2D (boat, buoy, float) to make it gently bob up/down.
## No collision, no gameplay effect, purely decorative.
class_name HarborAmbientBob
extends Node2D

@export var amplitude: float = 3.5   # pixels up/down
@export var period: float    = 2.6   # seconds for one full cycle
@export var phase_offset: float = 0.0 # stagger multiple boats

var _base_y: float = 0.0
var _time: float = 0.0


func _ready() -> void:
	_base_y = position.y
	_time = phase_offset


func _process(delta: float) -> void:
	_time += delta
	position.y = _base_y + sin(_time * TAU / period) * amplitude
