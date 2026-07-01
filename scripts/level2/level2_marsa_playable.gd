extends Node2D

## Level 2 Playable Foundation — جمانة وأثر الكلمة — مرسى زليتن
##
## Self-contained playable MVP for owner testing.
## Open scenes/level2/Level2_Marsa_Playable.tscn directly in Godot editor.
## NOT the default boot scene. NOT wired into main menu.
##
## Reuses from Level 1 (unmodified shared scripts):
##   ObstacleSpawner, CollectibleSpawner, AudioManager
##
## Level 2 exclusive:
##   level2_encounter_data.gd (family characters: Ali, Fatima, Zainab, Father)
##   Procedural harbor backgrounds (5 layers, ColorRect/Polygon2D)
##   Procedural ambient life (seagulls, boat bob, wind)

# ── Shared Level 1 systems (unmodified) ───────────────────────────────────
const OBSTACLE_SPAWNER    := preload("res://scripts/gameplay/obstacle_spawner.gd")
const COLLECTIBLE_SPAWNER := preload("res://scripts/gameplay/collectible_spawner.gd")
const AUDIO_MANAGER       := preload("res://scripts/audio/audio_manager.gd")
# BACKGROUND_MOTION is not used in the procedural MVP — the procedural
# background layers are Node2D containers, not Sprite2D, so they are
# incompatible with BackgroundMotion.add_layer(Sprite2D).
# The Environment Lane coder will wire real Sprite2D layers + motion later.

# ── Level 2 environment PNG auto-detector (non-fatal) ─────────────────────
const L2_ENV := preload("res://scripts/level2/environment/level2_environment_visual.gd")

# ── Level 2 encounter data ────────────────────────────────────────────────
# Level2EncounterData is available globally via its class_name declaration.
# Do NOT preload — the class_name registration handles resolution.

# ── Immutable gameplay constants (same as Level 1) ────────────────────────
const VIEW_W                  := 1152.0
const VIEW_H                  := 648.0
const ROAD_SURFACE_Y          := 510.0
const PLAYER_START_X          := 220.0
const PLAYER_COLLISION_HALF_H := 24.0
const CURB_TOP_Y              := 470.0
const GROUND_COLLISION_HEIGHT := 70.0
const GROUND_CENTER_Y         := ROAD_SURFACE_Y + GROUND_COLLISION_HEIGHT / 2.0
const START_PLAYER_POSITION   := Vector2(PLAYER_START_X, ROAD_SURFACE_Y - PLAYER_COLLISION_HALF_H)
const ENCOUNTER_TARGET_X      := 610.0
const CHECKPOINT_ARRIVAL_SPEED := 360.0
const COUNTDOWN_DURATION      := 3.0
const GAME_OVER_DELAY         := 0.45

# ── Level 2 camera tuning constants (all Level 2 local) ───────────────────
# Increase GAMEPLAY_ZOOM to bring Jomana closer; safe range: 1.25–1.45.
# At 1.38 the visible world width is 1152/1.38 ≈ 835 px, obstacles at
# spawn X=1292 appear ~475 px ahead (world space) — comfortable react time.
const GAMEPLAY_ZOOM           := 1.38   # was 1.18 — now visibly larger
const CAMERA_REVEAL_FROM      := 0.95   # cinematic opening starts here
const CAMERA_CHECKPOINT_BOOST := 0.05   # +5% zoom during checkpoint
# Where Jomana lands on screen (px from left at gameplay zoom):
const CAM_SCREEN_X            := 238.0  # left-third — enough look-ahead right
const CAM_SCREEN_Y            := 498.0  # road surface screen Y (same as L1)
const CAM_TRANSITION_TIME     := 0.38
# Smooth look-ahead: camera slides slightly forward so players see more ahead.
# In a fixed-X runner, look-ahead = horizontal offset applied every frame.
const LOOKAHEAD_X             := 120.0  # extra px of look-ahead (world space)
const FOLLOW_SPEED            := 5.5    # lerp speed for look-ahead correction
# Vertical feel: slight upward shift keeps jump apex in frame without
# showing empty sky. Negative = camera is higher, showing more below.
const VERTICAL_OFFSET         := -18.0

# ── Harbour palette (procedural — no external assets required) ────────────
const C_SKY        := Color(0.38, 0.66, 0.90, 1.0)
const C_HORIZON    := Color(0.70, 0.87, 0.98, 1.0)
const C_SEA        := Color(0.16, 0.44, 0.68, 1.0)
const C_SEA_LIGHT  := Color(0.28, 0.62, 0.80, 1.0)
const C_BREAKWATER := Color(0.52, 0.48, 0.42, 1.0)
const C_BUILDING   := Color(0.74, 0.66, 0.54, 0.88)
const C_BOAT_HULL  := Color(0.22, 0.34, 0.58, 1.0)
const C_BOAT_CABIN := Color(0.88, 0.84, 0.72, 1.0)
const C_PIER       := Color(0.68, 0.60, 0.48, 1.0)
const C_PIER_EDGE  := Color(0.54, 0.48, 0.38, 1.0)

# ── Node references ───────────────────────────────────────────────────────
@onready var game_camera: Camera2D         = $GameCamera
@onready var player: CharacterBody2D       = $Player
@onready var jomana_sprite: Node2D         = $Player/AliSprite
@onready var ground: StaticBody2D          = $Ground
@onready var bg_node: Node2D               = $Background
@onready var sky_layer: Node2D             = $Background/L2_SkyLayer
@onready var sea_layer: Node2D             = $Background/L2_SeaBreakwaterLayer
@onready var buildings_layer: Node2D       = $Background/L2_FarBuildingsLayer
@onready var boats_layer: Node2D           = $Background/L2_BoatsMidLayer
@onready var foreground_layer: Node2D      = $Background/L2_ForegroundPierLayer
@onready var ambient_layer: Node2D         = $AmbientLife
@onready var obstacle_spawner: Node2D      = $Obstacles
@onready var spawn_timer: Timer            = $SpawnTimer
@onready var collectible_spawner: Node2D   = $Collectibles
@onready var col_spawn_timer: Timer        = $CollectibleSpawnTimer
@onready var encounter_npc: Node2D         = $EncounterNPC
@onready var npc_label: Label              = $EncounterNPC/NPCLabel
@onready var score_label: Label            = $UI/ScoreLabel
@onready var game_over_panel: Control      = $UI/GameOverPanel
@onready var game_over_title: Label        = $UI/GameOverPanel/Card/Title
@onready var game_over_msg: Label          = $UI/GameOverPanel/Card/Message
@onready var game_over_count: Label        = $UI/GameOverPanel/Card/CountLabel
@onready var retry_button: Button          = $UI/GameOverPanel/Card/RetryButton
@onready var restart_button: Button        = $UI/GameOverPanel/Card/RestartButton
@onready var checkpoint_panel: Control     = $UI/CheckpointPanel
@onready var cp_speaker: Label             = $UI/CheckpointPanel/Card/SpeakerName
@onready var cp_char_line: Label           = $UI/CheckpointPanel/Card/CharacterLine
@onready var cp_jomana_line: Label         = $UI/CheckpointPanel/Card/JomanaLine
@onready var cp_reward: Label              = $UI/CheckpointPanel/Card/RewardLabel
@onready var cp_continue: Button           = $UI/CheckpointPanel/Card/ContinueButton
@onready var countdown_overlay: Control    = $UI/CountdownOverlay
@onready var countdown_label: Label        = $UI/CountdownOverlay/CountdownLabel
@onready var start_screen: Control         = $UI/StartScreen
@onready var play_button: Button           = $UI/StartScreen/PlayButton

# ── Gameplay state ────────────────────────────────────────────────────────
var score              := 0
var collectible_count  := 0
var col_snapshot       := 0
var started            := false
var game_over          := false
var checkpoint_active  := false
var countdown_active   := false
var countdown_remaining := 0.0
var current_speed      := 225.0
var last_checkpoint    := Level2EncounterData.NONE
var current_enc_id     := Level2EncounterData.NONE
var enc_step           := 0
var npc_arriving       := false

var audio_manager    := AUDIO_MANAGER.new()
var _cam_tween: Tween
var _gameplay_cam_pos: Vector2
var _look_x: float = 0.0          # smoothed look-ahead X target
var _tracking_active: bool = false  # true during gameplay only
var _boat_times: Array[float] = []

# ── Boot ──────────────────────────────────────────────────────────────────

func _ready() -> void:
	randomize()
	_gameplay_cam_pos = _calc_cam_pos()
	ground.position = Vector2(VIEW_W / 2.0, GROUND_CENTER_Y)

	obstacle_spawner.setup(spawn_timer)
	obstacle_spawner.obstacle_passed.connect(_on_obstacle_passed)
	obstacle_spawner.obstacle_hit.connect(_on_obstacle_hit)
	collectible_spawner.setup(col_spawn_timer, obstacle_spawner)
	collectible_spawner.collectible_spawned.connect(_on_collectible_spawned)

	audio_manager.setup(self)

	# Try loading real PNG environment layers — falls back to procedural if missing.
	var env_loader := L2_ENV.new()
	var any_real := env_loader.setup(bg_node, VIEW_W)
	if not any_real:
		_build_backgrounds()   # procedural fallback
	_build_ambient()
	_tag_jomana()

	play_button.pressed.connect(_on_play_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	retry_button.pressed.connect(_on_retry_pressed)
	cp_continue.pressed.connect(_on_continue_pressed)

	if player.has_signal("landed"):
		player.landed.connect(func(): audio_manager.play_land())
	if player.has_signal("jumped"):
		player.jumped.connect(func(): audio_manager.play_jump())

	_show_start_screen()
	audio_manager.play_calm_music()


# ── Frame ─────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	if npc_arriving and encounter_npc != null:
		encounter_npc.position.x = move_toward(
			encounter_npc.position.x, ENCOUNTER_TARGET_X, CHECKPOINT_ARRIVAL_SPEED * delta)
		if is_equal_approx(encounter_npc.position.x, ENCOUNTER_TARGET_X):
			npc_arriving = false

	if countdown_active:
		countdown_remaining -= delta
		var n := ceili(countdown_remaining)
		if n != countdown_label.text.to_int() and n > 0:
			countdown_label.text = str(n)
			_pop(countdown_label)
		if countdown_remaining <= 0.0:
			countdown_active = false
			countdown_overlay.visible = false
			_finish_countdown()

	if started and not game_over and not checkpoint_active and not countdown_active:
		_animate_boats(delta)
		# Smooth look-ahead: slide camera position.x toward a target
		# slightly ahead of the player so upcoming obstacles are visible.
		if _tracking_active:
			var desired_x: float = _gameplay_cam_pos.x - LOOKAHEAD_X / GAMEPLAY_ZOOM
			_look_x = lerpf(_look_x, desired_x, FOLLOW_SPEED * delta)
			game_camera.position.x = _look_x


func _unhandled_input(event: InputEvent) -> void:
	if not started or game_over or checkpoint_active or countdown_active:
		return
	if event.is_action_pressed("ui_accept") \
	or (event is InputEventMouseButton and event.pressed) \
	or (event is InputEventScreenTouch and event.pressed):
		player.jump()


func _input(event: InputEvent) -> void:
	if not checkpoint_active:
		return
	var enc := Level2EncounterData.get_encounter(current_enc_id)
	if enc.is_empty():
		return
	var steps: Array = enc.get("dialogue_steps", [])
	if enc_step >= steps.size() - 1:
		return
	if (event.is_action_pressed("ui_accept")
	or (event is InputEventMouseButton and event.pressed)
	or (event is InputEventScreenTouch and event.pressed)):
		enc_step += 1
		_show_enc_step()
		get_viewport().set_input_as_handled()


# ── Start / menu ──────────────────────────────────────────────────────────

func _show_start_screen() -> void:
	started = false
	game_over = false
	score = 0
	collectible_count = 0
	col_snapshot = 0
	last_checkpoint = Level2EncounterData.NONE
	start_screen.visible = true
	score_label.visible = false
	game_over_panel.visible = false
	checkpoint_panel.visible = false
	countdown_overlay.visible = false
	obstacle_spawner.stop_spawning()
	obstacle_spawner.clear_obstacles()
	collectible_spawner.stop_spawning()
	collectible_spawner.clear_collectibles()
	player.reset_player(START_PLAYER_POSITION)
	_apply_default_cam()


func _on_play_pressed() -> void:
	start_screen.visible = false
	_begin_run(0, Level2EncounterData.NONE, 225.0)
	_play_harbor_reveal()


func _begin_run(initial_score: int, checkpoint: int, speed: float) -> void:
	score = initial_score
	current_speed = speed
	collectible_count = (col_snapshot if checkpoint != Level2EncounterData.NONE else 0)
	if checkpoint == Level2EncounterData.NONE:
		col_snapshot = 0
	game_over = false
	checkpoint_active = false
	countdown_active = false
	npc_arriving = false
	started = true
	score_label.visible = true
	score_label.text = "الأثر: %d" % score
	game_over_panel.visible = false
	checkpoint_panel.visible = false
	countdown_overlay.visible = false
	player.reset_player(START_PLAYER_POSITION)
	player.set_gameplay_active(true)
	obstacle_spawner.clear_obstacles()
	obstacle_spawner.start_spawning(current_speed)
	collectible_spawner.clear_collectibles()
	collectible_spawner.start_spawning(current_speed)
	_apply_gameplay_cam()
	audio_manager.play_gameplay_music()


# ── Obstacle events ───────────────────────────────────────────────────────

func _on_obstacle_passed() -> void:
	score += 1
	score_label.text = "الأثر: %d" % score
	_pop(score_label)
	var char_id := Level2EncounterData.get_encounter_for_score(score)
	if char_id != Level2EncounterData.NONE:
		_start_checkpoint(char_id)


func _on_obstacle_hit() -> void:
	_end_run()


# ── Collectibles ──────────────────────────────────────────────────────────

func _on_collectible_spawned(c: Node) -> void:
	c.collected.connect(_on_collected)


func _on_collected() -> void:
	collectible_count += 1
	score_label.text = "الأثر: %d  ✦%d" % [score, collectible_count]
	audio_manager.play_shard_pickup()


# ── Checkpoint ────────────────────────────────────────────────────────────

func _start_checkpoint(char_id: int) -> void:
	if game_over or checkpoint_active:
		return
	checkpoint_active = true
	current_enc_id = char_id
	enc_step = 0
	col_snapshot = collectible_count
	last_checkpoint = char_id
	obstacle_spawner.stop_spawning()
	obstacle_spawner.clear_obstacles()
	collectible_spawner.stop_spawning()
	collectible_spawner.clear_collectibles()
	player.set_gameplay_active(false)
	get_tree().paused = true
	audio_manager.play_calm_music()
	audio_manager.play_checkpoint()
	_apply_checkpoint_cam()
	var enc := Level2EncounterData.get_encounter(char_id)
	npc_label.text = enc.get("placeholder_text", "؟")
	encounter_npc.position.x = 1300.0
	encounter_npc.position.y = ROAD_SURFACE_Y - enc.get("visual_height", 80.0)
	npc_arriving = true
	_show_enc_step()


func _show_enc_step() -> void:
	var enc := Level2EncounterData.get_encounter(current_enc_id)
	if enc.is_empty():
		return
	var steps: Array = enc.get("dialogue_steps", [])
	if enc_step >= steps.size():
		return
	var step: Dictionary = steps[enc_step]
	var role: int = step.get("role", 0)
	var text: String = Level2EncounterData.rtl_safe(step.get("text", ""))

	checkpoint_panel.visible = true
	cp_speaker.text = enc.get("speaker_name", "")

	match role:
		Level2EncounterData.ROLE_HELPER:
			cp_char_line.text = text
			cp_jomana_line.text = ""
			cp_reward.visible = false
			cp_continue.visible = false
		Level2EncounterData.ROLE_JOMANA:
			cp_char_line.text = ""
			cp_jomana_line.text = text
			cp_reward.visible = false
			cp_continue.visible = false
		Level2EncounterData.ROLE_REWARD:
			cp_char_line.text = ""
			cp_jomana_line.text = ""
			cp_reward.text = text
			cp_reward.visible = true
			cp_continue.visible = true
			audio_manager.play_reward_star()


func _on_continue_pressed() -> void:
	if not checkpoint_active:
		return
	var enc := Level2EncounterData.get_encounter(current_enc_id)
	checkpoint_panel.visible = false
	get_tree().paused = false
	checkpoint_active = false

	if current_enc_id == Level2EncounterData.FATHER:
		_show_start_screen()
		return

	var new_speed: float = enc.get("post_speed", current_speed)
	current_speed = new_speed
	countdown_active = true
	countdown_remaining = COUNTDOWN_DURATION
	countdown_label.text = "3"
	countdown_overlay.visible = true


func _finish_countdown() -> void:
	player.set_gameplay_active(true)
	obstacle_spawner.start_spawning(current_speed)
	collectible_spawner.start_spawning(current_speed)
	_apply_gameplay_cam()
	audio_manager.play_gameplay_music()


# ── Game Over ─────────────────────────────────────────────────────────────

func _end_run() -> void:
	if game_over or checkpoint_active or countdown_active:
		return
	game_over = true
	audio_manager.play_hit()
	audio_manager.play_calm_music()
	_apply_default_cam()
	obstacle_spawner.stop_spawning()
	obstacle_spawner.clear_obstacles()
	collectible_spawner.stop_spawning()
	collectible_spawner.clear_collectibles()
	player.kill()
	await get_tree().create_timer(GAME_OVER_DELAY).timeout
	audio_manager.play_game_over()
	_show_game_over()


func _show_game_over() -> void:
	var enc := Level2EncounterData.get_encounter(last_checkpoint)
	if enc.is_empty():
		game_over_msg.text = Level2EncounterData.rtl_safe(Level2EncounterData.GAME_OVER_BEFORE_CHECKPOINT)
		retry_button.visible = false
	else:
		game_over_msg.text = Level2EncounterData.rtl_safe(enc.get("game_over_line", ""))
		retry_button.visible = (last_checkpoint != Level2EncounterData.NONE)
	game_over_count.text = "الأثر الذي تركتِه: %d" % collectible_count

	var card: Panel = $UI/GameOverPanel/Card
	game_over_panel.modulate.a = 0.0
	card.scale = Vector2(0.92, 0.92)
	card.pivot_offset = card.size / 2.0
	game_over_panel.visible = true
	var t := create_tween().set_parallel()
	t.tween_property(game_over_panel, "modulate:a", 1.0, 0.28).set_trans(Tween.TRANS_SINE)
	t.tween_property(card, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if retry_button.visible:
		retry_button.grab_focus()
	else:
		restart_button.grab_focus()


func _on_restart_pressed() -> void:
	_begin_run(0, Level2EncounterData.NONE, 225.0)


func _on_retry_pressed() -> void:
	if last_checkpoint == Level2EncounterData.NONE:
		_begin_run(0, Level2EncounterData.NONE, 225.0)
		return
	var enc := Level2EncounterData.get_encounter(last_checkpoint)
	_begin_run(enc.get("retry_score", 0), last_checkpoint, enc.get("post_speed", 225.0))


# ── Camera ────────────────────────────────────────────────────────────────

func _calc_cam_pos() -> Vector2:
	# Apply VERTICAL_OFFSET: negative shifts camera up, showing more sky above
	# Jomana and keeping her jump arc in frame without cropping.
	return Vector2(
		PLAYER_START_X - (CAM_SCREEN_X - VIEW_W / 2.0) / GAMEPLAY_ZOOM,
		ROAD_SURFACE_Y - (CAM_SCREEN_Y - VIEW_H / 2.0) / GAMEPLAY_ZOOM + VERTICAL_OFFSET,
	)


func _apply_gameplay_cam() -> void:
	_tracking_active = false
	_tween_cam(_gameplay_cam_pos, Vector2(GAMEPLAY_ZOOM, GAMEPLAY_ZOOM))
	# Start look-ahead from current camera position, then enable tracking
	_look_x = game_camera.position.x
	await get_tree().create_timer(CAM_TRANSITION_TIME + 0.05).timeout
	if started and not game_over and not checkpoint_active:
		_tracking_active = true


func _apply_default_cam() -> void:
	_tracking_active = false
	_tween_cam(Vector2(VIEW_W / 2.0, VIEW_H / 2.0), Vector2.ONE)


func _apply_checkpoint_cam() -> void:
	_tracking_active = false
	var boost: float = GAMEPLAY_ZOOM * (1.0 + CAMERA_CHECKPOINT_BOOST)
	_tween_cam(_gameplay_cam_pos, Vector2(boost, boost))


func _play_harbor_reveal() -> void:
	# Soft reveal: start slightly zoomed out, settle into full gameplay framing
	game_camera.position = Vector2(VIEW_W / 2.0, VIEW_H / 2.0 + 20.0)
	game_camera.zoom = Vector2(CAMERA_REVEAL_FROM, CAMERA_REVEAL_FROM)
	_tween_cam(_gameplay_cam_pos, Vector2(GAMEPLAY_ZOOM, GAMEPLAY_ZOOM), 1.4)


func _tween_cam(tpos: Vector2, tzoom: Vector2, dur := CAM_TRANSITION_TIME) -> void:
	if _cam_tween != null and _cam_tween.is_valid():
		_cam_tween.kill()
	_cam_tween = create_tween().set_parallel()
	_cam_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_cam_tween.tween_property(game_camera, "position", tpos, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_cam_tween.tween_property(game_camera, "zoom", tzoom, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


# ── Jomana visual tag ─────────────────────────────────────────────────────

func _tag_jomana() -> void:
	# Apply teal tint to Ali's placeholder polygon so it reads as Jomana
	var poly: Polygon2D = player.get_node_or_null("Polygon2D")
	if poly != null:
		poly.color = Color(0.28, 0.72, 0.58, 1.0)
	# Small label above the character
	var lbl := Label.new()
	lbl.name = "JomanaTag"
	lbl.text = "جمانة"
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
	lbl.add_theme_constant_override("outline_size", 2)
	lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
	lbl.position = Vector2(-16.0, -52.0)
	lbl.size = Vector2(32.0, 14.0)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.set("text_direction", TextServer.DIRECTION_RTL)
	player.add_child(lbl)


# ── Procedural background (5 layers, zero external assets) ────────────────

func _build_backgrounds() -> void:
	_build_sky()
	_build_sea()
	_build_buildings()
	_build_boats()
	_build_pier()


func _build_sky() -> void:
	var r := ColorRect.new()
	r.color = C_SKY
	r.size = Vector2(VIEW_W, 360.0)
	sky_layer.add_child(r)
	var h := ColorRect.new()
	h.color = C_HORIZON
	h.size = Vector2(VIEW_W, 90.0)
	h.position = Vector2(0, 280.0)
	h.modulate.a = 0.65
	sky_layer.add_child(h)


func _build_sea() -> void:
	var sea := ColorRect.new()
	sea.color = C_SEA
	sea.size = Vector2(VIEW_W, 185.0)
	sea.position = Vector2(0, 290.0)
	sea_layer.add_child(sea)
	var shallow := ColorRect.new()
	shallow.color = C_SEA_LIGHT
	shallow.size = Vector2(VIEW_W, 55.0)
	shallow.position = Vector2(0, 408.0)
	sea_layer.add_child(shallow)
	var bw := Polygon2D.new()
	bw.color = C_BREAKWATER
	bw.polygon = PackedVector2Array([
		Vector2(0, 348), Vector2(220, 340), Vector2(500, 338),
		Vector2(680, 352), Vector2(900, 342), Vector2(1152, 348),
		Vector2(1152, 378), Vector2(0, 378),
	])
	sea_layer.add_child(bw)
	# Water shimmer shader
	var shimmer := ColorRect.new()
	shimmer.name = "WaterShimmer"
	shimmer.size = Vector2(VIEW_W, 125.0)
	shimmer.position = Vector2(0, 295.0)
	var sh := load("res://scripts/level2/ambient/water_shimmer.gdshader") as Shader
	if sh != null:
		var mat := ShaderMaterial.new()
		mat.shader = sh
		shimmer.material = mat
		shimmer.color = Color(0.18, 0.48, 0.72, 1.0)
	else:
		shimmer.color = Color(0.55, 0.80, 1.00, 0.09)
		var t := shimmer.create_tween()
		t.set_loops()
		t.tween_property(shimmer, "modulate:a", 2.0, 3.0).set_trans(Tween.TRANS_SINE)
		t.tween_property(shimmer, "modulate:a", 0.5, 3.0).set_trans(Tween.TRANS_SINE)
	sea_layer.add_child(shimmer)


func _build_buildings() -> void:
	var specs := [[60, 305, 78, 70], [165, 300, 60, 86], [245, 308, 88, 56],
				  [410, 298, 72, 92], [500, 310, 50, 62], [630, 302, 108, 78],
				  [760, 305, 64, 82], [858, 300, 80, 67], [958, 308, 55, 88]]
	for s in specs:
		var r := ColorRect.new()
		r.color = C_BUILDING
		r.size = Vector2(s[2] as float, s[3] as float)
		r.position = Vector2(s[0] as float, s[1] as float - s[3] as float + 62.0)
		buildings_layer.add_child(r)


func _build_boats() -> void:
	var defs := [[290.0, 375.0, 118.0, 0.0], [690.0, 372.0, 98.0, 1.4], [955.0, 376.0, 88.0, 0.8]]
	for i: int in defs.size():
		var d: Array = defs[i]
		var cont := Node2D.new()
		cont.position = Vector2(d[0] as float, d[1] as float)
		cont.set_meta("bob_base_y", d[1] as float)
		boats_layer.add_child(cont)
		_boat_times.append(d[3] as float)
		var hw: float = (d[2] as float) / 2.0
		var hull := Polygon2D.new()
		hull.color = C_BOAT_HULL
		hull.polygon = PackedVector2Array([Vector2(-hw,0),Vector2(hw,0),Vector2(hw*0.85,16),Vector2(-hw*0.85,16)])
		cont.add_child(hull)
		var cabin := ColorRect.new()
		cabin.color = C_BOAT_CABIN
		cabin.size = Vector2((d[2] as float)*0.30, 20.0)
		cabin.position = Vector2(-(d[2] as float)*0.15, -20.0)
		cont.add_child(cabin)
		var mast := Polygon2D.new()
		mast.color = Color(0.35, 0.28, 0.18, 1.0)
		mast.polygon = PackedVector2Array([Vector2(-1.5,0),Vector2(1.5,0),Vector2(1.5,-36),Vector2(-1.5,-36)])
		mast.position = Vector2(0, -20.0)
		cont.add_child(mast)


func _animate_boats(delta: float) -> void:
	for i: int in _boat_times.size():
		_boat_times[i] += delta
		var boat: Node2D = boats_layer.get_child(i)
		if not is_instance_valid(boat):
			continue
		var base_y: float = boat.get_meta("bob_base_y", boat.position.y)
		boat.position.y = base_y + sin(_boat_times[i] * TAU / 2.6) * 2.8


func _build_pier() -> void:
	var pier := ColorRect.new()
	pier.color = C_PIER
	pier.size = Vector2(VIEW_W, VIEW_H - CURB_TOP_Y)
	pier.position = Vector2(0, CURB_TOP_Y)
	foreground_layer.add_child(pier)
	var edge := ColorRect.new()
	edge.color = C_PIER_EDGE
	edge.size = Vector2(VIEW_W, 8.0)
	edge.position = Vector2(0, CURB_TOP_Y)
	foreground_layer.add_child(edge)
	for i: int in 4:
		var line := ColorRect.new()
		line.color = Color(0, 0, 0, 0.06)
		line.size = Vector2(VIEW_W, 2.0)
		line.position = Vector2(0, CURB_TOP_Y + 28.0 + i * 28.0)
		foreground_layer.add_child(line)


# ── Ambient life (seagulls) ───────────────────────────────────────────────

func _build_ambient() -> void:
	var gull_script := load("res://scripts/level2/ambient/seagull_loop.gd")
	if gull_script == null:
		return
	for i: int in 3:
		var g := Node2D.new()
		g.set_script(gull_script)
		g.set("flight_y", 100.0 + i * 48.0)
		g.set("speed", 60.0 + i * 18.0)
		g.set("from_right", (i % 2) == 1)
		g.set("wing_beat_hz", 1.2 + i * 0.2)
		ambient_layer.add_child(g)


# ── UI pop ────────────────────────────────────────────────────────────────

func _pop(node: Control) -> void:
	node.pivot_offset = node.size / 2.0
	var t := create_tween()
	t.tween_property(node, "scale", Vector2(0.85, 0.85), 0.0)
	t.tween_property(node, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
