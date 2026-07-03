## level2_camera_controller.gd
## Production camera controller for Level 2 جمانة وأثر الكلمة.
## Wire to Camera2D in Level2_Marsa_Playable.tscn once ready.
## Currently the playable scene uses inline tween calls in level2_marsa_playable.gd.
## Migrate to this controller in a future camera-lane sprint.
##
## Features planned (camera lane — one coder only):
##   - stable runner framing with look-ahead
##   - harbour establishing reveal
##   - checkpoint micro-focus zoom
##   - ending pier reveal
extends Camera2D

const VIEW_W        := 1152.0
const VIEW_H        := 648.0
const GAMEPLAY_ZOOM := 1.18
const SCREEN_X      := 230.0
const SCREEN_Y      := 498.0
const ROAD_Y        := 510.0
const PLAYER_X      := 220.0
const LOOK_AHEAD_PX := 26.0
const LOOK_SPEED    := 5.0
const TRANS_TIME    := 0.38

@export var auto_demo: bool = false

var _gameplay_pos: Vector2
var _look_x: float = 0.0
var _tracking: bool = false
var _player_ref: CharacterBody2D = null
var _tween: Tween


func _ready() -> void:
	_gameplay_pos = _solve(PLAYER_X, ROAD_Y)
	if auto_demo:
		_play_reveal()
	else:
		position = _gameplay_pos
		zoom = Vector2(GAMEPLAY_ZOOM, GAMEPLAY_ZOOM)


func bind_player(p: CharacterBody2D) -> void:
	_player_ref = p


func enable_tracking() -> void:
	_tracking = true
	_look_x = _gameplay_pos.x


func apply_gameplay() -> void:
	_tracking = false
	_tween_to(_gameplay_pos, Vector2(GAMEPLAY_ZOOM, GAMEPLAY_ZOOM), TRANS_TIME)
	enable_tracking()


func apply_default() -> void:
	_tracking = false
	_tween_to(Vector2(VIEW_W / 2.0, VIEW_H / 2.0), Vector2.ONE, TRANS_TIME)


func apply_checkpoint_focus() -> void:
	_tracking = false
	_tween_to(_gameplay_pos, Vector2(GAMEPLAY_ZOOM * 1.04, GAMEPLAY_ZOOM * 1.04), TRANS_TIME)


func _play_reveal() -> void:
	position = Vector2(VIEW_W / 2.0, VIEW_H / 2.0 + 30.0)
	zoom = Vector2(0.82, 0.82)
	_tween_to(_gameplay_pos, Vector2(GAMEPLAY_ZOOM, GAMEPLAY_ZOOM), 2.0)


func _process(delta: float) -> void:
	if not _tracking or _player_ref == null:
		return
	var vx: float = _player_ref.velocity.x if "velocity" in _player_ref else 0.0
	var dir := signf(vx) if absf(vx) > 10.0 else 1.0
	var desired := _gameplay_pos.x - (LOOK_AHEAD_PX / zoom.x) * dir
	_look_x = lerpf(_look_x, desired, LOOK_SPEED * delta)
	position.x = _look_x


func _tween_to(tp: Vector2, tz: Vector2, dur: float) -> void:
	if position.is_equal_approx(tp) and zoom.is_equal_approx(tz):
		return
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween().set_parallel()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.tween_property(self, "position", tp, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "zoom", tz, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _solve(px: float, ry: float) -> Vector2:
	return Vector2(
		px - (SCREEN_X - VIEW_W / 2.0) / GAMEPLAY_ZOOM,
		ry - (SCREEN_Y - VIEW_H / 2.0) / GAMEPLAY_ZOOM,
	)
