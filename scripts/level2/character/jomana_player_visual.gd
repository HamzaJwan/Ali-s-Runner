## jomana_player_visual.gd — Jomana visual + animation system for Level 2.
##
## Drop-in asset pipeline: add PNGs to the manifest paths and reopen the scene.
## No code changes needed. Missing frames fall back to the polygon placeholder.
##
## F6 test flow:
##   No art  → teal polygon placeholder, "جمانة" label
##   8 run   → animated Jomana, placeholder hides
##   +idle   → idle animation at start/checkpoint
##   +jump   → jump frame during jump
##   +wave   → wave frame during checkpoint reward
extends Node2D

const MANIFEST   := preload("res://scripts/level2/level2_asset_manifest.gd")

const VISUAL_HEIGHT  := 160.0   # px — final on-screen character height
const CANVAS_HEIGHT  := 512.0   # all normalized frames are 512px tall
const CANVAS_WIDTH   := 384.0   # all normalized frames are 384px wide
const FOOT_OFFSET_Y  := 24.0    # match Player CharacterBody2D half-collision height
const BASE_RUN_FPS   := 11.0    # 10–12 FPS is the sweet spot
const MIN_SPD_SCALE  := 0.80
const MAX_SPD_SCALE  := 1.50
const BASELINE_SPEED := 225.0

enum Pose { IDLE, RUN, JUMP, LAND, STORY }

var _anim: AnimatedSprite2D = null
var _placeholder: Node2D    = null
var _using_placeholder := true
var _current_pose: Pose = Pose.IDLE


func _ready() -> void:
	_build_placeholder()
	_try_load_real_frames()


# ── Public API ────────────────────────────────────────────────────────────

func set_pose(pose: Pose) -> void:
	if _current_pose == pose:
		return
	_current_pose = pose
	if _using_placeholder:
		_placeholder_pose(pose)
	else:
		_play_anim(pose)


func is_using_placeholder() -> bool:
	return _using_placeholder


func set_speed(speed: float) -> void:
	if _anim == null:
		return
	_anim.speed_scale = clampf(speed / BASELINE_SPEED, MIN_SPD_SCALE, MAX_SPD_SCALE)


# ── Asset loading via manifest ────────────────────────────────────────────

func _try_load_real_frames() -> void:
	var run_frames := MANIFEST.get_jomana_run_frames()
	if run_frames.size() < MANIFEST.JOMANA_RUN_COUNT:
		push_warning(
			"[Jomana] Run frames %d/%d found in %srun/ — using placeholder. "
			% [run_frames.size(), MANIFEST.JOMANA_RUN_COUNT, MANIFEST.ROOT_CHAR] +
			"See docs/level2/JOMANA_IMAGE_REQUESTS.md"
		)
		return

	_using_placeholder = false
	if _placeholder != null:
		_placeholder.visible = false

	_anim = AnimatedSprite2D.new()
	_anim.name = "JomanaAnimated"
	add_child(_anim)

	var sf := SpriteFrames.new()
	_anim.sprite_frames = sf

	# Run — required
	_add_anim(sf, "run", run_frames, BASE_RUN_FPS, true)

	# Idle — optional fallback to run[0]
	var idle_frames := MANIFEST.get_jomana_idle_frames()
	if idle_frames.is_empty():
		idle_frames = [run_frames[0]]
	_add_anim(sf, "idle", idle_frames, 6.0, true)

	# Jump — optional fallback to run[2]
	var jump_tex := load(MANIFEST.JOMANA_JUMP) as Texture2D
	_add_anim(sf, "jump", [jump_tex if jump_tex != null else run_frames[2]], 1.0, false)

	# Land — optional fallback to run[0]
	var land_tex := load(MANIFEST.JOMANA_LAND) as Texture2D
	_add_anim(sf, "land", [land_tex if land_tex != null else run_frames[0]], 1.0, false)

	# Story / wave — optional fallback to idle[0]
	var wave_tex := load(MANIFEST.JOMANA_WAVE) as Texture2D
	_add_anim(sf, "story", [wave_tex if wave_tex != null else run_frames[1]], 3.0, true)

	# Scale to visual height — all normalized frames are CANVAS_HEIGHT tall.
	# centered=false so we control exact foot placement.
	var s := VISUAL_HEIGHT / CANVAS_HEIGHT
	_anim.scale    = Vector2(s, s)
	_anim.centered = false
	# Position: top-left X centred horizontally, Y such that feet land at local y=FOOT_OFFSET_Y
	# (matching Player CharacterBody2D half-collision so feet appear on the ground).
	_anim.position = Vector2(-(CANVAS_WIDTH * s) / 2.0, -VISUAL_HEIGHT + FOOT_OFFSET_Y)

	_play_anim(Pose.RUN)


func _add_anim(sf: SpriteFrames, name: String, frames: Array, fps: float, loop: bool) -> void:
	sf.add_animation(name)
	sf.set_animation_speed(name, fps)
	sf.set_animation_loop(name, loop)
	for tex in frames:
		if tex != null:
			sf.add_frame(name, tex)


func _play_anim(pose: Pose) -> void:
	if _anim == null or _anim.sprite_frames == null:
		return
	var anim_name := "run"
	match pose:
		Pose.IDLE:   anim_name = "idle"
		Pose.RUN:    anim_name = "run"
		Pose.JUMP:   anim_name = "jump"
		Pose.LAND:   anim_name = "land"
		Pose.STORY:  anim_name = "story"
	if _anim.sprite_frames.has_animation(anim_name):
		_anim.play(anim_name)


# ── Polygon placeholder ────────────────────────────────────────────────────

func _build_placeholder() -> void:
	_placeholder = Node2D.new()
	_placeholder.name = "JomanaPlaceholder"
	add_child(_placeholder)

	var body := Polygon2D.new()
	body.color = Color(0.28, 0.72, 0.58, 1.0)  # teal dress
	body.polygon = PackedVector2Array([
		Vector2(-13, -70), Vector2(13, -70),
		Vector2(16, -24), Vector2(-16, -24),
	])
	_placeholder.add_child(body)

	var head := Polygon2D.new()
	head.color = Color(0.85, 0.68, 0.50, 1.0)  # skin
	var pts := PackedVector2Array()
	for i: int in 10:
		var a := i * TAU / 10.0
		pts.append(Vector2(cos(a) * 10.0, sin(a) * 10.0))
	head.polygon = pts
	head.position.y = -82.0
	_placeholder.add_child(head)

	var hijab := Polygon2D.new()
	hijab.color = Color(0.22, 0.42, 0.32, 1.0)  # dark teal hijab
	var hp := PackedVector2Array()
	for i: int in 9:
		var a := i * PI / 8.0 + PI * 0.06
		hp.append(Vector2(cos(a) * 13.0, sin(a) * 12.0))
	hp.append(Vector2(-13.0, 4.0))
	hijab.polygon = hp
	hijab.position.y = -84.0
	_placeholder.add_child(hijab)

	for side: int in [-1, 1]:
		var leg := ColorRect.new()
		leg.color = Color(0.20, 0.56, 0.42, 1.0)
		leg.size = Vector2(8.0, 24.0)
		leg.position = Vector2(side * 3.0 - 4.0, -24.0)
		_placeholder.add_child(leg)

	var lbl := Label.new()
	lbl.text = "جمانة"
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.90))
	lbl.add_theme_constant_override("outline_size", 2)
	lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.size = Vector2(44.0, 16.0)
	lbl.position = Vector2(-22.0, -100.0)
	lbl.set("text_direction", TextServer.DIRECTION_RTL)
	_placeholder.add_child(lbl)


func _placeholder_pose(pose: Pose) -> void:
	if _placeholder == null:
		return
	match pose:
		Pose.JUMP:  _placeholder.rotation_degrees = -12.0
		Pose.LAND:  _placeholder.rotation_degrees = 5.0
		_:          _placeholder.rotation_degrees = 0.0
