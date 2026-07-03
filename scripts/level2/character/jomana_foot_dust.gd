## jomana_foot_dust.gd — Subtle stone-dust puff at Jomana's feet.
## Attach to a CPUParticles2D node parented to the Player.
## Call emit_run_puff() on contact frames; emit_land_puff() on landing.
## Very low count — web/mobile safe.
extends CPUParticles2D

const RUN_PUFF_AMOUNT  := 4
const LAND_PUFF_AMOUNT := 8
const DUST_COLOR := Color(0.72, 0.66, 0.52, 0.55)   # warm stone dust

## Set to false to disable without removing node.
@export var enabled: bool = true


func _ready() -> void:
	_configure()


func _configure() -> void:
	amount         = 0       # always emit via restart()
	lifetime       = 0.35
	one_shot       = true
	emitting       = false
	explosiveness  = 0.85
	randomness     = 0.4
	direction      = Vector2(-1.0, -1.0).normalized()
	spread         = 55.0
	gravity        = Vector2(0, 200.0)
	initial_velocity_min = 18.0
	initial_velocity_max = 35.0
	scale_amount_min = 1.5
	scale_amount_max = 3.5
	color          = DUST_COLOR


func emit_run_puff() -> void:
	if not enabled:
		return
	amount = RUN_PUFF_AMOUNT
	restart()
	emitting = true


func emit_land_puff() -> void:
	if not enabled:
		return
	amount = LAND_PUFF_AMOUNT
	restart()
	emitting = true
