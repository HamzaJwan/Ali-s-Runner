## level2_camera_preview.gd
## LookDev-only camera preview for Level 2 مرسى زليتن.
## Shows three intended cinematic states:
##   1. Establishing reveal (slightly zoomed-out harbor pan)
##   2. Gameplay framing (stable runner position)
##   3. Checkpoint focus (gentle zoom-in on encounter)
##
## NOT a production camera controller — wiring to gameplay happens later.
extends Camera2D

const VIEW_W := 1152.0
const VIEW_H := 648.0

# Gameplay framing constants (same algebra as Level 1 main.gd)
const GAMEPLAY_ZOOM   := 1.18          # slightly deeper for harbor
const PLAYER_SCREEN_X := 230.0
const PLAYER_SCREEN_Y := 498.0
const ROAD_Y          := 510.0
const PLAYER_START_X  := 220.0

const REVEAL_ZOOM     := 0.82
const REVEAL_DURATION := 2.2
const CHECKPOINT_ZOOM := GAMEPLAY_ZOOM * 1.05
const TRANS_DURATION  := 0.45

# Cycle demo
const DEMO_HOLD_GAMEPLAY := 4.0
const DEMO_HOLD_CHECKPOINT := 2.5

@export var auto_demo: bool = true  # set false to freeze at gameplay framing

var _gameplay_pos: Vector2
var _phase: int = 0   # 0=reveal, 1=gameplay, 2=checkpoint, loop
var _phase_timer: float = 0.0
var _tween: Tween


func _ready() -> void:
	_gameplay_pos = _solve_pos(PLAYER_START_X, ROAD_Y)
	if auto_demo:
		_play_reveal()
	else:
		position = _gameplay_pos
		zoom = Vector2(GAMEPLAY_ZOOM, GAMEPLAY_ZOOM)


func _process(delta: float) -> void:
	if not auto_demo:
		return
	_phase_timer += delta
	match _phase:
		1:  # gameplay — wait, then go to checkpoint
			if _phase_timer >= DEMO_HOLD_GAMEPLAY:
				_phase_timer = 0.0
				_phase = 2
				_play_checkpoint()
		2:  # checkpoint — wait, then loop back
			if _phase_timer >= DEMO_HOLD_CHECKPOINT:
				_phase_timer = 0.0
				_phase = 0
				_play_reveal()


func _play_reveal() -> void:
	position = Vector2(VIEW_W / 2.0, VIEW_H / 2.0 + 30.0)
	zoom = Vector2(REVEAL_ZOOM, REVEAL_ZOOM)
	_tween_to(_gameplay_pos, Vector2(GAMEPLAY_ZOOM, GAMEPLAY_ZOOM), REVEAL_DURATION)
	await get_tree().create_timer(REVEAL_DURATION).timeout
	_phase = 1
	_phase_timer = 0.0


func _play_checkpoint() -> void:
	_tween_to(_gameplay_pos, Vector2(CHECKPOINT_ZOOM, CHECKPOINT_ZOOM), TRANS_DURATION)


func _tween_to(tgt_pos: Vector2, tgt_zoom: Vector2, dur: float) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween().set_parallel()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.tween_property(self, "position", tgt_pos, dur) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(self, "zoom", tgt_zoom, dur) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _solve_pos(px: float, ry: float) -> Vector2:
	return Vector2(
		px - (PLAYER_SCREEN_X - VIEW_W / 2.0) / GAMEPLAY_ZOOM,
		ry - (PLAYER_SCREEN_Y - VIEW_H / 2.0) / GAMEPLAY_ZOOM,
	)
