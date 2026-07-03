extends Node2D

## Level 2: جمانة وأثر الكلمة — مرسى زليتن
## Value: الكلمة الطيبة، الحكمة، الصبر
##
## Architecture: reuses Level 1 spawners, encounter controller, audio
## manager, collectible system, and HUD node structure unchanged.
## This script only handles what is new or different for Level 2.

# ── Shared systems (same scripts as Level 1) ──────────────────────────────
const ASSET_UTILS         := preload("res://scripts/asset_utils.gd")
const DIFFICULTY_MANAGER  := preload("res://scripts/gameplay/difficulty_manager.gd")
const OBSTACLE_SPAWNER    := preload("res://scripts/gameplay/obstacle_spawner.gd")
const COLLECTIBLE_SPAWNER := preload("res://scripts/gameplay/collectible_spawner.gd")
const AUDIO_MANAGER       := preload("res://scripts/audio/audio_manager.gd")
const ENCOUNTER_CONTROLLER := preload("res://scripts/story/encounter_controller.gd")
const BACKGROUND_MOTION   := preload("res://scripts/visual/background_motion.gd")

# ── Level 2-specific systems ──────────────────────────────────────────────
const L2_ENCOUNTER_DATA := preload("res://scripts/level2/level2_encounter_data.gd")
const HARBOR_AMBIENT    := preload("res://scripts/ambient/harbor_ambient.gd")

# ── Viewport / layout constants (same as Level 1 — immutable) ─────────────
const VIEW_W  := 1152.0
const VIEW_H  := 648.0
const ROAD_SURFACE_Y          := 510.0
const PLAYER_START_X          := 220.0
const PLAYER_COLLISION_HALF_H := 24.0
const CURB_TOP_Y              := 470.0
const GROUND_COLLISION_HEIGHT := 70.0
const GROUND_CENTER_Y := ROAD_SURFACE_Y + GROUND_COLLISION_HEIGHT / 2.0
const START_PLAYER_POSITION   := Vector2(PLAYER_START_X, ROAD_SURFACE_Y - PLAYER_COLLISION_HALF_H)

# ── Parallax factors (harbor layers feel deeper than city) ────────────────
const SEA_FAR_FACTOR       := 0.02
const BUILDINGS_FACTOR     := 0.05
const BOATS_MID_FACTOR     := 0.12
const FOREGROUND_FACTOR    := 0.18
const GROUND_FACTOR        := 0.65

# ── Gameplay speeds (same progression as Level 1 for now) ─────────────────
const BASE_SPEED := 225.0

# ── Story / encounter positions ───────────────────────────────────────────
const ENCOUNTER_TARGET_X   := 610.0
const CHECKPOINT_ARRIVAL_SPEED := 360.0
const COUNTDOWN_DURATION   := 3.0
const GAME_OVER_IMPACT_DELAY   := 0.45

# ── Camera tweaks (Level 2 is more cinematic) ─────────────────────────────
const GAMEPLAY_ZOOM := 1.18          # slightly deeper than Level 1's 1.15
const CAMERA_TARGET_SCREEN_X := 230.0
const CAMERA_TARGET_SCREEN_Y := 498.0

# ── Node references ───────────────────────────────────────────────────────
@onready var level_camera: Camera2D = $LevelCamera
@onready var player: CharacterBody2D = $Player
@onready var jomana_sprite: Sprite2D = $Player/JomanaSprite
@onready var ground: StaticBody2D    = $Ground
@onready var bg_node: Node2D         = $BG
@onready var sea_far_sprite: Sprite2D      = $BG/SeaFarSprite
@onready var buildings_sprite: Sprite2D   = $BG/BuildingsSprite
@onready var boats_mid_sprite: Sprite2D   = $BG/BoatsMidSprite
@onready var foreground_sprite: Sprite2D  = $BG/ForegroundSprite
@onready var ground_sprite: Sprite2D      = $Ground/GroundSprite
@onready var harbor_ambient: Node2D       = $HarborAmbient
@onready var obstacle_spawner: Node2D     = $Obstacles
@onready var spawn_timer: Timer           = $SpawnTimer
@onready var collectible_spawner: Node2D  = $Collectibles
@onready var collectible_spawn_timer: Timer = $CollectibleSpawnTimer
@onready var encounter_npc: Node2D        = $EncounterNPC
@onready var encounter_npc_label: Label   = $EncounterNPC/NPCLabel

# UI references (same HUD layout as Level 1)
@onready var score_label: Label          = $UI/ScoreLabel
@onready var light_shard_label: Label    = $UI/LightShardLabel
@onready var game_over_panel: Control    = $UI/GameOverPanel
@onready var game_over_label: Label      = $UI/GameOverPanel/GameOverCard/GameOverLabel
@onready var game_over_message: Label    = $UI/GameOverPanel/GameOverCard/GameOverMessage
@onready var game_over_light_count: Label = $UI/GameOverPanel/GameOverCard/GameOverLightCount
@onready var retry_button: Button        = $UI/GameOverPanel/GameOverCard/RetryButton
@onready var restart_button: Button      = $UI/GameOverPanel/GameOverCard/RestartButton
@onready var checkpoint_panel: Control   = $UI/CheckpointPanel
@onready var checkpoint_card: Control    = $UI/CheckpointPanel/Card
@onready var checkpoint_speaker_name: Label  = $UI/CheckpointPanel/Card/SpeakerName
@onready var checkpoint_character_line: Label = $UI/CheckpointPanel/Card/CharacterLine
@onready var checkpoint_jomana_line: Label    = $UI/CheckpointPanel/Card/AliLine
@onready var checkpoint_reward_label: Label   = $UI/CheckpointPanel/Card/RewardLabel
@onready var continue_button: Button     = $UI/CheckpointPanel/Card/ContinueButton
@onready var countdown_overlay: Control  = $UI/CountdownOverlay
@onready var countdown_label: Label      = $UI/CountdownOverlay/CountdownLabel
@onready var start_screen: Control       = $UI/StartScreen
@onready var play_button: Button         = $UI/StartScreen/PlayButton

# ── Runtime state ─────────────────────────────────────────────────────────
var score := 0
var collectible_count := 0
var collectible_count_snapshot := 0
var started := false
var game_over := false
var checkpoint_encounter_active := false
var countdown_active := false
var countdown_remaining := 0.0
var countdown_number := 0
var current_speed := BASE_SPEED
var last_checkpoint := L2_ENCOUNTER_DATA.NONE
var current_encounter_id := L2_ENCOUNTER_DATA.NONE
var encounter_arriving := false
var encounter_step := 0

var encounter_controller := ENCOUNTER_CONTROLLER.new()
var background_motion    := BACKGROUND_MOTION.new()
var audio_manager        := AUDIO_MANAGER.new()

var _camera_tween: Tween
var _countdown_tween: Tween
var _gameplay_camera_pos: Vector2

# ── Computed constants ────────────────────────────────────────────────────
func _compute_camera_pos() -> Vector2:
	return Vector2(
		PLAYER_START_X - (CAMERA_TARGET_SCREEN_X - VIEW_W / 2.0) / GAMEPLAY_ZOOM,
		ROAD_SURFACE_Y - (CAMERA_TARGET_SCREEN_Y - VIEW_H / 2.0) / GAMEPLAY_ZOOM,
	)

# ── Lifecycle ─────────────────────────────────────────────────────────────

func _ready() -> void:
	randomize()
	_gameplay_camera_pos = _compute_camera_pos()

	# Spawn system setup (same as Level 1)
	obstacle_spawner.setup(spawn_timer)
	obstacle_spawner.obstacle_passed.connect(_on_obstacle_passed)
	obstacle_spawner.obstacle_hit.connect(_on_obstacle_hit)
	collectible_spawner.setup(collectible_spawn_timer, obstacle_spawner)
	collectible_spawner.collectible_spawned.connect(_on_collectible_spawned)

	# Audio
	audio_manager.setup(self)

	# Background motion (multi-layer parallax)
	background_motion.setup(VIEW_W)
	background_motion.add_layer(sea_far_sprite,     SEA_FAR_FACTOR)
	background_motion.add_layer(buildings_sprite,   BUILDINGS_FACTOR)
	background_motion.add_layer(boats_mid_sprite,   BOATS_MID_FACTOR)
	background_motion.add_layer(foreground_sprite,  FOREGROUND_FACTOR)
	background_motion.add_layer(ground_sprite,      GROUND_FACTOR)

	# Ground position
	ground.position = Vector2(VIEW_W / 2.0, GROUND_CENTER_Y)

	# Button signals
	play_button.pressed.connect(_on_play_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	retry_button.pressed.connect(_on_retry_pressed)
	continue_button.pressed.connect(_on_continue_pressed)

	# Player signals
	if player.has_signal("landed"):
		player.landed.connect(func(): audio_manager.play_land())
	if player.has_signal("jumped"):
		player.jumped.connect(func(): audio_manager.play_jump())

	_apply_background_assets()
	_show_start_screen()
	audio_manager.play_calm_music()


func _process(delta: float) -> void:
	if encounter_arriving and encounter_npc != null:
		_update_encounter_arrival(delta)
	if countdown_active:
		_update_countdown(delta)
	if _is_motion_active():
		background_motion.update(delta, current_speed)


func _unhandled_input(event: InputEvent) -> void:
	if not started or game_over or checkpoint_encounter_active or countdown_active:
		return
	if event.is_action_pressed("ui_accept"):
		player.jump()
	elif event is InputEventMouseButton and event.pressed:
		player.jump()
	elif event is InputEventScreenTouch and event.pressed:
		player.jump()


func _input(event: InputEvent) -> void:
	if not checkpoint_encounter_active:
		return
	var enc := L2_ENCOUNTER_DATA.get_encounter(current_encounter_id)
	if enc.is_empty():
		return
	var steps: Array = enc.get("dialogue_steps", [])
	if encounter_step >= steps.size() - 1:
		return
	if _is_dialogue_advance(event):
		encounter_step += 1
		_show_encounter_step()
		get_viewport().set_input_as_handled()


# ── Start / menu ──────────────────────────────────────────────────────────

func _show_start_screen() -> void:
	started = false
	game_over = false
	score = 0
	collectible_count = 0
	collectible_count_snapshot = 0
	last_checkpoint = L2_ENCOUNTER_DATA.NONE
	start_screen.visible = true
	score_label.visible = false
	light_shard_label.visible = false
	game_over_panel.visible = false
	checkpoint_panel.visible = false
	obstacle_spawner.stop_spawning()
	obstacle_spawner.clear_obstacles()
	collectible_spawner.stop_spawning()
	collectible_spawner.clear_collectibles()
	_apply_default_framing()
	player.reset_player(START_PLAYER_POSITION)


func _on_play_pressed() -> void:
	start_screen.visible = false
	_begin_run(0, L2_ENCOUNTER_DATA.NONE, BASE_SPEED)
	_apply_establishing_reveal()


func _begin_run(initial_score: int, checkpoint: int, speed: float) -> void:
	score = initial_score
	if checkpoint == L2_ENCOUNTER_DATA.NONE:
		collectible_count = 0
		collectible_count_snapshot = 0
	else:
		collectible_count = collectible_count_snapshot
	current_speed = speed
	game_over = false
	checkpoint_encounter_active = false
	countdown_active = false
	encounter_arriving = false
	encounter_controller.reset_for_run(checkpoint)
	started = true
	start_screen.visible = false
	score_label.visible = true
	score_label.text = "النقاط: %d" % score
	light_shard_label.visible = true
	_update_shard_label()
	game_over_panel.visible = false
	checkpoint_panel.visible = false
	player.reset_player(START_PLAYER_POSITION)
	player.set_gameplay_active(true)
	obstacle_spawner.clear_obstacles()
	obstacle_spawner.start_spawning(current_speed)
	collectible_spawner.clear_collectibles()
	collectible_spawner.start_spawning(current_speed)
	_apply_gameplay_framing()
	audio_manager.play_gameplay_music()


# ── Obstacle events ───────────────────────────────────────────────────────

func _on_obstacle_passed() -> void:
	score += 1
	score_label.text = "النقاط: %d" % score
	_pop_label(score_label)
	var char_id := L2_ENCOUNTER_DATA.get_encounter_for_score(score)
	if char_id != L2_ENCOUNTER_DATA.NONE:
		_start_checkpoint_encounter(char_id)


func _on_obstacle_hit() -> void:
	if _is_zainab_shield_active():   # future: Zainab shield from Level 1 carry-over
		return
	_end_run()


# ── Collectibles ──────────────────────────────────────────────────────────

func _on_collectible_spawned(collectible: Node) -> void:
	collectible.collected.connect(_on_collected)


func _on_collected() -> void:
	collectible_count += 1
	_update_shard_label()
	_pop_label(light_shard_label)
	audio_manager.play_shard_pickup()


func _update_shard_label() -> void:
	light_shard_label.text = "الأثر: %d" % collectible_count


# ── Checkpoint encounters ─────────────────────────────────────────────────

func _start_checkpoint_encounter(char_id: int) -> void:
	if game_over or checkpoint_encounter_active:
		return
	checkpoint_encounter_active = true
	current_encounter_id = char_id
	encounter_step = 0
	obstacle_spawner.stop_spawning()
	obstacle_spawner.clear_obstacles()
	collectible_spawner.stop_spawning()
	collectible_spawner.clear_collectibles()
	player.set_gameplay_active(false)
	get_tree().paused = true
	audio_manager.play_calm_music()
	_apply_checkpoint_framing()
	audio_manager.play_checkpoint()
	_show_encounter_step()
	# Snapshot collectibles for retry
	collectible_count_snapshot = collectible_count
	last_checkpoint = char_id


func _show_encounter_step() -> void:
	var enc := L2_ENCOUNTER_DATA.get_encounter(current_encounter_id)
	if enc.is_empty():
		return
	var steps: Array = enc.get("dialogue_steps", [])
	if encounter_step >= steps.size():
		return
	var step: Dictionary = steps[encounter_step]
	var role: int = step.get("role", 0)
	var text: String = L2_ENCOUNTER_DATA.rtl_safe(step.get("text", ""))

	checkpoint_panel.visible = true
	checkpoint_speaker_name.text = enc.get("speaker_name", "")

	if role == L2_ENCOUNTER_DATA.ROLE_HELPER:
		checkpoint_character_line.text = text
		checkpoint_jomana_line.text = ""
		checkpoint_reward_label.visible = false
	elif role == L2_ENCOUNTER_DATA.ROLE_JOMANA:
		checkpoint_character_line.text = ""
		checkpoint_jomana_line.text = text
		checkpoint_reward_label.visible = false
	elif role == L2_ENCOUNTER_DATA.ROLE_REWARD:
		checkpoint_reward_label.text = text
		checkpoint_reward_label.visible = true
		checkpoint_character_line.text = ""
		checkpoint_jomana_line.text = ""
		continue_button.visible = true
		audio_manager.play_reward_star()

	# NPC placeholder label
	encounter_npc_label.text = enc.get("placeholder_text", "؟")


func _on_continue_pressed() -> void:
	if not checkpoint_encounter_active:
		return
	var enc := L2_ENCOUNTER_DATA.get_encounter(current_encounter_id)
	if enc.is_empty():
		return

	if current_encounter_id == L2_ENCOUNTER_DATA.ENDING:
		# Level complete — return to start screen
		get_tree().paused = false
		_show_start_screen()
		return

	checkpoint_panel.visible = false
	get_tree().paused = false
	checkpoint_encounter_active = false

	var new_speed: float = enc.get("post_speed", current_speed)
	_start_countdown_then_resume(new_speed)


func _start_countdown_then_resume(new_speed: float) -> void:
	countdown_active = true
	countdown_remaining = COUNTDOWN_DURATION
	countdown_number = 3
	countdown_overlay.visible = true
	countdown_label.text = "3"
	current_speed = new_speed


func _update_countdown(delta: float) -> void:
	countdown_remaining -= delta
	var new_num := ceili(countdown_remaining)
	if new_num != countdown_number and new_num > 0:
		countdown_number = new_num
		countdown_label.text = str(new_num)
		_pop_label(countdown_label)
	if countdown_remaining <= 0.0:
		countdown_active = false
		countdown_overlay.visible = false
		_finish_countdown()


func _finish_countdown() -> void:
	player.set_gameplay_active(true)
	obstacle_spawner.start_spawning(current_speed)
	collectible_spawner.start_spawning(current_speed)
	_apply_gameplay_framing()
	audio_manager.play_gameplay_music()


func _update_encounter_arrival(delta: float) -> void:
	encounter_npc.position.x = move_toward(
		encounter_npc.position.x, ENCOUNTER_TARGET_X, CHECKPOINT_ARRIVAL_SPEED * delta
	)
	if is_equal_approx(encounter_npc.position.x, ENCOUNTER_TARGET_X):
		encounter_arriving = false


# ── Game Over ─────────────────────────────────────────────────────────────

func _end_run() -> void:
	if game_over or checkpoint_encounter_active or countdown_active:
		return
	game_over = true
	audio_manager.play_hit()
	audio_manager.play_calm_music()
	_apply_default_framing()
	obstacle_spawner.stop_spawning()
	obstacle_spawner.clear_obstacles()
	collectible_spawner.stop_spawning()
	collectible_spawner.clear_collectibles()
	player.kill()
	await get_tree().create_timer(GAME_OVER_IMPACT_DELAY).timeout
	audio_manager.play_game_over()
	_show_game_over()


func _show_game_over() -> void:
	var enc := L2_ENCOUNTER_DATA.get_encounter(last_checkpoint)
	if enc.is_empty():
		game_over_message.text = L2_ENCOUNTER_DATA.rtl_safe(
			L2_ENCOUNTER_DATA.GAME_OVER_BEFORE_CHECKPOINT
		)
		retry_button.visible = false
	else:
		game_over_message.text = L2_ENCOUNTER_DATA.rtl_safe(enc.get("game_over_line", ""))
		retry_button.visible = true

	game_over_light_count.text = "الأثر الذي تركته: %d" % collectible_count
	var card: Node = game_over_panel.get_node("GameOverCard")
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
	_begin_run(0, L2_ENCOUNTER_DATA.NONE, BASE_SPEED)


func _on_retry_pressed() -> void:
	if last_checkpoint == L2_ENCOUNTER_DATA.NONE:
		_begin_run(0, L2_ENCOUNTER_DATA.NONE, BASE_SPEED)
		return
	var enc := L2_ENCOUNTER_DATA.get_encounter(last_checkpoint)
	_begin_run(
		enc.get("retry_score", 0),
		last_checkpoint,
		enc.get("post_speed", BASE_SPEED)
	)

# ── Camera framing ────────────────────────────────────────────────────────

func _apply_gameplay_framing() -> void:
	_tween_camera(_gameplay_camera_pos, Vector2(GAMEPLAY_ZOOM, GAMEPLAY_ZOOM))


func _apply_default_framing() -> void:
	_tween_camera(Vector2(VIEW_W / 2.0, VIEW_H / 2.0), Vector2.ONE)


func _apply_checkpoint_framing() -> void:
	# Subtle additional zoom for checkpoint intimacy
	_tween_camera(_gameplay_camera_pos, Vector2(GAMEPLAY_ZOOM * 1.04, GAMEPLAY_ZOOM * 1.04))


func _apply_establishing_reveal() -> void:
	# Start zoomed out, then settle into gameplay framing — cinematic opener
	level_camera.position = Vector2(VIEW_W / 2.0, VIEW_H / 2.0)
	level_camera.zoom = Vector2(0.85, 0.85)
	_tween_camera(_gameplay_camera_pos, Vector2(GAMEPLAY_ZOOM, GAMEPLAY_ZOOM), 1.8)


func _tween_camera(target_pos: Vector2, target_zoom: Vector2, dur := 0.35) -> void:
	if (
		level_camera.position.is_equal_approx(target_pos)
		and level_camera.zoom.is_equal_approx(target_zoom)
	):
		return
	if _camera_tween != null and _camera_tween.is_valid():
		_camera_tween.kill()
	_camera_tween = create_tween().set_parallel()
	_camera_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_camera_tween.tween_property(level_camera, "position", target_pos, dur) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_camera_tween.tween_property(level_camera, "zoom", target_zoom, dur) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# ── Background assets ─────────────────────────────────────────────────────

func _apply_background_assets() -> void:
	# Load Level 2 harbor backgrounds if they exist; fall back to Level 1 art.
	# Proper Level 2 art will replace these paths once sourced.
	var L2_SKY     := "res://assets/backgrounds/marsa/bg_sky_marsa.png"
	var L2_SEA_FAR := "res://assets/backgrounds/marsa/bg_sea_far.png"
	var L2_BUILDS  := "res://assets/backgrounds/marsa/bg_harbor_buildings.png"
	var L2_BOATS   := "res://assets/backgrounds/marsa/bg_boats_mid.png"
	var L2_FG      := "res://assets/backgrounds/marsa/fg_road_marsa.png"
	var L1_SKY     := "res://assets/backgrounds/mantarha/bg_sky.png.png"
	var L1_BUILDS  := "res://assets/backgrounds/mantarha/bg_buildings.png.png"
	var L1_FG      := "res://assets/backgrounds/mantarha/bg_foreground.png.png"
	var L1_GROUND  := "res://assets/backgrounds/mantarha/ground_mantarha.png.png"

	_try_load_sprite(sea_far_sprite, L2_SEA_FAR)
	_try_load_sprite_or_fallback(buildings_sprite, L2_BUILDS, L1_BUILDS)
	_try_load_sprite(boats_mid_sprite, L2_BOATS)
	_try_load_sprite_or_fallback(foreground_sprite, L2_FG, L1_FG)
	_try_load_sprite(ground_sprite, L1_GROUND)  # reuse Level 1 ground for now

	# Sky: full-viewport color rect if no asset
	var sky_img := load(L2_SKY) as Texture2D
	if sky_img == null:
		sky_img = load(L1_SKY) as Texture2D
	if sky_img != null:
		var sky_sprite: Sprite2D = get_node_or_null("BG/SkySprite")
		if sky_sprite != null:
			sky_sprite.texture = sky_img
			sky_sprite.visible = true
			ASSET_UTILS.fit_sprite_visible_to_width(sky_sprite, VIEW_W)

	# Fit all visible layer sprites to viewport width
	for sp in [sea_far_sprite, buildings_sprite, boats_mid_sprite, foreground_sprite]:
		if sp != null and sp.visible and sp.texture != null:
			ASSET_UTILS.fit_sprite_visible_to_width(sp, VIEW_W)
			ASSET_UTILS.align_sprite_visible_left_bottom(sp, 0.0, CURB_TOP_Y + 10.0)

	# Ground
	if ground_sprite.texture != null:
		ASSET_UTILS.fit_sprite_visible_to_width(ground_sprite, VIEW_W)


func _try_load_sprite(sprite: Sprite2D, path: String) -> void:
	if sprite == null:
		return
	var tex := load(path) as Texture2D
	if tex != null:
		sprite.texture = tex
		sprite.visible = true


func _try_load_sprite_or_fallback(sprite: Sprite2D, path: String, fallback: String) -> void:
	if sprite == null:
		return
	var tex := load(path) as Texture2D
	if tex == null:
		tex = load(fallback) as Texture2D
	if tex != null:
		sprite.texture = tex
		sprite.visible = true

# ── UI pop animation (same pattern as Level 1) ────────────────────────────

func _pop_label(label: Label) -> void:
	label.pivot_offset = label.size / 2.0
	var t := create_tween()
	t.tween_property(label, "scale", Vector2(0.85, 0.85), 0.0)
	t.tween_property(label, "scale", Vector2.ONE, 0.18) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

# ── Helpers ───────────────────────────────────────────────────────────────

func _is_motion_active() -> bool:
	return started and not game_over and not checkpoint_encounter_active and not countdown_active


func _is_dialogue_advance(event: InputEvent) -> bool:
	return (
		event.is_action_pressed("ui_accept")
		or (event is InputEventMouseButton and event.pressed)
		or (event is InputEventScreenTouch and event.pressed)
	)


func _is_zainab_shield_active() -> bool:
	return false  # Level 2 placeholder — shield logic can be added later
