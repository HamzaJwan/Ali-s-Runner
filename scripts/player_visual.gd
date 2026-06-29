class_name AliPlayerVisual
extends Sprite2D

const ASSET_UTILS := preload("res://scripts/asset_utils.gd")
const VISUAL_HEIGHT := 100.0
const FEET_Y := 24.0
const RUN_ANIMATION_FPS := 14.0

# --- Run cycle frame count ---
# A 4-frame run (today's actual asset set) is fully supported and is what
# every owner playtest so far has seen. An 8-frame run is the PREFERRED
# target for the final, smoothest feel - the loader below already scans up
# to RUN_FRAME_COUNT_MAX and will pick up frames 5-8 automatically the
# moment they exist on disk, with zero further code changes. When those
# frames are produced, they should share the same canvas size and the same
# feet baseline (same alpha-trim bottom-edge convention) as frames 1-4, so
# every frame normalizes to the same on-screen height/feet position the way
# ali_idle/ali_run_1..4 already do - that consistency is what the existing
# visible-bbox normalization in _calculate_texture_layout() depends on.
const RUN_FRAME_COUNT_MAX := 8

# Subtle per-frame vertical bob layered on top of the normal feet-aligned
# position, meant to fake a touch of inter-frame motion a low frame-count
# cycle can't otherwise convey. ONLY used in the legacy 4-frame fallback
# (run_frame_textures.size() <= RUN_FRAME_Y_OFFSET_MAX_FRAME_COUNT) - see
# _run_frame_y_offset(). Measured diagnostics on the real 8-frame set (see
# docs/AUTOPILOT_PROGRESS.md, v1.36C) showed the existing feet-pinning math
# in _calculate_texture_layout() already lands every frame's feet at
# exactly FEET_Y on its own; this dict only ever existed to compensate for
# the OLD 4-frame art having no body bob of its own. Applying it unevenly
# on top of 8 real frames (which already carry their own natural body-
# height variation from the artist's own poses) was a real, measured
# contributor to the reported run jitter, so it is gated off once enough
# real frames exist.
const RUN_FRAME_Y_OFFSETS := {
	0: 0.0,
	1: -1.5,
	2: 0.0,
	3: -1.5,
}
const RUN_FRAME_Y_OFFSET_MAX_FRAME_COUNT := 4

# Optional tiny per-frame lean, in radians. Left at 0.0 for every frame for
# now: rotating the sprite would pivot around its center, not its feet, so
# any non-zero value needs an owner-reviewed visual pass to confirm feet
# don't appear to lift/slide before it's turned on. The plumbing exists so
# that pass is a data-only change, not a new code change.
const RUN_FRAME_ROTATION := {}

# Per-stride ground-contact frames, used only for the dust accent in
# player.gd. A real running stride has exactly two ground-contact events
# (left foot down, right foot down) no matter how many in-between frames
# represent the cycle, so contact frames are always frame 0 and the
# half-cycle frame - [0, 2] for today's 4 frames, [0, 4] once 8 exist.
static func contact_frame_indices(frame_count: int) -> Array:
	if frame_count <= 0:
		return []
	return [0, frame_count / 2]

# ali_land.png's visible art is nearly square (measured ~239x241px) while
# every other pose is tall/thin (idle ~189x474, run frames ~385-426x513).
# Normalizing purely by height (like every other pose) forces LAND's width
# to balloon out to roughly its own height, reading as an oversized, "messed
# up" crouch. This is a per-pose override, not a per-run-frame one - the
# run-cycle pulsing bug fixed earlier was caused by exactly that kind of
# override on run frames, so this must never be applied to RUN_FRAME_PATHS.
const POSE_SCALE_OVERRIDES := {
	LAND: 0.33,
}

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
const RUN_FRAME_PATH_TEMPLATE := "res://assets/characters/ali/ali_run_%d.png"
const RUN_FRAME_1_COMPATIBILITY_PATH := \
	"res://assets/characters/ali/ali_run1.png"

var current_pose := &""
var run_frame_textures: Array[Texture2D] = []
var run_anim_time := 0.0
var run_frame_index := 0
var _pose_textures: Dictionary = {}
var _native_pose_available: Dictionary = {}
var _texture_layouts: Dictionary = {}
var _single_run_texture: Texture2D
var _run_frame_x_anchor := 0.0


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
		_apply_run_frame(0)
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
		_apply_run_frame(run_frame_index)
	return true


## Applies a run-cycle frame plus its tiny optional bob/lean. The base
## scale/position still comes entirely from _apply_texture()'s normal
## feet-aligned layout - this only ever adds a small, fixed per-frame
## offset on top, so it can never reintroduce the size-pulse or
## feet-baseline bugs fixed earlier (those were caused by the *scale*
## differing per frame/pose, not by a tiny position nudge).
func _apply_run_frame(frame_index: int) -> void:
	_apply_texture(run_frame_textures[frame_index])
	position.x = _run_frame_x_anchor
	position.y += _run_frame_y_offset(frame_index)
	rotation = RUN_FRAME_ROTATION.get(frame_index, 0.0)


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
	# Frames are a contiguous sequence starting at ali_run_1.png. A 4-frame
	# set (today's actual art) is fully supported; an 8-frame set (preferred
	# for the smoothest final feel) is picked up automatically the moment
	# ali_run_5.png..ali_run_8.png exist, with no further code changes. A
	# gap stops the scan rather than skipping it, so the cycle never plays
	# frames out of their intended order. This loads once, here, at _ready()
	# - never per-frame during gameplay.
	for frame_number in range(1, RUN_FRAME_COUNT_MAX + 1):
		var frame_index := frame_number - 1
		var frame_path := RUN_FRAME_PATH_TEMPLATE % frame_number
		var loaded_path := frame_path
		var frame_texture := ASSET_UTILS.load_texture_with_fallback(frame_path)
		if frame_texture == null and frame_index == 0:
			frame_texture = ASSET_UTILS.load_texture_with_fallback(
				RUN_FRAME_1_COMPATIBILITY_PATH
			)
			if frame_texture != null:
				loaded_path = RUN_FRAME_1_COMPATIBILITY_PATH
		if frame_texture == null:
			print("[ali_run] frame ", frame_number, " missing; using ",
				run_frame_textures.size(), " frame(s) for the run cycle")
			break
		run_frame_textures.append(frame_texture)
		print("[ali_run] frame ", frame_number, " loaded: ", loaded_path)

	if not run_frame_textures.is_empty():
		_native_pose_available[RUN] = true
		_compute_run_frame_x_anchor()
		print("[ali_run] using ", run_frame_textures.size(),
			" cached run frames at ", RUN_ANIMATION_FPS, " FPS",
			" x_anchor=", _run_frame_x_anchor)
	elif _single_run_texture != null:
		print("[ali_run] run frames missing; using ali_run.png")
	elif _pose_textures[IDLE] != null:
		print("[ali_run] run frames and ali_run.png missing; using idle fallback")
	else:
		print("[ali_run] no run or idle images; using blue placeholder")


## Measured diagnostics (docs/AUTOPILOT_PROGRESS.md, v1.36C) on the real
## 8-frame set showed each frame's own alpha-bbox horizontal center swings
## by up to ~3px frame-to-frame, because the source art's limb extension
## isn't symmetric about a fixed torso line in every pose. Centering each
## frame independently (the original approach) therefore reads as the
## whole sprite sliding left/right every frame - real, measured jitter.
## Averaging every loaded frame's own natural horizontal position once,
## here, and reusing that single anchor for all of them removes that
## frame-to-frame noise while leaving the per-frame vertical/feet math
## (which is already correct and frame-specific by design) untouched.
func _compute_run_frame_x_anchor() -> void:
	if run_frame_textures.is_empty():
		_run_frame_x_anchor = 0.0
		return
	var total_x := 0.0
	for frame_texture in run_frame_textures:
		var layout: Dictionary = _calculate_texture_layout(frame_texture)
		total_x += (layout["position"] as Vector2).x
	_run_frame_x_anchor = total_x / run_frame_textures.size()


## See RUN_FRAME_Y_OFFSETS' comment: only used while still on the legacy
## 4-frame (or fewer) fallback. A real 8-frame cycle already carries its
## own natural body bob and does not need (or want) this on top.
func _run_frame_y_offset(frame_index: int) -> float:
	if run_frame_textures.size() > RUN_FRAME_Y_OFFSET_MAX_FRAME_COUNT:
		return 0.0
	return RUN_FRAME_Y_OFFSETS.get(frame_index, 0.0)


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
	# Source images have different pixel dimensions; normalize their visible
	# character bounds instead of forcing the same numeric scale on every frame.
	# A small set of poses (see POSE_SCALE_OVERRIDES) have a visible aspect
	# ratio so different from the rest that pure height-normalization makes
	# them look broken, so they get an explicit, measured scale instead.
	var uniform_scale := (
		scale_override if scale_override > 0.0 else VISUAL_HEIGHT / visible_rect.size.y
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
