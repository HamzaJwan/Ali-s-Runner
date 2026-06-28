extends Node2D

enum StoryCheckpoint {
	NONE,
	FATIMA,
	ZAINAB,
	JOMANA,
}

enum EncounterCharacter {
	NONE,
	FATIMA,
	ZAINAB,
	JOMANA,
	FATHER,
}

enum DialogueRole {
	HELPER,
	ALI,
	REWARD,
}

const ASSET_UTILS := preload("res://scripts/asset_utils.gd")
const ENCOUNTER_DATA := preload("res://scripts/story/encounter_data.gd")
const ENCOUNTER_CONTROLLER := preload("res://scripts/story/encounter_controller.gd")
const DIFFICULTY_MANAGER := preload("res://scripts/gameplay/difficulty_manager.gd")
const OBSTACLE_SPAWNER := preload("res://scripts/gameplay/obstacle_spawner.gd")
const DIALOGUE_BUBBLE_HELPER := preload("res://scripts/ui/dialogue_bubble_helper.gd")
const VIEW_W := 1152.0
const VIEW_H := 648.0
const CURB_TOP_Y := 470.0
const ROAD_SURFACE_Y := 510.0
const GROUND_VISUAL_HEIGHT := 80.0
const GROUND_COLLISION_HEIGHT := 70.0
const PLAYER_START_X := 140.0
const PLAYER_COLLISION_HALF_HEIGHT := 24.0
const ALI_TEXTURE_PATH := "res://assets/characters/ali/ali_idle.png"
const CHECKPOINT_ARRIVAL_SPEED := 360.0
const ALI_STORY_X := 300.0
const ALI_STORY_VISUAL_HEIGHT := 160.0
const ENCOUNTER_TARGET_X := 610.0
const CURB_STORY_Y := CURB_TOP_Y
const COUNTDOWN_DURATION := 3.0
const GAME_OVER_IMPACT_DELAY := 0.45
const IMPACT_BOUNCE_DISTANCE := 10.0
const IMPACT_BOUNCE_OUT_TIME := 0.08
const IMPACT_BOUNCE_BACK_TIME := 0.18
const JOMANA_SAFETY_WINDOW_SPAWNS := 4
const GROUND_CENTER_Y := ROAD_SURFACE_Y + GROUND_COLLISION_HEIGHT / 2.0
const START_PLAYER_POSITION := Vector2(
	PLAYER_START_X, ROAD_SURFACE_Y - PLAYER_COLLISION_HALF_HEIGHT
)
const SKY_TEXTURE_PATH := "res://assets/backgrounds/mantarha/bg_sky.png"
const BUILDINGS_TEXTURE_PATH := "res://assets/backgrounds/mantarha/bg_buildings.png"
const FOREGROUND_TEXTURE_PATH := "res://assets/backgrounds/mantarha/bg_foreground.png"
const GROUND_TEXTURE_PATH := "res://assets/backgrounds/mantarha/ground_mantarha.png"

@onready var player: Player = $Player
@onready var player_story_sprite: Sprite2D = $Player/AliSprite
@onready var obstacle_spawner: Node2D = $Obstacles
@onready var spawn_timer: Timer = $SpawnTimer
@onready var fatima_npc: Node2D = $FatimaEncounter
@onready var fatima_npc_sprite: Sprite2D = $FatimaEncounter/FatimaSprite
@onready var fatima_npc_placeholder: CanvasItem = $FatimaEncounter/FatimaPlaceholder
@onready var zainab_npc: Node2D = $ZainabEncounter
@onready var zainab_npc_sprite: Sprite2D = $ZainabEncounter/ZainabSprite
@onready var zainab_npc_placeholder: CanvasItem = $ZainabEncounter/ZainabPlaceholder
@onready var jomana_npc: Node2D = $JomanaEncounter
@onready var jomana_npc_sprite: Sprite2D = $JomanaEncounter/JomanaSprite
@onready var jomana_npc_placeholder: CanvasItem = $JomanaEncounter/JomanaPlaceholder
@onready var father_npc: Node2D = $FatherEncounter
@onready var father_npc_sprite: Sprite2D = $FatherEncounter/FatherSprite
@onready var father_npc_placeholder: CanvasItem = $FatherEncounter/FatherPlaceholder
@onready var ground: StaticBody2D = $Ground
@onready var sky_sprite: Sprite2D = $BG/SkySprite
@onready var buildings_sprite: Sprite2D = $BG/BuildingsSprite
@onready var foreground_sprite: Sprite2D = $BG/ForegroundSprite
@onready var ground_sprite: Sprite2D = $Ground/GroundSprite
@onready var ground_base: Polygon2D = $Ground/GroundBase
@onready var ground_placeholder: Polygon2D = $Ground/Polygon2D
@onready var score_label: Label = $UI/ScoreLabel
@onready var game_over_label: Label = $UI/GameOverLabel
@onready var game_over_message: Label = $UI/GameOverMessage
@onready var retry_button: Button = $UI/RetryButton
@onready var restart_button: Button = $UI/RestartButton
@onready var start_screen: Control = $UI/StartScreen
@onready var play_button: Button = $UI/StartScreen/PlayButton
@onready var checkpoint_panel: Control = $UI/CheckpointPanel
@onready var checkpoint_card: Control = $UI/CheckpointPanel/Card
@onready var fatima_texture: TextureRect = $UI/CheckpointPanel/Card/FatimaTexture
@onready var fatima_panel_placeholder: Control = $UI/CheckpointPanel/Card/FatimaPlaceholder
@onready var zainab_texture: TextureRect = $UI/CheckpointPanel/Card/ZainabTexture
@onready var zainab_panel_placeholder: Control = $UI/CheckpointPanel/Card/ZainabPlaceholder
@onready var jomana_texture: TextureRect = $UI/CheckpointPanel/Card/JomanaTexture
@onready var jomana_panel_placeholder: Control = $UI/CheckpointPanel/Card/JomanaPlaceholder
@onready var father_texture: TextureRect = $UI/CheckpointPanel/Card/FatherTexture
@onready var father_panel_placeholder: Control = $UI/CheckpointPanel/Card/FatherPlaceholder
@onready var ali_focus_texture: TextureRect = $UI/CheckpointPanel/Card/AliFocusTexture
@onready var ali_focus_placeholder: Control = $UI/CheckpointPanel/Card/AliFocusPlaceholder
@onready var checkpoint_title: Label = $UI/CheckpointPanel/Card/CheckpointTitle
@onready var checkpoint_speaker_name: Label = $UI/CheckpointPanel/Card/SpeakerName
@onready var checkpoint_character_line: Label = $UI/CheckpointPanel/Card/CharacterLine
@onready var checkpoint_ali_line: Label = $UI/CheckpointPanel/Card/AliLine
@onready var checkpoint_reward_label: Label = $UI/CheckpointPanel/Card/RewardLabel
@onready var checkpoint_next_hint: Label = $UI/CheckpointPanel/Card/NextHint
@onready var continue_button: Button = $UI/CheckpointPanel/Card/ContinueButton
@onready var countdown_overlay: Control = $UI/CountdownOverlay
@onready var countdown_label: Label = $UI/CountdownOverlay/CountdownLabel

var score := 0
var started := false
var game_over := false
var checkpoint_active := false
var current_obstacle_speed := DIFFICULTY_MANAGER.BASE_SPEED
var last_reached_checkpoint := StoryCheckpoint.NONE
var checkpoint_encounter_started := false
var checkpoint_arriving := false
var checkpoint_cinematic_active := false
var active_encounter_node: Node2D
var encounter_controller := ENCOUNTER_CONTROLLER.new()
var countdown_active := false
var countdown_remaining := 0.0
var countdown_number := 0
var player_runner_position := START_PLAYER_POSITION
var fatima_reward_applied := false
var zainab_shield_active := false
var jomana_safety_window_pending := false


func _ready() -> void:
	randomize()
	if not play_button.pressed.is_connected(_on_play_pressed):
		play_button.pressed.connect(_on_play_pressed)
	if not restart_button.pressed.is_connected(_on_restart_pressed):
		restart_button.pressed.connect(_on_restart_pressed)
	if not retry_button.pressed.is_connected(_on_retry_pressed):
		retry_button.pressed.connect(_on_retry_pressed)
	if not continue_button.pressed.is_connected(_on_checkpoint_continue_pressed):
		continue_button.pressed.connect(_on_checkpoint_continue_pressed)
	start_screen.mouse_filter = Control.MOUSE_FILTER_STOP
	play_button.mouse_filter = Control.MOUSE_FILTER_STOP
	checkpoint_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	obstacle_spawner.setup(spawn_timer)
	obstacle_spawner.obstacle_passed.connect(_on_obstacle_passed)
	obstacle_spawner.obstacle_hit.connect(_on_obstacle_hit)
	_apply_fixed_visual_layout()
	_apply_optional_backgrounds()
	_apply_optional_story_textures()
	_apply_optional_ali_focus_texture()
	_show_start_screen()


func _process(delta: float) -> void:
	if checkpoint_arriving and active_encounter_node != null:
		active_encounter_node.position.x = move_toward(
			active_encounter_node.position.x, ENCOUNTER_TARGET_X,
			CHECKPOINT_ARRIVAL_SPEED * delta
		)
		if is_equal_approx(
			active_encounter_node.position.x, ENCOUNTER_TARGET_X
		):
			_open_checkpoint_cinematic()

	if countdown_active:
		_update_countdown(delta)


func _input(event: InputEvent) -> void:
	if not checkpoint_cinematic_active:
		return
	if encounter_controller.is_final_step():
		return
	if _is_dialogue_advance_event(event):
		_advance_encounter_dialogue()
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if not started or game_over or checkpoint_encounter_started or countdown_active:
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
	checkpoint_active = false
	current_obstacle_speed = DIFFICULTY_MANAGER.BASE_SPEED
	last_reached_checkpoint = StoryCheckpoint.NONE
	encounter_controller.reset_for_run(StoryCheckpoint.NONE)
	_reset_checkpoint_encounter_state()
	start_screen.visible = true
	score_label.visible = false
	game_over_label.visible = false
	game_over_message.visible = false
	retry_button.visible = false
	restart_button.visible = false
	obstacle_spawner.stop_spawning()
	obstacle_spawner.clear_obstacles()
	player.reset_player(START_PLAYER_POSITION)


func _on_play_pressed() -> void:
	if started:
		return
	print("Play button pressed")
	_start_run()


func _start_run() -> void:
	_begin_run(0, StoryCheckpoint.NONE, DIFFICULTY_MANAGER.BASE_SPEED)


func _begin_run(initial_score: int, checkpoint: int, obstacle_speed: float) -> void:
	get_tree().paused = false
	started = true
	score = initial_score
	game_over = false
	last_reached_checkpoint = checkpoint
	encounter_controller.reset_for_run(checkpoint)
	checkpoint_active = false
	fatima_reward_applied = checkpoint >= StoryCheckpoint.FATIMA
	zainab_shield_active = checkpoint >= StoryCheckpoint.ZAINAB
	jomana_safety_window_pending = false
	current_obstacle_speed = obstacle_speed
	_reset_checkpoint_encounter_state()
	print("Game started: score=", score, " obstacle_speed=",
		current_obstacle_speed)
	start_screen.visible = false
	score_label.visible = true
	score_label.text = "Score: %d" % score
	game_over_label.visible = false
	game_over_message.visible = false
	retry_button.visible = false
	restart_button.visible = false
	player.reset_player(START_PLAYER_POSITION)
	player.set_gameplay_active(true)
	obstacle_spawner.clear_obstacles()
	obstacle_spawner.start_spawning(current_obstacle_speed)
	obstacle_spawner.clear_safety_window()
	if checkpoint >= StoryCheckpoint.JOMANA:
		obstacle_spawner.grant_safety_window(JOMANA_SAFETY_WINDOW_SPAWNS)


func _on_obstacle_passed() -> void:
	score += 1
	score_label.text = "Score: %d" % score
	var encounter_id := encounter_controller.get_pending_for_score(score)
	if encounter_id != EncounterCharacter.NONE:
		_start_checkpoint_encounter(encounter_id)


func _on_obstacle_hit() -> void:
	if (
		zainab_shield_active and not game_over
		and not checkpoint_encounter_started and not countdown_active
	):
		_consume_zainab_shield()
		return
	_end_run()


func _consume_zainab_shield() -> void:
	zainab_shield_active = false
	obstacle_spawner.stop_spawning()
	obstacle_spawner.clear_obstacles()
	player.set_gameplay_active(false)
	_play_shield_flash()
	_start_countdown()
	print("[reward] Zainab shield consumed; gameplay resumes after countdown")


func _play_shield_flash() -> void:
	var flash_tween := create_tween()
	flash_tween.tween_property(
		player, "modulate", Color(0.55, 0.85, 1.0, 1.0), 0.08
	)
	flash_tween.tween_property(player, "modulate", Color.WHITE, 0.25)


func _end_run() -> void:
	if game_over or checkpoint_encounter_started or countdown_active:
		return

	game_over = true
	obstacle_spawner.stop_spawning()
	obstacle_spawner.clear_obstacles()
	player.kill()
	_play_impact_bounce()
	await get_tree().create_timer(GAME_OVER_IMPACT_DELAY).timeout
	_show_game_over_options()


func _play_impact_bounce() -> void:
	var start_x := player.global_position.x
	var bounce_tween := create_tween()
	bounce_tween.tween_property(
		player, "global_position:x", start_x - IMPACT_BOUNCE_DISTANCE,
		IMPACT_BOUNCE_OUT_TIME
	)
	bounce_tween.tween_property(
		player, "global_position:x", start_x, IMPACT_BOUNCE_BACK_TIME
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _show_game_over_options() -> void:
	game_over_label.visible = true
	game_over_message.visible = true
	restart_button.visible = true

	var checkpoint_config := ENCOUNTER_DATA.get_checkpoint(last_reached_checkpoint)
	if checkpoint_config.is_empty():
		game_over_message.text = ENCOUNTER_DATA.GAME_OVER_BEFORE_CHECKPOINT
		retry_button.visible = false
		restart_button.grab_focus()
	else:
		game_over_message.text = checkpoint_config["game_over_line"]
		retry_button.visible = true
		retry_button.grab_focus()


func _on_restart_pressed() -> void:
	_start_run()


func _on_retry_pressed() -> void:
	var retry_config := _get_retry_state_config(last_reached_checkpoint)
	_begin_run(
		retry_config["score"],
		retry_config["checkpoint"],
		retry_config["speed"]
	)


func _get_retry_state_config(checkpoint: int) -> Dictionary:
	var checkpoint_config := ENCOUNTER_DATA.get_checkpoint(checkpoint)
	if not checkpoint_config.is_empty():
		return {
			"score": checkpoint_config["retry_score"],
			"checkpoint": checkpoint_config["checkpoint_id"],
			"speed": DIFFICULTY_MANAGER.get_speed_for_checkpoint(checkpoint),
		}
	return {
		"score": 0,
		"checkpoint": StoryCheckpoint.NONE,
		"speed": DIFFICULTY_MANAGER.BASE_SPEED,
	}


func _start_checkpoint_encounter(character: int) -> void:
	if game_over or checkpoint_encounter_started:
		return

	if not _configure_active_encounter(character):
		return

	checkpoint_encounter_started = true
	obstacle_spawner.stop_spawning()
	obstacle_spawner.clear_obstacles()
	player_runner_position = Vector2(
		player.global_position.x, START_PLAYER_POSITION.y
	)
	_prepare_player_for_encounter()

	if encounter_controller.config["arrival_mode"] == ENCOUNTER_DATA.ARRIVAL_REVEAL:
		checkpoint_arriving = false
		active_encounter_node.position = Vector2(
			ENCOUNTER_TARGET_X,
			_get_encounter_world_y(encounter_controller.character_id)
		)
		active_encounter_node.modulate.a = 0.0
		active_encounter_node.visible = true
		var reveal_tween := create_tween()
		reveal_tween.tween_property(
			active_encounter_node, "modulate:a", 1.0, 0.45
		)
		reveal_tween.tween_callback(_open_checkpoint_cinematic)
		print("[encounter] character=", encounter_controller.character_id,
			" revealed in place at x=", ENCOUNTER_TARGET_X)
	else:
		checkpoint_arriving = true
		active_encounter_node.position = Vector2(
			OBSTACLE_SPAWNER.SPAWN_X,
			_get_encounter_world_y(encounter_controller.character_id)
		)
		active_encounter_node.modulate.a = 1.0
		active_encounter_node.visible = true
		print("[encounter] character=", encounter_controller.character_id,
			" entering_from_x=", active_encounter_node.position.x)


func _configure_active_encounter(character: int) -> bool:
	if not encounter_controller.begin(character):
		return false

	match encounter_controller.character_id:
		EncounterCharacter.FATIMA:
			active_encounter_node = fatima_npc
		EncounterCharacter.ZAINAB:
			active_encounter_node = zainab_npc
		EncounterCharacter.JOMANA:
			active_encounter_node = jomana_npc
		EncounterCharacter.FATHER:
			active_encounter_node = father_npc
		_:
			return false
	return true


func _get_encounter_world_y(character: int) -> float:
	var config := ENCOUNTER_DATA.get_encounter(character)
	return (
		CURB_STORY_Y
		if config.get("story_position_role", ENCOUNTER_DATA.POSITION_ROAD)
			== ENCOUNTER_DATA.POSITION_CURB
		else ROAD_SURFACE_Y
	)


func _prepare_player_for_encounter() -> void:
	player.reset_player(Vector2(ALI_STORY_X, START_PLAYER_POSITION.y))
	if player_story_sprite.texture != null:
		ASSET_UTILS.fit_sprite_visible_to_height(
			player_story_sprite, ALI_STORY_VISUAL_HEIGHT
		)
		ASSET_UTILS.align_sprite_visible_bottom(
			player_story_sprite, PLAYER_COLLISION_HALF_HEIGHT
		)


func _open_checkpoint_cinematic() -> void:
	if not checkpoint_encounter_started:
		return

	checkpoint_arriving = false
	checkpoint_active = true
	checkpoint_cinematic_active = true
	_configure_checkpoint_panel()
	_show_encounter_dialogue_step()
	checkpoint_panel.visible = true
	_play_checkpoint_panel_intro()
	print("[encounter] character=", encounter_controller.character_id,
		" reached_story_x=", ENCOUNTER_TARGET_X)
	get_tree().paused = true


func _configure_checkpoint_panel() -> void:
	checkpoint_title.visible = false
	fatima_texture.visible = false
	fatima_panel_placeholder.visible = false
	zainab_texture.visible = false
	zainab_panel_placeholder.visible = false
	jomana_texture.visible = false
	jomana_panel_placeholder.visible = false
	father_texture.visible = false
	father_panel_placeholder.visible = false
	ali_focus_texture.visible = false
	ali_focus_placeholder.visible = false


func _show_encounter_dialogue_step() -> void:
	checkpoint_character_line.visible = false
	checkpoint_ali_line.visible = false
	checkpoint_reward_label.visible = false
	continue_button.visible = false
	checkpoint_next_hint.visible = true

	var step := encounter_controller.current_step()
	if step.is_empty():
		return
	var role: int = step["role"]
	var text: String = step["text"]
	_position_dialogue_bubble_for_speaker(role)
	checkpoint_speaker_name.text = _get_speaker_name(role)
	match role:
		DialogueRole.HELPER:
			checkpoint_character_line.text = text
			checkpoint_character_line.visible = true
		DialogueRole.ALI:
			checkpoint_ali_line.text = text
			checkpoint_ali_line.visible = true
		DialogueRole.REWARD:
			checkpoint_reward_label.text = text
			checkpoint_reward_label.visible = true
			_pop_reward_text()
			if encounter_controller.character_id == EncounterCharacter.FATIMA:
				_apply_fatima_reward_bonus()
			elif encounter_controller.character_id == EncounterCharacter.ZAINAB:
				_apply_zainab_shield_grant()

	if encounter_controller.is_final_step():
		checkpoint_next_hint.visible = false
		continue_button.visible = true
		continue_button.text = (
			"العب من جديد / Play Again"
			if encounter_controller.character_id == EncounterCharacter.FATHER
			else "متابعة / Continue"
		)
		continue_button.grab_focus()


func _position_dialogue_bubble_for_speaker(role: int) -> void:
	var ali_visual_top := Vector2(
		player.global_position.x,
		ROAD_SURFACE_Y - ALI_STORY_VISUAL_HEIGHT
	)
	var helper_visual_top := Vector2(ENCOUNTER_TARGET_X, ROAD_SURFACE_Y)
	if active_encounter_node != null:
		helper_visual_top = Vector2(
			active_encounter_node.global_position.x,
			_get_encounter_world_y(encounter_controller.character_id)
				- float(encounter_controller.config.get("visual_height", 100.0))
		)
	checkpoint_card.size = DIALOGUE_BUBBLE_HELPER.BUBBLE_SIZE
	checkpoint_card.position = DIALOGUE_BUBBLE_HELPER.get_position(
		role, ali_visual_top, helper_visual_top
	)


func _get_speaker_name(role: int) -> String:
	return encounter_controller.speaker_name(role)


func _play_checkpoint_panel_intro() -> void:
	checkpoint_panel.modulate.a = 0.0
	checkpoint_card.pivot_offset = checkpoint_card.size / 2.0
	checkpoint_card.scale = Vector2(0.96, 0.96)
	var panel_tween := create_tween().set_parallel()
	panel_tween.tween_property(checkpoint_panel, "modulate:a", 1.0, 0.25)
	panel_tween.tween_property(checkpoint_card, "scale", Vector2.ONE, 0.28)


func _pop_reward_text() -> void:
	checkpoint_reward_label.pivot_offset = checkpoint_reward_label.size / 2.0
	checkpoint_reward_label.scale = Vector2(0.9, 0.9)
	var reward_tween := create_tween()
	reward_tween.tween_property(
		checkpoint_reward_label, "scale", Vector2.ONE, 0.22
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _apply_fatima_reward_bonus() -> void:
	if fatima_reward_applied:
		return
	fatima_reward_applied = true
	score += ENCOUNTER_DATA.FATIMA_REWARD_BONUS
	score_label.text = "Score: %d" % score
	print("[reward] Fatima joy bonus applied: +",
		ENCOUNTER_DATA.FATIMA_REWARD_BONUS, " score=", score)


func _apply_zainab_shield_grant() -> void:
	zainab_shield_active = true
	print("[reward] Zainab courage shield granted")


func _advance_encounter_dialogue() -> void:
	if not encounter_controller.advance_dialogue():
		return
	_show_encounter_dialogue_step()
	print("[encounter] dialogue_step=",
		encounter_controller.dialogue_step_index)


func _is_dialogue_advance_event(event: InputEvent) -> bool:
	if event.is_action_pressed("ui_accept"):
		return true
	if event is InputEventMouseButton:
		return event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if event is InputEventScreenTouch:
		return event.pressed
	return false


func _on_checkpoint_continue_pressed() -> void:
	if not checkpoint_active:
		return
	if not encounter_controller.is_final_step():
		return

	if encounter_controller.character_id == EncounterCharacter.FATHER:
		print("[encounter] Father ending complete; restarting from beginning")
		_start_run()
		return

	if not _apply_checkpoint_state(encounter_controller.character_id):
		return
	_finish_encounter_and_countdown()
	print("[checkpoint] character=", encounter_controller.character_id,
		" continued; obstacle_speed=", current_obstacle_speed)


func _apply_checkpoint_state(character: int) -> bool:
	var config := ENCOUNTER_DATA.get_encounter(character)
	if config.is_empty() or config["checkpoint_id"] == StoryCheckpoint.NONE:
		return false
	last_reached_checkpoint = config["checkpoint_id"]
	current_obstacle_speed = DIFFICULTY_MANAGER.get_speed_for_checkpoint(
		last_reached_checkpoint
	)
	if character == EncounterCharacter.JOMANA:
		jomana_safety_window_pending = true
	return true


func _finish_encounter_and_countdown() -> void:
	checkpoint_active = false
	checkpoint_cinematic_active = false
	checkpoint_panel.visible = false
	if active_encounter_node != null:
		active_encounter_node.visible = false
	player.reset_player(player_runner_position)
	_start_countdown()


func _start_countdown() -> void:
	countdown_active = true
	countdown_remaining = COUNTDOWN_DURATION
	countdown_number = 3
	countdown_label.text = "3"
	countdown_overlay.visible = true
	_pop_countdown_number()


func _update_countdown(delta: float) -> void:
	countdown_remaining -= delta
	if countdown_remaining <= 0.0:
		_finish_countdown()
		return

	var next_number := maxi(ceili(countdown_remaining), 1)
	if next_number != countdown_number:
		countdown_number = next_number
		countdown_label.text = str(countdown_number)
		_pop_countdown_number()


func _pop_countdown_number() -> void:
	countdown_label.pivot_offset = countdown_label.size / 2.0
	countdown_label.scale = Vector2(0.72, 0.72)
	var countdown_tween := create_tween()
	countdown_tween.tween_property(
		countdown_label, "scale", Vector2.ONE, 0.2
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _finish_countdown() -> void:
	countdown_active = false
	countdown_overlay.visible = false
	checkpoint_encounter_started = false
	active_encounter_node = null
	encounter_controller.clear_active()
	get_tree().paused = false
	player.set_gameplay_active(true)
	obstacle_spawner.start_spawning(current_obstacle_speed)
	if jomana_safety_window_pending:
		jomana_safety_window_pending = false
		obstacle_spawner.grant_safety_window(JOMANA_SAFETY_WINDOW_SPAWNS)
		print("[reward] Jomana safer-spacing window granted: ",
			JOMANA_SAFETY_WINDOW_SPAWNS, " spawns")
	print("[encounter] countdown complete; gameplay resumed")


func _reset_checkpoint_encounter_state() -> void:
	checkpoint_encounter_started = false
	checkpoint_arriving = false
	checkpoint_cinematic_active = false
	checkpoint_active = false
	active_encounter_node = null
	encounter_controller.clear_active()
	countdown_active = false
	countdown_remaining = 0.0
	countdown_number = 0
	fatima_npc.visible = false
	zainab_npc.visible = false
	jomana_npc.visible = false
	father_npc.visible = false
	fatima_npc.modulate.a = 1.0
	zainab_npc.modulate.a = 1.0
	jomana_npc.modulate.a = 1.0
	father_npc.modulate.a = 1.0
	checkpoint_panel.visible = false
	checkpoint_panel.modulate.a = 1.0
	checkpoint_card.scale = Vector2.ONE
	countdown_overlay.visible = false


func _apply_optional_story_textures() -> void:
	encounter_controller.apply_optional_character_texture(
		EncounterCharacter.FATIMA, fatima_texture, fatima_panel_placeholder,
		fatima_npc_sprite, fatima_npc_placeholder
	)
	encounter_controller.apply_optional_character_texture(
		EncounterCharacter.ZAINAB, zainab_texture, zainab_panel_placeholder,
		zainab_npc_sprite, zainab_npc_placeholder
	)
	encounter_controller.apply_optional_character_texture(
		EncounterCharacter.JOMANA, jomana_texture, jomana_panel_placeholder,
		jomana_npc_sprite, jomana_npc_placeholder
	)
	encounter_controller.apply_optional_character_texture(
		EncounterCharacter.FATHER, father_texture, father_panel_placeholder,
		father_npc_sprite, father_npc_placeholder
	)


func _apply_optional_ali_focus_texture() -> void:
	var texture := ASSET_UTILS.load_texture_with_fallback(ALI_TEXTURE_PATH)
	if texture != null:
		ali_focus_texture.texture = texture
		ali_focus_texture.visible = true
		ali_focus_placeholder.visible = false
	else:
		ali_focus_texture.texture = null
		ali_focus_texture.visible = false
		ali_focus_placeholder.visible = true


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
