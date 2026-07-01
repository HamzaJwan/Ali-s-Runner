## jomana_player_visual.gd
## Jomana's visual animation system for Level 2.
## Attach to JomanaPlayerVisual.tscn, then instance inside Level2_Marsa_Playable.
##
## Pipeline:
##   1. If PNG frames exist in ASSET_PATH_RUN, loads them into AnimatedSprite2D.
##   2. If missing, shows a clean teal polygon placeholder and logs a warning.
##   3. Animation speed scales with game speed.
##
## To upgrade from placeholder to real art:
##   - Drop jomana_run_01.png … jomana_run_08.png into:
##       assets/level2/marsa/characters/jomana/run/
##   - Drop jomana_idle_01.png … jomana_idle_04.png into:
##       assets/level2/marsa/characters/jomana/idle/
##   - Drop jomana_jump_01.png into:
##       assets/level2/marsa/characters/jomana/jump/
##   Re-open the scene — frames load automatically, placeholder hides.
extends Node2D

const ASSET_ROOT := "res://assets/level2/marsa/characters/jomana/"
const RUN_FRAMES  := 8
const IDLE_FRAMES := 4
const BASE_FPS    := 11.0   # run animation FPS at speed 225
const MIN_SPEED_SCALE := 0.8
const MAX_SPEED_SCALE := 1.6

# Visual size target — matches Level 1 runner calibration.
# Collision remains 32x48 on the parent Player.tscn, unchanged.
const VISUAL_HEIGHT_TARGET := 160.0

enum Pose { IDLE, RUN, JUMP, LAND, STORY }

var _anim: AnimatedSprite2D
var _placeholder: Node2D    # shown when real art is missing
var _using_placeholder := true
var _current_pose: Pose = Pose.IDLE
var _current_speed: float = 225.0


func _ready() -> void:
	_build_placeholder()
	_try_load_real_frames()


# ── Public API ────────────────────────────────────────────────────────────

func set_pose(pose: Pose) -> void:
	if _current_pose == pose:
		return
	_current_pose = pose
	if _using_placeholder:
		_update_placeholder_pose(pose)
	else:
		_play_anim(pose)


func set_speed(speed: float) -> void:
	_current_speed = speed
	if _anim != null:
		_anim.speed_scale = clampf(speed / 225.0, MIN_SPEED_SCALE, MAX_SPEED_SCALE)


# ── Asset loading ─────────────────────────────────────────────────────────

func _try_load_real_frames() -> void:
	var run_frames: Array[Texture2D] = []
	for i: int in RUN_FRAMES:
		var path := ASSET_ROOT + "run/jomana_run_%02d.png" % (i + 1)
		var tex := load(path) as Texture2D
		if tex == null:
			break
		run_frames.append(tex)

	if run_frames.size() < RUN_FRAMES:
		push_warning(
			"[Level2 Jomana] Run frames not found in %srun/ — using placeholder. " +
			"See docs/level2/JOMANA_IMAGE_REQUESTS.md for required assets." % ASSET_ROOT
		)
		return

	# All run frames present — build AnimatedSprite2D
	_using_placeholder = false
	if _placeholder != null:
		_placeholder.visible = false

	_anim = AnimatedSprite2D.new()
	_anim.name = "JomanaAnimated"
	add_child(_anim)

	var sf := SpriteFrames.new()
	_anim.sprite_frames = sf

	# Run animation
	sf.add_animation("run")
	sf.set_animation_speed("run", BASE_FPS)
	sf.set_animation_loop("run", true)
	for tex: Texture2D in run_frames:
		sf.add_frame("run", tex)

	# Idle — optional, fallback to run frame 0 if missing
	sf.add_animation("idle")
	sf.set_animation_speed("idle", 6.0)
	sf.set_animation_loop("idle", true)
	for i: int in IDLE_FRAMES:
		var path := ASSET_ROOT + "idle/jomana_idle_%02d.png" % (i + 1)
		var tex := load(path) as Texture2D
		if tex != null:
			sf.add_frame("idle", tex)
	if sf.get_frame_count("idle") == 0:
		sf.add_frame("idle", run_frames[0])

	# Jump single frame
	sf.add_animation("jump")
	sf.set_animation_speed("jump", 1.0)
	sf.set_animation_loop("jump", false)
	var jump_tex := load(ASSET_ROOT + "jump/jomana_jump_01.png") as Texture2D
	sf.add_frame("jump", jump_tex if jump_tex != null else run_frames[2])

	# Land single frame
	sf.add_animation("land")
	sf.set_animation_speed("land", 1.0)
	sf.set_animation_loop("land", false)
	var land_tex := load(ASSET_ROOT + "jump/jomana_land_01.png") as Texture2D
	sf.add_frame("land", land_tex if land_tex != null else run_frames[0])

	# Story / wave
	sf.add_animation("story")
	sf.set_animation_speed("story", 3.0)
	sf.set_animation_loop("story", true)
	var story_tex := load(ASSET_ROOT + "story/jomana_smile_wave_01.png") as Texture2D
	sf.add_frame("story", story_tex if story_tex != null else run_frames[1])

	# Calibrate visual size
	_anim.scale = Vector2(VISUAL_HEIGHT_TARGET / 192.0, VISUAL_HEIGHT_TARGET / 192.0)
	_play_anim(Pose.RUN)


func _play_anim(pose: Pose) -> void:
	if _anim == null:
		return
	var name: String
	match pose:
		Pose.IDLE:   name = "idle"
		Pose.RUN:    name = "run"
		Pose.JUMP:   name = "jump"
		Pose.LAND:   name = "land"
		Pose.STORY:  name = "story"
		_:           name = "run"
	if _anim.sprite_frames != null and _anim.sprite_frames.has_animation(name):
		_anim.play(name)


# ── Placeholder (when real art is missing) ────────────────────────────────

func _build_placeholder() -> void:
	_placeholder = Node2D.new()
	_placeholder.name = "JomanaPlaceholder"
	add_child(_placeholder)

	# Dress/body
	var body := Polygon2D.new()
	body.color = Color(0.28, 0.72, 0.58, 1.0)
	body.polygon = PackedVector2Array([
		Vector2(-13, -70), Vector2(13, -70),
		Vector2(16, -24),  Vector2(-16, -24),
	])
	_placeholder.add_child(body)

	# Head
	var head := Polygon2D.new()
	head.color = Color(0.85, 0.68, 0.50, 1.0)
	var pts := PackedVector2Array()
	for i: int in 10:
		var a := i * TAU / 10.0
		pts.append(Vector2(cos(a) * 10.0, sin(a) * 10.0))
	head.polygon = pts
	head.position = Vector2(0, -82.0)
	_placeholder.add_child(head)

	# Hijab
	var hijab := Polygon2D.new()
	hijab.color = Color(0.22, 0.42, 0.32, 1.0)
	var hpts := PackedVector2Array()
	for i: int in 9:
		var a := i * PI / 8.0 + PI * 0.06
		hpts.append(Vector2(cos(a) * 13.0, sin(a) * 12.0))
	hpts.append(Vector2(-13.0, 4.0))
	hijab.polygon = hpts
	hijab.position = Vector2(0, -84.0)
	_placeholder.add_child(hijab)

	# Legs
	for side: int in [-1, 1]:
		var leg := ColorRect.new()
		leg.color = Color(0.20, 0.56, 0.42, 1.0)
		leg.size = Vector2(8.0, 24.0)
		leg.position = Vector2(side * 3.0 - 4.0, -24.0)
		_placeholder.add_child(leg)

	# "جمانة" label
	var lbl := Label.new()
	lbl.text = "جمانة"
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.88))
	lbl.add_theme_constant_override("outline_size", 2)
	lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.size = Vector2(44.0, 16.0)
	lbl.position = Vector2(-22.0, -100.0)
	lbl.set("text_direction", TextServer.DIRECTION_RTL)
	_placeholder.add_child(lbl)


func _update_placeholder_pose(pose: Pose) -> void:
	if _placeholder == null:
		return
	match pose:
		Pose.JUMP:
			_placeholder.rotation_degrees = -12.0
		Pose.LAND:
			_placeholder.rotation_degrees = 5.0
		_:
			_placeholder.rotation_degrees = 0.0
