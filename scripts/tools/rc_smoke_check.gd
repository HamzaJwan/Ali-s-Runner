## RC Smoke / Regression Check — خطوات الخير
##
## Run headless with:
##   Godot_v4.7-stable_win64_console.exe --headless --path . -s scripts/tools/rc_smoke_check.gd
##
## Checks (all non-destructive, no gameplay state persists):
##   - Public title and subtitle text
##   - HUD collectible label uses "الأثر" terminology
##   - Game Over panel terminology
##   - GameOverPanel and button NodePaths exist
##   - Menu Ali scale is not animated (stays at calibrated value)
##   - Menu Ali Y is restored when idle motion stops
##   - Immutable physics and spawn constants
##   - Checkpoint trigger scores (15 / 35 / 60 / 90)
##   - No Level 2 scene nodes present
##   - Play button pulse scale within acceptable range
##   - No NodePath resolution errors

extends SceneTree

func _init() -> void:
	var scene: Node = load("res://scenes/Main.tscn").instantiate()
	get_root().add_child(scene)
	await process_frame
	await process_frame

	var failures: Array[String] = []
	var warnings: Array[String] = []

	# ── Public identity ────────────────────────────────────────────────────
	var title: Label = scene.menu_title_label
	var subtitle: Label = scene.menu_subtitle_label
	if title.text != "خطوات الخير":
		failures.append("title: expected 'خطوات الخير', got '%s'" % title.text)
	if not subtitle.text.contains("زليتن"):
		failures.append("subtitle: expected to contain 'زليتن', got '%s'" % subtitle.text)
	if not subtitle.text.contains("حكايات"):
		failures.append("subtitle: expected to contain 'حكايات', got '%s'" % subtitle.text)

	# ── HUD / collectible terminology ──────────────────────────────────────
	scene._update_light_shard_label()
	var hud_text: String = scene.light_shard_label.text
	if not hud_text.contains("الأثر"):
		failures.append("HUD label must contain 'الأثر', got '%s'" % hud_text)
	if hud_text.contains("النور"):
		failures.append("HUD label must NOT contain old 'النور', got '%s'" % hud_text)

	# ── Game Over panel presence and terminology ───────────────────────────
	var panel: Control = scene.get_node_or_null("UI/GameOverPanel")
	if panel == null:
		failures.append("GameOverPanel not found at $UI/GameOverPanel")
	else:
		if panel.visible:
			failures.append("GameOverPanel must be hidden at boot")
		var card_label: Label = panel.get_node_or_null("GameOverCard/GameOverLightCount")
		if card_label == null:
			failures.append("GameOverLightCount label missing under GameOverCard")
		else:
			if not card_label.text.contains("الأثر"):
				failures.append("GameOverLightCount default must contain 'الأثر', got '%s'" % card_label.text)

	# ── Button NodePaths exist ─────────────────────────────────────────────
	var retry: Button = scene.get_node_or_null("UI/GameOverPanel/GameOverCard/RetryButton")
	var restart: Button = scene.get_node_or_null("UI/GameOverPanel/GameOverCard/RestartButton")
	if retry == null:
		failures.append("RetryButton NodePath missing")
	if restart == null:
		failures.append("RestartButton NodePath missing")

	# ── Menu Ali grounding: scale stays at calibrated value after idle ─────
	var ali: Sprite2D = scene.player_story_sprite
	var scale_before: Vector2 = ali.scale
	await create_timer(scene.MENU_IDLE_BOB_TIME * 2.0 + 0.1).timeout
	var scale_after: Vector2 = ali.scale
	if absf(scale_after.x - scale_before.x) > 0.005:
		failures.append(
			"Ali sprite scale drifted during menu idle (%.4f → %.4f) — scale must not animate" \
			% [scale_before.x, scale_after.x]
		)

	# ── Menu Ali Y restored on idle stop ──────────────────────────────────
	var base_y: float = scene._menu_ali_base_y
	scene._stop_menu_idle_motion()
	await process_frame
	if base_y != 0.0 and absf(ali.position.y - base_y) > 0.5:
		failures.append(
			"Ali Y not restored after _stop_menu_idle_motion: %.2f vs base %.2f" \
			% [ali.position.y, base_y]
		)

	# ── Play button pulse scale ────────────────────────────────────────────
	if scene.PLAY_BUTTON_PULSE_SCALE > 1.025:
		failures.append("PLAY_BUTTON_PULSE_SCALE too large: %.4f (must be <= 1.025)" \
			% scene.PLAY_BUTTON_PULSE_SCALE)
	if scene.PLAY_BUTTON_PULSE_SCALE < 1.005:
		warnings.append("PLAY_BUTTON_PULSE_SCALE unusually small: %.4f" \
			% scene.PLAY_BUTTON_PULSE_SCALE)

	# ── Physics immutable constants ────────────────────────────────────────
	var player: Node = scene.player
	if player.GRAVITY != 1050.0:
		failures.append("GRAVITY changed: %s" % player.GRAVITY)
	if player.JUMP_VELOCITY != -440.0:
		failures.append("JUMP_VELOCITY changed: %s" % player.JUMP_VELOCITY)
	if player.MAX_FALL_SPEED != 700.0:
		failures.append("MAX_FALL_SPEED changed: %s" % player.MAX_FALL_SPEED)
	if player.JUMP_BUFFER_TIME != 0.12:
		failures.append("JUMP_BUFFER_TIME changed: %s" % player.JUMP_BUFFER_TIME)
	if scene.ROAD_SURFACE_Y != 510.0:
		failures.append("ROAD_SURFACE_Y changed: %s" % scene.ROAD_SURFACE_Y)
	var obs: Node = scene.obstacle_spawner
	if obs.SPAWN_INTERVAL != 2.25:
		failures.append("SPAWN_INTERVAL changed: %s" % obs.SPAWN_INTERVAL)
	if obs.SPAWN_X != 1292.0:
		failures.append("SPAWN_X changed: %s" % obs.SPAWN_X)

	# ── Checkpoint scores ──────────────────────────────────────────────────
	var enc := preload("res://scripts/story/encounter_data.gd")
	var expected: Dictionary = {enc.FATIMA: 15, enc.ZAINAB: 35, enc.JOMANA: 60, enc.FATHER: 90}
	for char_id: int in expected:
		var actual: int = enc.ENCOUNTERS[char_id]["trigger_score"]
		if actual != expected[char_id]:
			failures.append(
				"Checkpoint score changed for character %d: %d (expected %d)" \
				% [char_id, actual, expected[char_id]]
			)

	# ── No Level 2 nodes present ───────────────────────────────────────────
	var level2_paths := [
		"JomanaLevel2", "Level2Scene", "BeachLevel", "MarsaLevel",
		"JomanaRunner", "Level2Node"
	]
	for path: String in level2_paths:
		if scene.get_node_or_null(path) != null:
			failures.append("Level 2 node found in scene: %s — Level 2 not yet implemented" % path)

	# ── Summary ───────────────────────────────────────────────────────────
	var any_failure := not failures.is_empty()
	print("")
	if not warnings.is_empty():
		print("RC_SMOKE_WARNINGS:")
		for w in warnings:
			print("  [WARN] ", w)
	if any_failure:
		print("RC_SMOKE=FAIL")
		for f in failures:
			print("  [FAIL] ", f)
	else:
		print("RC_SMOKE=PASS  (%d checks, %d warnings)" % [
			14 + level2_paths.size(),
			warnings.size()
		])
	print("")
	quit(0 if not any_failure else 1)
