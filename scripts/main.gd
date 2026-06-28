extends Node2D

const ASSET_UTILS := preload("res://scripts/asset_utils.gd")
const VIEW_W := 1152.0
const VIEW_H := 648.0
const CURB_TOP_Y := 470.0
const ROAD_SURFACE_Y := 510.0
const GROUND_VISUAL_HEIGHT := 80.0
const GROUND_COLLISION_HEIGHT := 70.0
const PLAYER_START_X := 140.0
const PLAYER_COLLISION_HALF_HEIGHT := 24.0
const OBSTACLE_COLLISION_HALF_HEIGHT := 25.0
const OBSTACLE_SPAWN_INTERVAL := 2.25
const OBSTACLE_SPAWN_MARGIN := 140.0
const OBSTACLE_SPAWN_X := VIEW_W + OBSTACLE_SPAWN_MARGIN
const BASE_OBSTACLE_SPEED := 225.0
const POST_FATIMA_OBSTACLE_SPEED := 240.0
const FATIMA_CHECKPOINT_SCORE := 15
const FATIMA_TEXTURE_PATH := "res://assets/characters/fatima/fatima_helper.png"
const FATIMA_LINE := "آآ… علي! ⭐"
const ALI_FATIMA_LINE := "فاطمة! لقيتك… نجمتك بتنور الطريق."
const FATIMA_REWARD_TEXT := "حصلت على نجمة الفرح."
const GROUND_CENTER_Y := ROAD_SURFACE_Y + GROUND_COLLISION_HEIGHT / 2.0
const START_PLAYER_POSITION := Vector2(
	PLAYER_START_X, ROAD_SURFACE_Y - PLAYER_COLLISION_HALF_HEIGHT
)
const SKY_TEXTURE_PATH := "res://assets/backgrounds/mantarha/bg_sky.png"
const BUILDINGS_TEXTURE_PATH := "res://assets/backgrounds/mantarha/bg_buildings.png"
const FOREGROUND_TEXTURE_PATH := "res://assets/backgrounds/mantarha/bg_foreground.png"
const GROUND_TEXTURE_PATH := "res://assets/backgrounds/mantarha/ground_mantarha.png"

@onready var player: Player = $Player
@onready var obstacles: Node2D = $Obstacles
@onready var spawn_timer: Timer = $SpawnTimer
@onready var ground: StaticBody2D = $Ground
@onready var sky_sprite: Sprite2D = $BG/SkySprite
@onready var buildings_sprite: Sprite2D = $BG/BuildingsSprite
@onready var foreground_sprite: Sprite2D = $BG/ForegroundSprite
@onready var ground_sprite: Sprite2D = $Ground/GroundSprite
@onready var ground_base: Polygon2D = $Ground/GroundBase
@onready var ground_placeholder: Polygon2D = $Ground/Polygon2D
@onready var score_label: Label = $UI/ScoreLabel
@onready var game_over_label: Label = $UI/GameOverLabel
@onready var restart_button: Button = $UI/RestartButton
@onready var start_screen: Control = $UI/StartScreen
@onready var play_button: Button = $UI/StartScreen/PlayButton
@onready var checkpoint_panel: Control = $UI/CheckpointPanel
@onready var fatima_texture: TextureRect = $UI/CheckpointPanel/Card/FatimaTexture
@onready var fatima_placeholder: Control = $UI/CheckpointPanel/Card/FatimaPlaceholder
@onready var checkpoint_character_line: Label = $UI/CheckpointPanel/Card/CharacterLine
@onready var checkpoint_ali_line: Label = $UI/CheckpointPanel/Card/AliLine
@onready var checkpoint_reward_label: Label = $UI/CheckpointPanel/Card/RewardLabel
@onready var continue_button: Button = $UI/CheckpointPanel/Card/ContinueButton

var score := 0
var started := false
var game_over := false
var fatima_checkpoint_triggered := false
var fatima_checkpoint_active := false
var current_obstacle_speed := BASE_OBSTACLE_SPEED


func _ready() -> void:
	randomize()
	if not play_button.pressed.is_connected(_on_play_pressed):
		play_button.pressed.connect(_on_play_pressed)
	if not restart_button.pressed.is_connected(_on_restart_pressed):
		restart_button.pressed.connect(_on_restart_pressed)
	if not continue_button.pressed.is_connected(_on_checkpoint_continue_pressed):
		continue_button.pressed.connect(_on_checkpoint_continue_pressed)
	start_screen.mouse_filter = Control.MOUSE_FILTER_STOP
	play_button.mouse_filter = Control.MOUSE_FILTER_STOP
	checkpoint_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	spawn_timer.wait_time = OBSTACLE_SPAWN_INTERVAL
	spawn_timer.timeout.connect(_spawn_obstacle)
	_apply_fixed_visual_layout()
	_apply_optional_backgrounds()
	_apply_optional_fatima_texture()
	_show_start_screen()


func _unhandled_input(event: InputEvent) -> void:
	if not started or game_over:
		return

	if event.is_action_pressed("ui_accept"):
		player.jump()
	elif event is InputEventMouseButton and event.pressed:
		player.jump()
	elif event is InputEventScreenTouch and event.pressed:
		player.jump()


func _show_start_screen() -> void:
	get_tree().paused = false
	started = false
	game_over = false
	fatima_checkpoint_triggered = false
	fatima_checkpoint_active = false
	current_obstacle_speed = BASE_OBSTACLE_SPEED
	start_screen.visible = true
	checkpoint_panel.visible = false
	score_label.visible = false
	game_over_label.visible = false
	restart_button.visible = false
	spawn_timer.stop()
	_clear_obstacles()
	player.reset_player(START_PLAYER_POSITION)


func _on_play_pressed() -> void:
	if started:
		return
	print("Play button pressed")
	_start_run()


func _start_run() -> void:
	get_tree().paused = false
	started = true
	score = 0
	game_over = false
	fatima_checkpoint_triggered = false
	fatima_checkpoint_active = false
	current_obstacle_speed = BASE_OBSTACLE_SPEED
	print("Game started")
	start_screen.visible = false
	checkpoint_panel.visible = false
	score_label.visible = true
	score_label.text = "Score: 0"
	game_over_label.visible = false
	restart_button.visible = false
	player.reset_player(START_PLAYER_POSITION)
	_clear_obstacles()
	spawn_timer.start()


func _spawn_obstacle() -> void:
	if game_over:
		return

	var obstacle_scene := preload("res://scenes/Obstacle.tscn")
	var obstacle := obstacle_scene.instantiate()
	obstacle.speed = current_obstacle_speed
	obstacle.position = Vector2(
		OBSTACLE_SPAWN_X,
		ROAD_SURFACE_Y - OBSTACLE_COLLISION_HALF_HEIGHT
	)
	obstacle.passed.connect(_on_obstacle_passed)
	obstacle.hit.connect(_on_obstacle_hit)
	obstacles.add_child(obstacle)
	print("[spawn] obstacle_x=", OBSTACLE_SPAWN_X,
		" margin=", OBSTACLE_SPAWN_MARGIN)


func _on_obstacle_passed() -> void:
	score += 1
	score_label.text = "Score: %d" % score
	if score == FATIMA_CHECKPOINT_SCORE and not fatima_checkpoint_triggered:
		_show_fatima_checkpoint()


func _on_obstacle_hit() -> void:
	_end_run()


func _end_run() -> void:
	if game_over or fatima_checkpoint_active:
		return

	game_over = true
	spawn_timer.stop()
	game_over_label.visible = true
	restart_button.visible = true
	player.kill()


func _on_restart_pressed() -> void:
	_start_run()


func _clear_obstacles() -> void:
	for child in obstacles.get_children():
		child.queue_free()


func _show_fatima_checkpoint() -> void:
	if game_over or fatima_checkpoint_triggered:
		return

	fatima_checkpoint_triggered = true
	fatima_checkpoint_active = true
	checkpoint_character_line.text = FATIMA_LINE
	checkpoint_ali_line.text = ALI_FATIMA_LINE
	checkpoint_reward_label.text = FATIMA_REWARD_TEXT
	checkpoint_panel.visible = true
	continue_button.grab_focus()
	print("[checkpoint] Fatima reached at score=", score)
	get_tree().paused = true


func _on_checkpoint_continue_pressed() -> void:
	if not fatima_checkpoint_active:
		return

	current_obstacle_speed = POST_FATIMA_OBSTACLE_SPEED
	for obstacle in obstacles.get_children():
		obstacle.set("speed", current_obstacle_speed)
	fatima_checkpoint_active = false
	checkpoint_panel.visible = false
	get_tree().paused = false
	print("[checkpoint] Fatima continued; obstacle_speed=",
		current_obstacle_speed)


func _apply_optional_fatima_texture() -> void:
	var texture := ASSET_UTILS.load_texture_with_fallback(FATIMA_TEXTURE_PATH)
	if texture != null:
		fatima_texture.texture = texture
		fatima_texture.visible = true
		fatima_placeholder.visible = false
		print("[checkpoint] Fatima helper texture loaded")
	else:
		fatima_texture.texture = null
		fatima_texture.visible = false
		fatima_placeholder.visible = true
		print("[checkpoint] Fatima helper missing; using placeholder")


func _apply_optional_backgrounds() -> void:
	_apply_sky_texture()
	_apply_scenery_layer(buildings_sprite, BUILDINGS_TEXTURE_PATH, 1.0)
	_apply_scenery_layer(foreground_sprite, FOREGROUND_TEXTURE_PATH, 0.82)
	_apply_ground_texture()


func _apply_fixed_visual_layout() -> void:
	ground.position = Vector2(VIEW_W / 2.0, GROUND_CENTER_Y)
	var local_left := -ground.position.x
	var local_right := VIEW_W - ground.position.x
	var local_top := CURB_TOP_Y - ground.position.y
	var local_bottom := VIEW_H - ground.position.y
	ground_base.polygon = PackedVector2Array([
		Vector2(local_left, local_top),
		Vector2(local_right, local_top),
		Vector2(local_right, local_bottom),
		Vector2(local_left, local_bottom),
	])
	ground_placeholder.polygon = PackedVector2Array([
		Vector2(local_left, local_top),
		Vector2(local_right, local_top),
		Vector2(local_right, local_top + GROUND_VISUAL_HEIGHT),
		Vector2(local_left, local_top + GROUND_VISUAL_HEIGHT),
	])
	print("[layout] curb_top_y=", CURB_TOP_Y,
		" road_surface_y=", ROAD_SURFACE_Y,
		" ground_visual_height=", GROUND_VISUAL_HEIGHT)


func _apply_sky_texture() -> void:
	if ASSET_UTILS.set_sprite_texture_if_exists(sky_sprite, SKY_TEXTURE_PATH):
		sky_sprite.centered = false
		sky_sprite.position = Vector2.ZERO
		ASSET_UTILS.fit_sprite_to_size(sky_sprite, VIEW_W, VIEW_H)


func _apply_scenery_layer(
		sprite: Sprite2D, texture_path: String, opacity: float
) -> void:
	if ASSET_UTILS.set_sprite_texture_if_exists(sprite, texture_path):
		sprite.centered = false
		ASSET_UTILS.fit_sprite_visible_to_width(sprite, VIEW_W)
		ASSET_UTILS.align_sprite_visible_left_bottom(
			sprite, 0.0, CURB_TOP_Y
		)
		sprite.modulate.a = opacity
		print("[layout] ", sprite.name, " visible_bottom=", CURB_TOP_Y,
			" opacity=", opacity)


func _apply_ground_texture() -> void:
	if ASSET_UTILS.set_sprite_texture_if_exists(ground_sprite, GROUND_TEXTURE_PATH):
		ground_sprite.centered = false
		ASSET_UTILS.fit_sprite_visible_to_size(
			ground_sprite, VIEW_W, GROUND_VISUAL_HEIGHT
		)
		ASSET_UTILS.align_sprite_visible_top_left(
			ground_sprite,
			Vector2(-ground.position.x, CURB_TOP_Y - ground.position.y)
		)
		ground_placeholder.visible = false
	else:
		ground_placeholder.visible = true
