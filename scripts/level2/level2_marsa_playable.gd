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
const COLLECTIBLE_SPAWNER := preload("res://scripts/level2/gameplay/level2_collectible_spawner.gd")
const AUDIO_MANAGER       := preload("res://scripts/audio/audio_manager.gd")
# BACKGROUND_MOTION is not used in the procedural MVP — the procedural
# background layers are Node2D containers, not Sprite2D, so they are
# incompatible with BackgroundMotion.add_layer(Sprite2D).
# The Environment Lane coder will wire real Sprite2D layers + motion later.

# ── Level 2 environment PNG auto-detector (non-fatal) ─────────────────────
const L2_ENV        := preload("res://scripts/level2/environment/level2_environment_visual.gd")
# ── Level 2 Jomana character visual (replaces Level 1 AliSprite) ──────────
const L2_JOMANA_VIS  := preload("res://scripts/level2/character/jomana_player_visual.gd")
# ── Level 2 obstacle visual skins (non-fatal, no shared code change) ──────
const L2_OBS_VIS     := preload("res://scripts/level2/gameplay/level2_obstacle_visuals.gd")
# ── Level 2 Marsa audio (replaces Level 1 fallbacks where L2 files exist) ─
const L2_AUDIO_MGR   := preload("res://scripts/level2/audio/level2_audio_manager.gd")
const L2_FAMILY_VIS  := preload("res://scripts/level2/story/level2_family_checkpoint_visuals.gd")
# ── Level 2 manifest for collectible path ─────────────────────────────────
const L2_MANIFEST    := preload("res://scripts/level2/level2_asset_manifest.gd")

# ── Level 2 encounter data ────────────────────────────────────────────────
# Level2EncounterData is available globally via its class_name declaration.
# Do NOT preload — the class_name registration handles resolution.

# ── Immutable gameplay constants (same as Level 1) ────────────────────────
const VIEW_W                  := 1152.0
const VIEW_H                  := 648.0
const ROAD_SURFACE_Y          := 510.0
const VISUAL_LANE_Y_OFFSET    := 30.0
const PLAYER_START_X          := 220.0
const PLAYER_COLLISION_HALF_H := 24.0
const CURB_TOP_Y              := 470.0
const GROUND_COLLISION_HEIGHT := 70.0
const GROUND_CENTER_Y         := ROAD_SURFACE_Y + GROUND_COLLISION_HEIGHT / 2.0
const START_PLAYER_POSITION   := Vector2(PLAYER_START_X, ROAD_SURFACE_Y - PLAYER_COLLISION_HALF_H)
const ENCOUNTER_TARGET_X      := 780.0
const ENCOUNTER_PLAYER_POSITION := Vector2(300.0, ROAD_SURFACE_Y - PLAYER_COLLISION_HALF_H)
const ENCOUNTER_CAMERA_POSITION := Vector2(540.0, 334.0)
const ENCOUNTER_CAMERA_ZOOM   := 1.35   # was 1.05 — larger = characters bigger on screen
const CHECKPOINT_ARRIVAL_SPEED := 360.0
const COUNTDOWN_DURATION      := 3.0
const GAME_OVER_DELAY         := 0.45
const L2_LAND_VISUAL_TIME     := 0.10
# Reserved for a future seamless panorama. Current harbor art is not tileable.
const HARBOR_DRIFT_SPEED      := 0.0

# ── Level 2 camera tuning constants (all Level 2 local) ───────────────────
# Increase GAMEPLAY_ZOOM to bring Jomana closer; safe range: 1.25–1.45.
# At 1.38 the visible world width is 1152/1.38 ≈ 835 px, obstacles at
# spawn X=1292 appear ~475 px ahead (world space) — comfortable react time.
const GAMEPLAY_ZOOM           := 1.28
const CAMERA_REVEAL_FROM      := 0.88
const CAMERA_CHECKPOINT_BOOST := 0.18   # 18% zoom in on checkpoint for cinematic feel
# CAM_SCREEN_X: where Jomana appears on screen (px from left at gameplay zoom).
# 200 gives ≈17% from left — plenty of road ahead visible, feels like Level 1.
const CAM_SCREEN_X            := 200.0
const CAM_SCREEN_Y            := 498.0
const CAM_TRANSITION_TIME     := 0.38
# LOOKAHEAD_X = 0: lookahead is baked directly into CAM_SCREEN_X (≤200 = leftward = more road shown).
const LOOKAHEAD_X             := 0.0
const FOLLOW_SPEED            := 5.5
# VERTICAL_OFFSET = -14: camera slightly high, keeps jump arc visible + reduces ground share.
const VERTICAL_OFFSET         := -14.0

# ── Level 2 collectible lane Y values (world coords) ─────────────────────
const L2_RUN_PICKUP_Y  := ROAD_SURFACE_Y - 55.0 + VISUAL_LANE_Y_OFFSET
const L2_LIGHT_JUMP_Y  := ROAD_SURFACE_Y - 105.0 + VISUAL_LANE_Y_OFFSET
const L2_FULL_JUMP_Y   := ROAD_SURFACE_Y - 150.0 + VISUAL_LANE_Y_OFFSET
const L2_COLLECTIBLE_VISUAL_HEIGHT := 48.0

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
@onready var ending_image: TextureRect     = $UI/GameOverPanel/EndingImage
@onready var game_over_title: Label        = $UI/GameOverPanel/Card/Title
@onready var game_over_msg: Label          = $UI/GameOverPanel/Card/Message
@onready var game_over_count: Label        = $UI/GameOverPanel/Card/CountLabel
@onready var retry_button: Button          = $UI/GameOverPanel/Card/RetryButton
@onready var restart_button: Button        = $UI/GameOverPanel/Card/RestartButton
@onready var checkpoint_panel: Control     = $UI/CheckpointPanel
@onready var cp_card: Panel                = $UI/CheckpointPanel/Card
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
var ending_active      := false
var _harbor_reveal_active := false

var audio_manager    := AUDIO_MANAGER.new()
var _obs_vis          = null         # L2ObstacleVisuals (RefCounted)
var _family_vis       = null         # Level2 family checkpoint visual helper
var _l2_audio: Node   = null         # Level2AudioManager
var _jomana_vis: Node    = null        # JomanaPlayerVisual (the active instance)
var _ali_polygon: Node2D = null        # cached $Player/Polygon2D — hidden every frame
var _jomana_shadow: Polygon2D = null   # static ground shadow at ROAD_SURFACE_Y
var _init_cam_x: float   = 0.0   # camera X at scene start, for scroll-based parallax
var _ground_base: Node2D = null   # $Ground/GroundBase — hidden when pier PNG loads
var _cam_tween: Tween
var _gameplay_cam_pos: Vector2
var _look_x: float = 0.0          # smoothed look-ahead X target
var _tracking_active: bool = false  # true during gameplay only
var _boat_times: Array[float] = []
# Per-sprite scroll positions (BackgroundMotion approach — no hard wrap jump).
# Each layer has two sprites (a=left, b=right); they move left and wrap individually.
var _gnd_a_x: float = 0.0         # pier ground sprite A local X
var _gnd_b_x: float = VIEW_W      # pier ground sprite B local X
var _boats_a_x: float = 0.0       # boats-mid sprite A local X
var _boats_b_x: float = VIEW_W    # boats-mid sprite B local X
var _bldg_a_x: float = 0.0        # buildings sprite A local X
var _bldg_b_x: float = VIEW_W     # buildings sprite B local X

# ── Merged harbour panorama (buildings + boats, 2203×253px) ─────────────────
# Scrolls as one continuous strip: city → boats → city → boats → ...
# Width per copy in world units set after texture loads (_pano_w).
var _pano_sprites: Array[Sprite2D] = []
var _pano_w: float = VIEW_W   # panorama world-width per copy (set in _build_merged_panorama)

# ── Boot ──────────────────────────────────────────────────────────────────

func _ready() -> void:
	randomize()
	_gameplay_cam_pos = _calc_cam_pos()
	_init_cam_x = _gameplay_cam_pos.x   # capture for scroll-based parallax
	ground.position = Vector2(VIEW_W / 2.0, GROUND_CENTER_Y)

	obstacle_spawner.setup(spawn_timer)
	obstacle_spawner.obstacle_passed.connect(_on_obstacle_passed)
	obstacle_spawner.obstacle_hit.connect(_on_obstacle_hit)
	collectible_spawner.setup(col_spawn_timer, obstacle_spawner)
	collectible_spawner.configure_lanes(ROAD_SURFACE_Y, VISUAL_LANE_Y_OFFSET)
	collectible_spawner.collectible_spawned.connect(_on_collectible_spawned)

	audio_manager.setup(self)

	# Level 2 audio — all local to this scene, never touches Level 1 manager.
	_l2_audio = L2_AUDIO_MGR.new()
	_l2_audio.name = "L2AudioManager"
	add_child(_l2_audio)
	_l2_audio.setup(self, audio_manager)

	# Initial background position before first _process tick.
	_update_background_parallax()

	# Try loading real PNG environment layers — falls back to procedural if missing.
	var env_loader := L2_ENV.new()
	var any_real := env_loader.setup(bg_node)
	if not any_real:
		_build_backgrounds()   # procedural fallback

	# Replace buildings layer with merged panorama (city+boats continuous scroll).
	# Must run AFTER env_visual so we can replace its sprites.
	_build_merged_panorama()

	# Hide the GroundBase visual polygon when the real pier PNG is loaded.
	# GroundBase z_index=-1 renders in front of the pier sprite z_index=-5 and
	# would otherwise appear as a large brown rectangle covering the pier art.
	_ground_base = ground.get_node_or_null("GroundBase") as Node2D
	if _ground_base != null:
		_ground_base.visible = not L2_MANIFEST.file_exists(L2_MANIFEST.BG_PIER)

	_build_ambient()
	_build_ambient_props()
	_setup_jomana_visual()
	_tune_level2_player_fx()

	# Level 2 obstacle visual skins (RefCounted helper — not a Node).
	_obs_vis = L2_OBS_VIS.new()
	_family_vis = L2_FAMILY_VIS.new()
	obstacle_spawner.obstacle_spawned.connect(_on_obstacle_spawned_l2)

	play_button.pressed.connect(_on_play_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	retry_button.pressed.connect(_on_retry_pressed)
	cp_continue.pressed.connect(_on_continue_pressed)

	if player.has_signal("landed"):
		player.landed.connect(_on_player_landed)
	if player.has_signal("jumped"):
		player.jumped.connect(_on_player_jumped)

	_show_start_screen()
	audio_manager.play_calm_music()
	print("[L2 parallax] mode=fixed_camera_ambient sky=fixed harbor=fixed boats=bob flags=sway rope=disabled pier=fixed")


# ── Frame ─────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	# Suppress Level 1 Ali visual every frame.
	# player.gd._physics_process() re-enables ali_sprite and placeholder_shape each frame.
	# _process() runs after _physics_process(), so these are the final values before render.
	if is_instance_valid(_jomana_vis):
		jomana_sprite.visible = false
		if _ali_polygon != null:
			_ali_polygon.visible = false

	# Ground shadow: tracks player X, fixed at pier surface Y = ROAD_SURFACE_Y + VISUAL_LANE_Y_OFFSET.
	# Visible only while playing (not on menu, not game over, not checkpoint pause).
	if _jomana_shadow != null and is_instance_valid(player):
		_jomana_shadow.position.x = player.position.x
		_jomana_shadow.position.y = ROAD_SURFACE_Y + VISUAL_LANE_Y_OFFSET
		_jomana_shadow.visible = started and not game_over and not checkpoint_active

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

	# Always update background positions (start screen, gameplay, checkpoint).
	_update_background_parallax()

	# If gameplay is active and Jomana is stuck in IDLE, push her to RUN.
	# Catches any timing edge-case where set_pose(RUN) was missed.
	if started and not game_over and not checkpoint_active and not countdown_active and not _harbor_reveal_active:
		if is_instance_valid(_jomana_vis) and _jomana_vis.get_pose() == _jomana_vis.Pose.IDLE:
			_jomana_vis.set_pose(_jomana_vis.Pose.RUN)

	if started and not game_over and not checkpoint_active and not countdown_active and not _harbor_reveal_active:
		_animate_boats(delta)
		# BackgroundMotion-style parallax (same technique as Level 1).
		# Sprites move left; when a sprite's right edge clears 0, snap it
		# to follow the other sprite — no hard fmod jump.
		# Factors: ground 60% (Level 1 uses 65%), boats 12%, buildings 4%.
		var gnd_move  := current_speed * 0.60 * delta
		var boat_move := current_speed * 0.12 * delta
		var bldg_move := current_speed * 0.04 * delta

		_gnd_a_x -= gnd_move;  _gnd_b_x -= gnd_move
		if _gnd_a_x + VIEW_W <= 0: _gnd_a_x = _gnd_b_x + VIEW_W
		if _gnd_b_x + VIEW_W <= 0: _gnd_b_x = _gnd_a_x + VIEW_W

		# Boats-mid scrolls at 8% (slightly faster than buildings at 4%).
		# Sprites wrap individually — no hard position jump.
		_boats_a_x -= boat_move; _boats_b_x -= boat_move
		if _boats_a_x + VIEW_W <= 0: _boats_a_x = _boats_b_x + VIEW_W
		if _boats_b_x + VIEW_W <= 0: _boats_b_x = _boats_a_x + VIEW_W

		# Panorama wraps using _pano_w (merged image world width, wider than VIEW_W).
		_bldg_a_x -= bldg_move;  _bldg_b_x -= bldg_move
		if _bldg_a_x + _pano_w <= 0: _bldg_a_x = _bldg_b_x + _pano_w
		if _bldg_b_x + _pano_w <= 0: _bldg_b_x = _bldg_a_x + _pano_w
		# No per-frame horizontal tracking — camera is fixed.
		# Look-ahead is baked into _gameplay_cam_pos once at _ready().
		# _tracking_active and _look_x are kept for compatibility but unused.


func _unhandled_input(event: InputEvent) -> void:
	if not started or game_over or checkpoint_active or countdown_active or _harbor_reveal_active:
		return
	if event.is_action_pressed("ui_accept"):
		player.jump()


func _input(event: InputEvent) -> void:
	# Pointer input is handled before GUI dispatch so passive HUD Controls cannot
	# swallow gameplay taps. State gates keep menu/dialogue buttons jump-safe.
	if started and not game_over and not checkpoint_active and not countdown_active and not _harbor_reveal_active:
		var mouse_jump: bool = (
			event is InputEventMouseButton
			and event.pressed
			and event.button_index == MOUSE_BUTTON_LEFT
		)
		var touch_jump: bool = event is InputEventScreenTouch and event.pressed
		if mouse_jump or touch_jump:
			player.jump()
			get_viewport().set_input_as_handled()
			return

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
	_harbor_reveal_active = false
	_gnd_a_x = 0.0;   _gnd_b_x = VIEW_W
	_boats_a_x = 0.0; _boats_b_x = VIEW_W
	_bldg_a_x = 0.0;  _bldg_b_x = _pano_w
	boats_layer.visible = false
	game_over = false
	ending_active = false
	score = 0
	collectible_count = 0
	col_snapshot = 0
	last_checkpoint = Level2EncounterData.NONE
	start_screen.visible = true
	score_label.visible = false
	_update_hud()
	game_over_panel.visible = false
	ending_image.visible = false
	retry_button.text = "إعادة المحاولة من آخر نقطة"
	restart_button.text = "إعادة البدء"
	checkpoint_panel.visible = false
	countdown_overlay.visible = false
	obstacle_spawner.stop_spawning()
	obstacle_spawner.clear_obstacles()
	collectible_spawner.stop_spawning()
	collectible_spawner.clear_collectibles()
	_cleanup_encounter(false)
	player.reset_player(START_PLAYER_POSITION)
	_apply_default_cam()
	# Show idle/story pose on the menu — not running.
	if is_instance_valid(_jomana_vis):
		_jomana_vis.set_pose(_jomana_vis.Pose.IDLE)


func _on_play_pressed() -> void:
	if started:
		return
	print("[L2 play] pressed")
	get_tree().paused = false
	start_screen.visible = false
	if is_instance_valid(_l2_audio):
		_l2_audio.play_gameplay_music()
	if is_instance_valid(_jomana_vis):
		_jomana_vis.modulate.a = 0.78
		_jomana_vis.set_pose(_jomana_vis.Pose.IDLE)
		create_tween().tween_property(_jomana_vis, "modulate:a", 1.0, 0.18)
	_begin_run(0, Level2EncounterData.NONE, 225.0)
	player.set_gameplay_active(false)
	# ONE camera transition. _play_harbor_reveal tweens from open view → gameplay pos.
	# _begin_run does NOT touch the camera to avoid a race condition.
	_play_harbor_reveal()
	print("[L2 play] started=%s tree_paused=%s" % [started, get_tree().paused])


func debug_start_gameplay_for_smoke() -> void:
	_on_play_pressed()


func debug_trigger_ali_checkpoint_for_smoke() -> void:
	_start_checkpoint(Level2EncounterData.ALI)


func debug_complete_checkpoint_for_smoke() -> void:
	if not checkpoint_active:
		return
	var enc := Level2EncounterData.get_encounter(current_enc_id)
	var steps: Array = enc.get("dialogue_steps", [])
	enc_step = maxi(steps.size() - 1, 0)
	_show_enc_step()
	_on_continue_pressed()
	countdown_remaining = 0.05


func debug_show_ending_for_smoke() -> void:
	_show_level2_ending()


func _begin_run(initial_score: int, checkpoint: int, speed: float) -> void:
	score = initial_score
	current_speed = speed
	last_checkpoint = checkpoint
	ending_active = false
	game_over_title.text = Level2EncounterData.rtl_safe("انتهت المحاولة")
	retry_button.text = "إعادة المحاولة من آخر نقطة"
	restart_button.text = "إعادة البدء"
	collectible_count = (col_snapshot if checkpoint != Level2EncounterData.NONE else 0)
	if checkpoint == Level2EncounterData.NONE:
		col_snapshot = 0
	game_over = false
	checkpoint_active = false
	countdown_active = false
	npc_arriving = false
	started = true
	score_label.visible = true
	_update_hud()
	game_over_panel.visible = false
	ending_image.visible = false
	checkpoint_panel.visible = false
	countdown_overlay.visible = false
	player.reset_player(START_PLAYER_POSITION)
	player.set_gameplay_active(true)
	_start_runtime_spawners()
	# Camera is NOT set here to avoid the race with _play_harbor_reveal().
	# Only _play_harbor_reveal() (on first play) or _apply_gameplay_cam() (on retry)
	# should drive the camera transition.
	audio_manager.play_gameplay_music()


func _start_runtime_spawners(after_checkpoint := false) -> void:
	var obstacle_started := false
	var collectible_started := false
	if is_instance_valid(obstacle_spawner) and obstacle_spawner.has_method("start_spawning"):
		obstacle_spawner.clear_obstacles()
		if after_checkpoint and obstacle_spawner.has_method("grant_safety_window"):
			obstacle_spawner.grant_safety_window(1)
		obstacle_spawner.start_spawning(current_speed)
		obstacle_started = true
	else:
		push_warning("[L2 play] obstacle spawner unavailable; gameplay continues")
	if is_instance_valid(collectible_spawner) and collectible_spawner.has_method("start_spawning"):
		collectible_spawner.clear_collectibles()
		if after_checkpoint and collectible_spawner.has_method("restart_after_checkpoint"):
			collectible_spawner.restart_after_checkpoint(current_speed)
		else:
			collectible_spawner.start_spawning(current_speed)
		collectible_started = true
	else:
		push_warning("[L2 play] collectible spawner unavailable; gameplay continues")
	print("[L2 play] obstacle_spawner_started=%s" % obstacle_started)
	print("[L2 play] collectible_spawner_started=%s" % collectible_started)


# ── Obstacle events ───────────────────────────────────────────────────────

func _on_obstacle_passed() -> void:
	score += 1
	_update_hud()
	_pop(score_label)
	var char_id := Level2EncounterData.get_encounter_for_score(score)
	if char_id != Level2EncounterData.NONE:
		_start_checkpoint(char_id)


func _on_obstacle_hit() -> void:
	_end_run()


# ── Collectibles ──────────────────────────────────────────────────────────

func _on_collectible_spawned(c: Node) -> void:
	c.collected.connect(_on_collected)
	_apply_l2_collectible_visual(c)


func _apply_l2_collectible_visual(c: Node) -> void:
	# Hide ALL Level 1 collectible visuals:
	# - Polygon2D (yellow star placeholder, visible when no texture found)
	# - ShardSprite (Sprite2D with the hearts/stars animation sheet from collectible.gd)
	for node_name in ["Polygon2D", "ShardSprite"]:
		var n := c.get_node_or_null(node_name)
		if n != null:
			(n as Node2D).visible = false
	# Load Level 2 أثر shard PNG.
	var path := L2_MANIFEST.COL_SHARD_SINGLE
	if not L2_MANIFEST.file_exists(path):
		return   # keep hidden — L2 art missing, blank collectible is OK
	var tex := load(path) as Texture2D
	if tex == null:
		return
	if c.get_node_or_null("L2ShardSprite") != null:
		return   # already applied
	var sprite := Sprite2D.new()
	sprite.name = "L2ShardSprite"
	sprite.texture = tex
	var s := L2_COLLECTIBLE_VISUAL_HEIGHT / float(tex.get_height())
	sprite.scale = Vector2(s, s)
	c.add_child(sprite)


func _on_collected() -> void:
	collectible_count += 1
	_update_hud()
	if is_instance_valid(_l2_audio):
		_l2_audio.play_pickup()
	else:
		audio_manager.play_shard_pickup()


func _update_hud() -> void:
	score_label.text = "الأثر: %d   ✦ %d" % [score, collectible_count]


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
	player.reset_player(ENCOUNTER_PLAYER_POSITION)
	player.set_gameplay_active(false)
	get_tree().paused = true
	audio_manager.play_calm_music()
	if is_instance_valid(_l2_audio):
		_l2_audio.play_checkpoint()
	else:
		audio_manager.play_checkpoint()
	if is_instance_valid(_jomana_vis):
		_jomana_vis.set_pose(_jomana_vis.Pose.STORY)
	_apply_checkpoint_cam()
	var enc := Level2EncounterData.get_encounter(char_id)
	npc_label.text = enc.get("placeholder_text", "؟")
	encounter_npc.visible = true
	encounter_npc.position.x = 1050.0
	encounter_npc.position.y = ROAD_SURFACE_Y + VISUAL_LANE_Y_OFFSET
	_build_npc_card(char_id, enc)
	npc_arriving = true
	print("[L2 encounter] start id=%d" % char_id)
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
	var speaker: String = step.get("speaker", enc.get("speaker_name", ""))

	checkpoint_panel.visible = true
	cp_speaker.text = Level2EncounterData.rtl_safe(speaker)

	# Speech bubble — compact card fixed near screen top, positioned on the
	# SAME SIDE as the speaker (natural/intuitive):
	#   Jomana (left of screen) → card LEFT
	#   NPC    (right of screen) → card RIGHT
	#   Reward                  → centered
	# Card is narrow (500px) and short (100px) so it stays ABOVE all characters'
	# heads even for the tall Father portrait (head at ~y≈117px, card ends at y≈108).
	const CARD_W := 500.0
	const CARD_H := 100.0
	const CARD_T := 8.0    # distance from screen top
	cp_card.set_offsets_preset(Control.PRESET_TOP_LEFT)
	cp_card.clip_contents = true   # prevent labels overflowing card bounds
	cp_card.offset_top    = CARD_T
	cp_card.offset_bottom = CARD_T + CARD_H
	match role:
		Level2EncounterData.ROLE_HELPER:
			# NPC is on the RIGHT — card anchors to right edge
			cp_card.offset_right = VIEW_W - 16.0
			cp_card.offset_left  = VIEW_W - 16.0 - CARD_W
		Level2EncounterData.ROLE_JOMANA:
			# Jomana is on the LEFT — card anchors to left edge
			cp_card.offset_left  = 16.0
			cp_card.offset_right = 16.0 + CARD_W
		Level2EncounterData.ROLE_REWARD:
			# Centered
			cp_card.offset_left  = (VIEW_W - CARD_W) / 2.0
			cp_card.offset_right = (VIEW_W + CARD_W) / 2.0

	# Fit internal labels to the compact 100px card height.
	# speaker: 4-26px, text area: 28-94px, button: 58-94px (reward only).
	cp_speaker.offset_top    = 4;   cp_speaker.offset_bottom    = 26
	cp_speaker.offset_left   = 0;   cp_speaker.offset_right     = CARD_W
	cp_char_line.offset_top  = 28;  cp_char_line.offset_bottom  = 94
	cp_char_line.offset_left = 10;  cp_char_line.offset_right   = CARD_W - 10
	cp_jomana_line.offset_top  = 28; cp_jomana_line.offset_bottom  = 94
	cp_jomana_line.offset_left = 10; cp_jomana_line.offset_right   = CARD_W - 10
	cp_reward.offset_top  = 26;  cp_reward.offset_bottom  = 62
	cp_reward.offset_left = 0;   cp_reward.offset_right   = CARD_W
	cp_continue.offset_top  = 60; cp_continue.offset_bottom  = 96
	cp_continue.offset_left = 90; cp_continue.offset_right   = CARD_W - 90
	# Smaller font so text fits cleanly in 66px text area
	cp_char_line.add_theme_font_size_override("font_size", 19)
	cp_jomana_line.add_theme_font_size_override("font_size", 19)
	cp_speaker.add_theme_font_size_override("font_size", 15)
	cp_reward.add_theme_font_size_override("font_size", 17)

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


func _cleanup_encounter(log_cleanup := true) -> void:
	npc_arriving = false
	encounter_npc.visible = false
	npc_label.visible = false
	for child in encounter_npc.get_children():
		if child != npc_label:
			child.queue_free()
	cp_speaker.text = ""
	cp_char_line.text = ""
	cp_jomana_line.text = ""
	cp_reward.text = ""
	cp_reward.visible = false
	cp_continue.visible = false
	player.reset_player(START_PLAYER_POSITION)
	player.set_gameplay_active(false)
	if is_instance_valid(_jomana_vis):
		_jomana_vis.set_pose(_jomana_vis.Pose.IDLE)
	if log_cleanup:
		print("[L2 encounter] cleanup id=%d" % current_enc_id)
		print("[L2 encounter] npc_removed=true")


func _on_continue_pressed() -> void:
	if not checkpoint_active:
		return
	var enc := Level2EncounterData.get_encounter(current_enc_id)
	checkpoint_panel.visible = false
	get_tree().paused = false
	checkpoint_active = false
	_cleanup_encounter(true)

	if current_enc_id == Level2EncounterData.FATHER:
		_show_level2_ending()
		return

	var new_speed: float = enc.get("post_speed", current_speed)
	current_speed = new_speed
	countdown_active = true
	countdown_remaining = COUNTDOWN_DURATION
	countdown_label.text = "3"
	countdown_overlay.visible = true
	_apply_gameplay_cam_tween()


func _finish_countdown() -> void:
	player.set_gameplay_active(true)
	_start_runtime_spawners(true)
	_apply_gameplay_cam()
	audio_manager.play_gameplay_music()
	if is_instance_valid(_jomana_vis):
		_jomana_vis.set_pose(_jomana_vis.Pose.RUN)
	print("[L2 encounter] resume gameplay obstacles=true collectibles=true")


# ── Game Over ─────────────────────────────────────────────────────────────

func _end_run() -> void:
	if game_over or checkpoint_active or countdown_active:
		return
	game_over = true
	if is_instance_valid(_jomana_vis):
		_jomana_vis.set_pose(_jomana_vis.Pose.IDLE)
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
	ending_image.visible = false
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


# ── Level 2 ending (after Father checkpoint) ──────────────────────────────

func _show_level2_ending() -> void:
	started = false
	ending_active = true
	player.set_gameplay_active(false)
	obstacle_spawner.stop_spawning()
	collectible_spawner.stop_spawning()
	if is_instance_valid(_jomana_vis):
		_jomana_vis.set_pose(_jomana_vis.Pose.STORY)
	encounter_npc.visible = false
	ending_image.visible = false
	ending_image.texture = null
	if L2_MANIFEST.file_exists(L2_MANIFEST.FAM_ENDING):
		ending_image.texture = load(L2_MANIFEST.FAM_ENDING) as Texture2D
		ending_image.visible = ending_image.texture != null
	game_over_title.text = Level2EncounterData.rtl_safe("أحسنتِ يا جمانة!")
	game_over_msg.text   = Level2EncounterData.rtl_safe("كل كلمة طيبة تترك أثرًا.")
	game_over_count.text = "الأثر الذي تركتِه: %d" % collectible_count
	retry_button.visible   = true
	restart_button.visible = true
	retry_button.text = "العودة إلى القائمة"
	restart_button.text = "إعادة الفصل الثاني"
	var card: Panel = $UI/GameOverPanel/Card
	game_over_panel.modulate.a = 0.0
	card.scale = Vector2(0.92, 0.92)
	card.pivot_offset = card.size / 2.0
	game_over_panel.visible = true
	var t := create_tween().set_parallel()
	t.tween_property(game_over_panel, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE)
	t.tween_property(card, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	restart_button.grab_focus()


func _on_restart_pressed() -> void:
	ending_active = false
	_begin_run(0, Level2EncounterData.NONE, 225.0)
	_apply_gameplay_cam()


func _on_retry_pressed() -> void:
	if ending_active:
		ending_active = false
		_show_start_screen()
		return
	if is_instance_valid(_l2_audio):
		_l2_audio.play_retry()
	if last_checkpoint == Level2EncounterData.NONE:
		_begin_run(0, Level2EncounterData.NONE, 225.0)
		return
	var enc := Level2EncounterData.get_encounter(last_checkpoint)
	_begin_run(enc.get("retry_score", 0), last_checkpoint, enc.get("post_speed", 225.0))


# ── Camera ────────────────────────────────────────────────────────────────

func _calc_cam_pos() -> Vector2:
	# LOOKAHEAD_X is baked here so _gameplay_cam_pos is the ONE fixed camera
	# position used throughout gameplay — no per-frame X updates needed.
	# +LOOKAHEAD_X/ZOOM shifts camera RIGHT so we see more of the upcoming road.
	var cam_x := PLAYER_START_X - (CAM_SCREEN_X - VIEW_W / 2.0) / GAMEPLAY_ZOOM \
		+ LOOKAHEAD_X / GAMEPLAY_ZOOM
	var cam_y := ROAD_SURFACE_Y - (CAM_SCREEN_Y - VIEW_H / 2.0) / GAMEPLAY_ZOOM \
		+ VERTICAL_OFFSET
	var pos := Vector2(cam_x, cam_y)
	# Debug: verify framing once at startup
	var player_screen_x := (PLAYER_START_X - cam_x) * GAMEPLAY_ZOOM + VIEW_W / 2.0
	var road_screen_y   := (ROAD_SURFACE_Y  - cam_y) * GAMEPLAY_ZOOM + VIEW_H / 2.0
	var pier_screen_pct := 72.0  # hardcoded to match parallax update
	var ground_share    := 100.0 - pier_screen_pct
	print("[L2 framing] player_screen_x=%.0f  road_screen_y=%.0f  ground_share=%.0f%%  zoom=%.2f" %
		[player_screen_x, road_screen_y, ground_share, GAMEPLAY_ZOOM])
	return pos


func _apply_gameplay_cam() -> void:
	# Fixed camera — no tracking after transition. Look-ahead is baked into position.
	_tracking_active = false
	game_camera.position = _gameplay_cam_pos
	game_camera.zoom     = Vector2(GAMEPLAY_ZOOM, GAMEPLAY_ZOOM)


func _apply_default_cam() -> void:
	_tracking_active = false
	_tween_cam(Vector2(VIEW_W / 2.0, VIEW_H / 2.0), Vector2.ONE)


func _apply_checkpoint_cam() -> void:
	_tracking_active = false
	_tween_cam(
		ENCOUNTER_CAMERA_POSITION,
		Vector2(ENCOUNTER_CAMERA_ZOOM, ENCOUNTER_CAMERA_ZOOM),
		0.45
	)


func _apply_gameplay_cam_tween() -> void:
	_tracking_active = false
	_tween_cam(
		_gameplay_cam_pos,
		Vector2(GAMEPLAY_ZOOM, GAMEPLAY_ZOOM),
		0.35
	)


func _play_harbor_reveal() -> void:
	# Soft reveal: start slightly zoomed out, settle into full gameplay framing
	_harbor_reveal_active = true
	game_camera.position = Vector2(VIEW_W / 2.0, VIEW_H / 2.0 + 20.0)
	game_camera.zoom = Vector2(CAMERA_REVEAL_FROM, CAMERA_REVEAL_FROM)
	_tween_cam(_gameplay_cam_pos, Vector2(GAMEPLAY_ZOOM, GAMEPLAY_ZOOM), 1.4)
	if _cam_tween != null:
		_cam_tween.finished.connect(
			func() -> void:
				_harbor_reveal_active = false
				player.set_gameplay_active(true)
				if is_instance_valid(_jomana_vis):
					_jomana_vis.set_pose(_jomana_vis.Pose.RUN)
				print("[L2 play] camera_transition_done=true run_started=true"),
			CONNECT_ONE_SHOT
		)


func _tween_cam(tpos: Vector2, tzoom: Vector2, dur := CAM_TRANSITION_TIME) -> void:
	if _cam_tween != null and _cam_tween.is_valid():
		_cam_tween.kill()
	_cam_tween = create_tween().set_parallel()
	_cam_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_cam_tween.tween_property(game_camera, "position", tpos, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_cam_tween.tween_property(game_camera, "zoom", tzoom, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


# ── Jomana real art wiring ────────────────────────────────────────────────

func _setup_jomana_visual() -> void:
	var vis := L2_JOMANA_VIS.new()
	vis.name = "JomanaVisual"
	player.add_child(vis)
	_jomana_vis = vis
	vis.set_visual_lane_offset(VISUAL_LANE_Y_OFFSET)
	var visual_baseline := ROAD_SURFACE_Y + VISUAL_LANE_Y_OFFSET
	var feet_screen_y := (visual_baseline - _gameplay_cam_pos.y) * GAMEPLAY_ZOOM + VIEW_H / 2.0
	var pickup_screen_y := (L2_RUN_PICKUP_Y - _gameplay_cam_pos.y) * GAMEPLAY_ZOOM + VIEW_H / 2.0
	print("[L2 lane] visual_offset=%.0f player_feet_screen_y=%.0f obstacle_base_screen_y=%.0f collectible_low_y=%.0f collectible_low_screen_y=%.0f" % [
		VISUAL_LANE_Y_OFFSET, feet_screen_y, feet_screen_y, L2_RUN_PICKUP_Y, pickup_screen_y
	])

	# Cache Level 1 visual nodes for per-frame suppression.
	# player.gd._physics_process() calls _set_visual_pose() every frame which
	# re-enables ali_sprite.visible and placeholder_shape.visible.
	# We counter it by hiding them every _process() (which runs after physics).
	_ali_polygon = player.get_node_or_null("Polygon2D") as Node2D
	jomana_sprite.visible = false
	if _ali_polygon != null:
		_ali_polygon.visible = false

	# Start in IDLE — menu should not show Jomana running in place.
	vis.set_pose(vis.Pose.IDLE)

	# Static ground shadow — stays at ROAD_SURFACE_Y + visual offset regardless of
	# jump height. Follows player X every frame via _process(). z=-3 renders behind
	# player (z=0) and obstacles but above the pier ground (z=-5).
	if _jomana_shadow == null:
		var shd := Polygon2D.new()
		shd.name = "JomanaGroundShadow"
		shd.color = Color(0.0, 0.0, 0.0, 0.30)
		shd.z_index = -3
		shd.z_as_relative = false
		var pts := PackedVector2Array()
		for i in 16:
			var a := i * TAU / 16.0
			pts.append(Vector2(cos(a) * 22.0, sin(a) * 6.0))
		shd.polygon = pts
		shd.position = Vector2(PLAYER_START_X, ROAD_SURFACE_Y + VISUAL_LANE_Y_OFFSET)
		add_child(shd)
		_jomana_shadow = shd


func _tune_level2_player_fx() -> void:
	# Reuse the Player instance's proven dust emitters, but align them to
	# Jomana's Level 2 visual baseline. Shared Level 1 code stays untouched.
	for child: Node in player.get_children():
		if child is not CPUParticles2D:
			continue
		var dust := child as CPUParticles2D
		dust.position.y += VISUAL_LANE_Y_OFFSET
		dust.z_index = -1
		dust.color = Color(0.75, 0.65, 0.50, 0.58)
		if not dust.one_shot:
			dust.amount = 6
			dust.lifetime = 0.4
			dust.direction = Vector2(-1.0, -0.25)
			dust.spread = 18.0
			dust.initial_velocity_min = 30.0
			dust.initial_velocity_max = 55.0


# ── NPC checkpoint card ───────────────────────────────────────────────────

func _build_npc_card(char_id: int, enc: Dictionary) -> void:
	# Remove previous card children (keep NPCLabel for fallback).
	for child in encounter_npc.get_children():
		if child.name != "NPCLabel":
			child.queue_free()
	npc_label.visible = false   # replaced by the card below
	if _family_vis != null and _family_vis.apply_npc_art(
		encounter_npc, char_id, String(enc.get("asset_path", ""))
	):
		return

	# Character colour palette — each family member gets a distinct warm tone.
	var char_color: Color
	match char_id:
		Level2EncounterData.ALI:    char_color = Color(0.20, 0.58, 0.78, 0.95)   # teal-blue
		Level2EncounterData.ZAINAB: char_color = Color(0.78, 0.42, 0.18, 0.95)   # warm orange
		Level2EncounterData.FATIMA: char_color = Color(0.72, 0.28, 0.48, 0.95)   # rose-pink
		Level2EncounterData.FATHER: char_color = Color(0.25, 0.38, 0.55, 0.95)   # deep blue
		_:                          char_color = Color(0.35, 0.35, 0.40, 0.95)

	# Card background
	var card := Panel.new()
	card.name = "NPCCard"
	card.size = Vector2(130, 160)
	card.position = Vector2(-65, -170)
	var sty := StyleBoxFlat.new()
	sty.bg_color = char_color
	sty.corner_radius_top_left = 14
	sty.corner_radius_top_right = 14
	sty.corner_radius_bottom_right = 14
	sty.corner_radius_bottom_left = 14
	sty.shadow_color = Color(0, 0, 0, 0.4)
	sty.shadow_size = 8
	sty.shadow_offset = Vector2(0, 4)
	card.add_theme_stylebox_override("panel", sty)
	encounter_npc.add_child(card)

	# Character Arabic name — large and centred
	var speaker: String = enc.get("speaker_name", "")
	var name_lbl := Label.new()
	name_lbl.text = speaker if not speaker.is_empty() else enc.get("placeholder_text", "؟")
	name_lbl.set("text_direction", TextServer.DIRECTION_RTL)
	name_lbl.set("language", "ar")
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 34)
	name_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	name_lbl.add_theme_constant_override("outline_size", 3)
	name_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.55))
	name_lbl.size = Vector2(130, 100)
	name_lbl.position = Vector2(0, 30)
	card.add_child(name_lbl)

	# Decorative bottom strip with character accent color
	var strip := ColorRect.new()
	strip.color = Color(1, 1, 1, 0.15)
	strip.size = Vector2(130, 18)
	strip.position = Vector2(0, 140)
	card.add_child(strip)


# ── Player event handlers ─────────────────────────────────────────────────

func _on_player_jumped() -> void:
	if is_instance_valid(_l2_audio): _l2_audio.play_jump()
	else: audio_manager.play_jump()
	if is_instance_valid(_jomana_vis):
		_jomana_vis.set_pose(_jomana_vis.Pose.JUMP)


func _on_player_landed() -> void:
	audio_manager.play_land()
	if is_instance_valid(_jomana_vis):
		_jomana_vis.set_pose(_jomana_vis.Pose.LAND)
		# Return to RUN after a brief landing frame display.
		await get_tree().create_timer(L2_LAND_VISUAL_TIME).timeout
		if not game_over and not checkpoint_active and is_instance_valid(_jomana_vis):
			_jomana_vis.set_pose(
				_jomana_vis.Pose.RUN if player.is_on_floor() else _jomana_vis.Pose.JUMP
			)


# ── Background parallax ───────────────────────────────────────────────────
# Called every frame to keep every layer anchored relative to the camera so
# backgrounds fill the full 1152×648 viewport at any zoom or camera position.
# Formula: layer_pos.y = top + VIEW_H * screen_fraction / zoom
#   → places layer at <fraction>% from screen top, zoom-independent.
# Formula: layer_pos.x = left - cam_x * drift
#   → left edge at screen-left, tiny drift creates subtle parallax depth.

func _update_background_parallax() -> void:
	var cam_x  := game_camera.position.x
	var cam_y  := game_camera.position.y
	var zoom   := game_camera.zoom.x
	var hw     := VIEW_W / (2.0 * zoom)
	var hh     := VIEW_H / (2.0 * zoom)
	var left   := cam_x - hw
	var top    := cam_y - hh
	# scroll = distance camera has moved since scene start.
	# Scroll-based drift is always safe — layers never go off-screen.
	var scroll := cam_x - _init_cam_x

	# ── Sky: camera-fixed. Use 2× width so it covers the wider field-of-view
	# during the harbor reveal (zoom=0.88) without exposing a gray right edge.
	sky_layer.position = Vector2(left, top)
	var sky_a := sky_layer.get_node_or_null("RealBG_Sky") as Sprite2D
	if sky_a != null:
		# Always keep local x at 0 so the sky starts at the camera left edge.
		sky_a.position.x = 0
		# Scale x to cover 2× viewport width so the sky always fills the screen
		# regardless of reveal zoom level (0.88 → 1.28 range).
		if sky_a.texture != null:
			sky_a.scale.x = (VIEW_W * 2.0) / float(sky_a.texture.get_width())

	# ── Merged panorama: city+boats continuous scroll at 4% parallax ─────────
	# Uses _pano_sprites[0] and [1] loaded from merged.png.
	# Fallback: if merged.png unavailable, uses env_visual buildings sprites.
	buildings_layer.position.x = left
	buildings_layer.position.y = top + VIEW_H * 0.30 / zoom
	if _pano_sprites.size() >= 2:
		_pano_sprites[0].position.x = _bldg_a_x
		_pano_sprites[1].position.x = _bldg_b_x
	else:
		var ba := buildings_layer.get_node_or_null("RealBG_L2_FarBuildingsLayer_0") as Sprite2D
		var bb := buildings_layer.get_node_or_null("RealBG_L2_FarBuildingsLayer_1") as Sprite2D
		if ba: ba.position.x = _bldg_a_x
		if bb: bb.position.x = _bldg_b_x

	# ── Boats-mid: CYCLE — shown only during phase 1 of the bg cycle.
	# When visible, positioned at 30% from top (same level as buildings) so
	# the boats layer fills the harbour zone and creates a closeup-of-boats view.
	# Scrolls slightly faster than buildings (8% vs 4%) to feel like foreground.
	# Visibility and alpha are controlled by _trigger_bg_cycle() / modulate.a.
	if boats_layer.visible:
		boats_layer.position.x = left
		boats_layer.position.y = top + VIEW_H * 0.30 / zoom
		var boa := boats_layer.get_node_or_null("RealBG_L2_BoatsMidLayer_0") as Sprite2D
		var bob := boats_layer.get_node_or_null("RealBG_L2_BoatsMidLayer_1") as Sprite2D
		if boa: boa.position.x = _boats_a_x
		if bob: bob.position.x = _boats_b_x

	# ── Pier/ground: 60% parallax — closest layer, strongest motion cue ─────
	# Ground scrolling is the primary "you are running" signal (same as Level 1).
	foreground_layer.position.x = left
	foreground_layer.position.y = top + VIEW_H * 0.72 / zoom  # 72% = CURB_TOP_Y≈470
	var ga := foreground_layer.get_node_or_null("RealBG_L2_ForegroundPierLayer_0") as Sprite2D
	var gb := foreground_layer.get_node_or_null("RealBG_L2_ForegroundPierLayer_1") as Sprite2D
	if ga: ga.position.x = _gnd_a_x
	if gb: gb.position.x = _gnd_b_x


# ── Level 2 obstacle visual skins ─────────────────────────────────────────

func _on_obstacle_spawned_l2(definition: Dictionary, _pos: Vector2) -> void:
	if _obs_vis == null or obstacle_spawner.get_child_count() == 0:
		return
	# The obstacle is already in the tree when the signal fires (spawner emits after add_child).
	var obs_type: String = definition.get("id", definition.get("type", ""))
	var newest: Node = obstacle_spawner.get_child(obstacle_spawner.get_child_count() - 1)
	if newest is Node2D:
		_obs_vis.apply_skin(newest as Node2D, obs_type, VISUAL_LANE_Y_OFFSET)


# ── Jomana visual tag (legacy placeholder fallback) ───────────────────────

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


func _build_merged_panorama() -> void:
	## Load merged.png (buildings+boats panorama) and replace the buildings layer
	## sprites with two side-by-side copies of the panorama for seamless scrolling.
	## The panorama is 2203×253px. Scale it so height = 260 world units (fills harbor zone).
	var tex := load(L2_MANIFEST.BG_MERGED) as Texture2D
	if tex == null:
		push_warning("[L2 pano] merged.png not found — keeping buildings from env_visual")
		return

	# Remove env_visual sprites from buildings layer (they loaded bg_harbor_buildings.png).
	for child in buildings_layer.get_children():
		child.queue_free()

	# Scale uniformly so the panorama is 260 world units tall.
	var s := 260.0 / float(tex.get_height())
	_pano_w = float(tex.get_width()) * s   # panorama world width per copy
	_bldg_a_x = 0.0
	_bldg_b_x = _pano_w   # second copy starts where first ends

	# Top-fade shader to blend panorama top into the sky seamlessly.
	var fade_sh := load("res://assets/level2/marsa/shaders/bg_top_fade.gdshader") as Shader

	for i in 2:
		var spr := Sprite2D.new()
		spr.name = "Pano_%d" % i
		spr.texture = tex
		spr.centered = false
		spr.scale = Vector2(s, s)
		spr.position = Vector2(float(i) * _pano_w, 0.0)
		if fade_sh != null:
			var mat := ShaderMaterial.new()
			mat.shader = fade_sh
			mat.set_shader_parameter("fade_px", 40.0)
			spr.material = mat
		buildings_layer.add_child(spr)
		_pano_sprites.append(spr)

	print("[L2 pano] merged panorama ready: pano_w=%.0f world_units" % _pano_w)


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
	# flight_y values in WORLD space. Camera at world y≈384 sees from y≈149.
	# y=175-235 places seagulls in the sky area (screen top 5-18%).
	for i: int in 3:
		var g := Node2D.new()
		g.set_script(gull_script)
		g.set("flight_y", 175.0 + i * 30.0)
		g.set("speed", 55.0 + i * 14.0)
		g.set("from_right", (i % 2) == 1)
		g.set("wing_beat_hz", 1.2 + i * 0.2)
		ambient_layer.add_child(g)


func _build_ambient_props() -> void:
	# flip_h=true: boats face RIGHT so they look like they're sailing WITH Jomana.
	_add_ambient_sprite(L2_MANIFEST.AMB_BOAT_BLUE, Vector2(520, 438), 92.0,
		"HarborBoatBlue", "res://scripts/level2/ambient/harbor_ambient_bob.gd", true)
	_add_ambient_sprite(L2_MANIFEST.AMB_BOAT_SMALL, Vector2(790, 444), 68.0,
		"HarborBoatSmall", "res://scripts/level2/ambient/harbor_ambient_bob.gd", true)
	# Flags disabled: the bunting art has no visible anchor pole on the left side,
	# making it appear to float in the air. Re-enable if a version with poles is provided.
	# _add_ambient_sprite(L2_MANIFEST.AMB_FLAGS, ...)
	# Rope disabled: the current transparent art has no visible posts/anchor context.
	_add_ambient_sprite(L2_MANIFEST.AMB_DECO_NET, Vector2(1080, 490), 58.0,
		"HarborNet", "")


func _add_ambient_sprite(
		path: String, world_pos: Vector2, target_height: float,
		node_name: String, motion_script_path: String, flip_h: bool = false
) -> void:
	var tex := load(path) as Texture2D
	if tex == null or tex.get_height() <= 0:
		push_warning("[L2 ambient] missing %s" % path)
		return
	var holder := Node2D.new()
	holder.name = node_name
	holder.position = world_pos
	holder.z_index = -8
	if not motion_script_path.is_empty():
		var motion_script := load(motion_script_path)
		if motion_script != null:
			holder.set_script(motion_script)
	var sprite := Sprite2D.new()
	sprite.texture = tex
	sprite.scale = Vector2.ONE * (target_height / float(tex.get_height()))
	sprite.flip_h = flip_h   # true for boats so they face the direction Jomana runs
	holder.add_child(sprite)
	ambient_layer.add_child(holder)
	print("[L2 ambient] active=%s path=%s flip_h=%s" % [node_name, path, flip_h])


# ── UI pop ────────────────────────────────────────────────────────────────

func _pop(node: Control) -> void:
	node.pivot_offset = node.size / 2.0
	var t := create_tween()
	t.tween_property(node, "scale", Vector2(0.85, 0.85), 0.0)
	t.tween_property(node, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
