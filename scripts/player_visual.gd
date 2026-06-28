class_name AliPlayerVisual
extends Sprite2D

const ASSET_UTILS := preload("res://scripts/asset_utils.gd")
const VISUAL_HEIGHT := 100.0
const FEET_Y := 24.0
const RUN_ANIMATION_FPS := 10.0

const IDLE := &"idle"
const RUN := &"run"
const JUMP := &"jump"
const FALL := &"fall"
const LAND := &"land"
const SLIDE := &"slide"
const HURT := &"hurt"
const VICTORY := &"victory"

const POSE_PATHS := {
	IDLE: "res://assets/characters/ali/ali_idle.png",
	RUN: "res://assets/characters/ali/ali_run.png",
	JUMP: "res://assets/characters/ali/ali_jump.png",
	FALL: "res://assets/characters/ali/ali_fall.png",
	LAND: "res://assets/characters/ali/ali_land.png",
	SLIDE: "res://assets/characters/ali/ali_slide.png",
	HURT: "res://assets/characters/ali/ali_hurt.png",
	VICTORY: "res://assets/characters/ali/ali_victory.png",
}
const RUN_FRAME_PATHS := [
	"res://assets/characters/ali/ali_run_1.png",
	"res://assets/characters/ali/ali_run_2.png",
	"res://assets/characters/ali/ali_run_3.png",
	"res://assets/characters/ali/ali_run_4.png",
]
const RUN_FRAME_1_COMPATIBILITY_PATH := \
	"res://assets/characters/ali/ali_run1.png"

# Code-side visual calibration (v1.26A). The pose/run-frame PNGs were not all
# cropped/exported at a consistent visible-rect height, so naively scaling
# every texture to hit VISUAL_HEIGHT from its own crop makes some poses look
# too large relative to ali_idle.png. These overrides correct only the
# confirmed-bad cases instead of re-deriving every pose's "ideal" size from
# scratch. Measured visible-rect heights (non-transparent bounding box):
# idle=474 (auto scale 0.211, treated as the reference), land=241 (auto scale
# 0.415 — nearly 2x idle, the "giant landing pose" bug), run frames
# 1/3/4=~513-517 (auto scale ~0.193-0.195) but run frame 2=981 (auto scale
# 0.102, roughly half the others — the run-cycle "pulse" bug).
const POSE_SCALE_OVERRIDES := {
	LAND: 0.224,
}
const RUN_FRAME_SCALE_OVERRIDES := {
	0: 0.194,
	1: 0.194,
	2: 0.194,
	3: 0.194,
}

var current_pose := &""
var run_frame_textures: Array[Texture2D] = []
var run_anim_time := 0.0
var run_frame_index := 0
var _pose_textures: Dictionary = {}
var _native_pose_available: Dictionary = {}
var _texture_layouts: Dictionary = {}
var _single_run_texture: Texture2D


func _ready() -> void:
	_load_pose_slots()
	_load_run_frames()
	show_pose(IDLE)


func show_pose(pose: StringName, force_refresh: bool = false) -> bool:
	if pose != RUN:
		_reset_run_animation()
	if pose == current_pose and not force_refresh:
		return _native_pose_available.get(pose, false)
	current_pose = pose
	if pose == RUN and not run_frame_textures.is_empty():
		_apply_texture(run_frame_textures[0], RUN_FRAME_SCALE_OVERRIDES.get(0, -1.0))
		return true

	texture = _pose_textures.get(pose)
	if texture == null:
		visible = false
		return false

	_apply_texture(texture, POSE_SCALE_OVERRIDES.get(pose, -1.0))
	return _native_pose_available.get(pose, false)


func update_visual(delta: float, requested_pose: StringName) -> bool:
	var native_pose_available := show_pose(requested_pose)
	if requested_pose != RUN or run_frame_textures.is_empty():
		return native_pose_available

	run_anim_time += delta
	var frame_duration := 1.0 / RUN_ANIMATION_FPS
	while run_anim_time >= frame_duration:
		run_anim_time -= frame_duration
		run_frame_index = (run_frame_index + 1) % run_frame_textures.size()
		_apply_texture(
			run_frame_textures[run_frame_index],
			RUN_FRAME_SCALE_OVERRIDES.get(run_frame_index, -1.0)
		)
	return true


func has_texture() -> bool:
	return texture != null


func has_native_pose(pose: StringName) -> bool:
	return _native_pose_available.get(pose, false)


func _load_pose_slots() -> void:
	var idle_texture := ASSET_UTILS.load_texture_with_fallback(POSE_PATHS[IDLE])
	_pose_textures[IDLE] = idle_texture
	_native_pose_available[IDLE] = idle_texture != null
	_log_pose_result(IDLE, idle_texture != null, false)

	_single_run_texture = ASSET_UTILS.load_texture_with_fallback(POSE_PATHS[RUN])
	_pose_textures[RUN] = (
		_single_run_texture if _single_run_texture != null else idle_texture
	)
	_native_pose_available[RUN] = _single_run_texture != null

	for pose: StringName in [JUMP, FALL, LAND, SLIDE, HURT, VICTORY]:
		var pose_texture := ASSET_UTILS.load_texture_with_fallback(POSE_PATHS[pose])
		var loaded := pose_texture != null
		_native_pose_available[pose] = loaded
		_pose_textures[pose] = pose_texture if loaded else idle_texture
		_log_pose_result(pose, loaded, idle_texture != null)


func _load_run_frames() -> void:
	for frame_index in RUN_FRAME_PATHS.size():
		var frame_path: String = RUN_FRAME_PATHS[frame_index]
		var loaded_path := frame_path
		var frame_texture := ASSET_UTILS.load_texture_with_fallback(frame_path)
		if frame_texture == null and frame_index == 0:
			frame_texture = ASSET_UTILS.load_texture_with_fallback(
				RUN_FRAME_1_COMPATIBILITY_PATH
			)
			if frame_texture != null:
				loaded_path = RUN_FRAME_1_COMPATIBILITY_PATH
		if frame_texture == null:
			print("[ali_run] frame ", frame_index + 1, " missing; skipped")
			continue
		run_frame_textures.append(frame_texture)
		print("[ali_run] frame ", frame_index + 1, " loaded: ", loaded_path)

	if not run_frame_textures.is_empty():
		_native_pose_available[RUN] = true
		print("[ali_run] using ", run_frame_textures.size(),
			" cached run frames at ", RUN_ANIMATION_FPS, " FPS")
	elif _single_run_texture != null:
		print("[ali_run] run frames missing; using ali_run.png")
	elif _pose_textures[IDLE] != null:
		print("[ali_run] run frames and ali_run.png missing; using idle fallback")
	else:
		print("[ali_run] no run or idle images; using blue placeholder")


func _reset_run_animation() -> void:
	run_anim_time = 0.0
	run_frame_index = 0


func _apply_texture(next_texture: Texture2D, scale_override: float = -1.0) -> void:
	texture = next_texture
	if texture == null:
		visible = false
		return

	visible = true
	centered = true
	if not _texture_layouts.has(texture):
		_texture_layouts[texture] = _calculate_texture_layout(next_texture, scale_override)
	var layout: Dictionary = _texture_layouts[texture]
	scale = layout["scale"]
	position = layout["position"]


func _calculate_texture_layout(
		next_texture: Texture2D, scale_override: float = -1.0
) -> Dictionary:
	var visible_rect := ASSET_UTILS.get_texture_visible_rect(next_texture)
	if visible_rect.size.y <= 0.0:
		return {"scale": Vector2.ONE, "position": Vector2.ZERO}
	var uniform_scale := (
		scale_override if scale_override > 0.0
		else VISUAL_HEIGHT / visible_rect.size.y
	)
	var next_scale := Vector2(uniform_scale, uniform_scale)
	var texture_origin := next_texture.get_size() / 2.0
	var visible_center_x := visible_rect.position.x + visible_rect.size.x / 2.0
	var visible_bottom := visible_rect.position.y + visible_rect.size.y
	return {
		"scale": next_scale,
		"position": Vector2(
			-(visible_center_x - texture_origin.x) * next_scale.x,
			FEET_Y - (visible_bottom - texture_origin.y) * next_scale.y
		),
	}


func _log_pose_result(
		pose: StringName, loaded: bool, using_idle_fallback: bool
) -> void:
	if loaded:
		print("[ali_pose] ", pose, " loaded: ", POSE_PATHS[pose])
	elif using_idle_fallback:
		print("[ali_pose] ", pose, " missing; using idle fallback")
	else:
		print("[ali_pose] ", pose, " missing; using blue placeholder")
