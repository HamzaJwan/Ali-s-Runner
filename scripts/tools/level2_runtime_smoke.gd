extends SceneTree

const LEVEL2_SCENE := preload("res://scenes/level2/Level2_Marsa_Playable.tscn")
const L2_OBSTACLE_VISUALS := preload("res://scripts/level2/gameplay/level2_obstacle_visuals.gd")


func _initialize() -> void:
	call_deferred("_run_smoke")


func _run_smoke() -> void:
	var scene := LEVEL2_SCENE.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	var failures: Array[String] = []
	var visual_manager := L2_OBSTACLE_VISUALS.new()
	for obstacle_type: String in ["block", "barrier", "cone", "crate", "sign"]:
		var dummy_obstacle := Node2D.new()
		if not visual_manager.apply_skin(dummy_obstacle, obstacle_type, 30.0):
			failures.append("could not apply Level 2 skin for %s" % obstacle_type)
			dummy_obstacle.free()
			continue
		var dummy_skin := dummy_obstacle.get_node_or_null("L2Skin") as Sprite2D
		if dummy_skin == null or dummy_skin.texture == null:
			failures.append("missing generated skin for %s" % obstacle_type)
			dummy_obstacle.free()
			continue
		var rendered_width := float(dummy_skin.texture.get_width()) * dummy_skin.scale.x
		var max_width: float = L2_OBSTACLE_VISUALS.MAX_VISUAL_WIDTHS[obstacle_type]
		if rendered_width > max_width + 0.5:
			failures.append("%s skin exceeds max width" % obstacle_type)
		var rendered_height := float(dummy_skin.texture.get_height()) * dummy_skin.scale.y
		var collision_height: float = L2_OBSTACLE_VISUALS.COLLISION_HEIGHTS[obstacle_type]
		if rendered_height > collision_height + 20.5:
			failures.append("%s skin is too tall for its collision" % obstacle_type)
		var rendered_bottom := dummy_skin.position.y + rendered_height / 2.0
		var expected_bottom := collision_height / 2.0 + 30.0
		if absf(rendered_bottom - expected_bottom) > 0.1:
			failures.append("%s skin bottom alignment is incorrect" % obstacle_type)
		dummy_obstacle.free()
	var expected_step_counts := {
		Level2EncounterData.ALI: 3,
		Level2EncounterData.ZAINAB: 3,
		Level2EncounterData.FATIMA: 3,
		Level2EncounterData.FATHER: 4,
	}
	for encounter_id: int in expected_step_counts:
		var encounter := Level2EncounterData.get_encounter(encounter_id)
		var dialogue_steps: Array = encounter.get("dialogue_steps", [])
		if dialogue_steps.size() != expected_step_counts[encounter_id]:
			failures.append("unexpected dialogue step count for encounter %d" % encounter_id)
		for step: Dictionary in dialogue_steps:
			if String(step.get("speaker", "")).is_empty():
				failures.append("missing explicit speaker for encounter %d" % encounter_id)
			if String(step.get("text", "")).is_empty():
				failures.append("missing dialogue text for encounter %d" % encounter_id)
	if not scene.has_method("debug_start_gameplay_for_smoke"):
		failures.append("missing debug start helper")
	else:
		scene.debug_start_gameplay_for_smoke()
	var player := scene.get_node_or_null("Player")
	if player != null:
		var reveal_click := InputEventMouseButton.new()
		reveal_click.button_index = MOUSE_BUTTON_LEFT
		reveal_click.pressed = true
		scene._input(reveal_click)
		if player.velocity.y < 0.0:
			failures.append("play/reveal click caused an accidental jump")

	# Covers camera reveal and the first 2.25s obstacle interval.
	await create_timer(2.5).timeout
	if not bool(scene.get("started")):
		failures.append("started is false")
	if player == null or not bool(player.get("_gameplay_active")):
		failures.append("player gameplay is inactive")
	var score_label := scene.get_node_or_null("UI/ScoreLabel") as Label
	if score_label == null or not score_label.text.contains("✦ 0"):
		failures.append("collectible HUD is not visible from run start")

	if player != null:
		var grounded_position: Vector2 = player.global_position
		var mouse_event := InputEventMouseButton.new()
		mouse_event.button_index = MOUSE_BUTTON_LEFT
		mouse_event.pressed = true
		for click_index: int in 10:
			scene._input(mouse_event)
			if player.velocity.y >= 0.0:
				failures.append("mouse input did not trigger jump %d/10" % [click_index + 1])
			player.reset_player(grounded_position)
			player.set_gameplay_active(true)
			await physics_frame
		var jomana_visual := player.get_node_or_null("JomanaVisual")
		scene._on_player_landed()
		await process_frame
		if jomana_visual == null or int(jomana_visual.get_pose()) != 3:
			failures.append("landing pose did not start on contact")
		await create_timer(0.12).timeout
		if jomana_visual == null or int(jomana_visual.get_pose()) != 1:
			failures.append("landing pose did not return quickly to run")
		var touch_event := InputEventScreenTouch.new()
		touch_event.pressed = true
		scene._input(touch_event)
		if player.velocity.y >= 0.0:
			failures.append("touch input did not trigger jump")
		player.reset_player(grounded_position)
		player.set_gameplay_active(true)
		await physics_frame
		var space_event := InputEventAction.new()
		space_event.action = "ui_accept"
		space_event.pressed = true
		scene._unhandled_input(space_event)
		if player.velocity.y >= 0.0:
			failures.append("Space/ui_accept did not trigger jump")
		player.reset_player(grounded_position)
		player.set_gameplay_active(true)
		await physics_frame
	var obstacle_timer := scene.get_node_or_null("SpawnTimer") as Timer
	if obstacle_timer == null or obstacle_timer.is_stopped():
		failures.append("obstacle timer is stopped")
	var obstacles := scene.get_node_or_null("Obstacles")
	if obstacles == null or obstacles.get_child_count() == 0:
		failures.append("first obstacle did not spawn")
	else:
		var obstacle := obstacles.get_child(0)
		var skin := obstacle.get_node_or_null("L2Skin") as Sprite2D
		if skin == null:
			failures.append("Level 2 obstacle skin is missing")
		elif skin.texture == null or float(skin.texture.get_width()) * skin.scale.x > 76.5:
			failures.append("first obstacle visual exceeds fair block width")
		for legacy_name in ["ObstacleSprite", "Polygon2D"]:
			var legacy := obstacle.get_node_or_null(legacy_name) as CanvasItem
			if legacy != null and legacy.visible:
				failures.append("legacy obstacle visual is visible: %s" % legacy_name)
		# Isolate the collectible assertion from the intentional obstacle-clearance gate.
		obstacles.clear_obstacles()
		await process_frame
		await process_frame
	var collectible_spawner := scene.get_node_or_null("Collectibles")
	if (
		collectible_spawner == null
		or not collectible_spawner.has_method("is_spawning")
		or not collectible_spawner.is_spawning()
	):
		failures.append("collectible spawner is stopped")
	else:
		collectible_spawner.call("_on_timer_timeout")
		await process_frame
	if collectible_spawner != null and collectible_spawner.get_child_count() == 0:
		failures.append("first collectible pattern did not spawn")
	elif collectible_spawner != null:
		var collectible := collectible_spawner.get_child(0)
		var l2_shard := collectible.get_node_or_null("L2ShardSprite") as Sprite2D
		if l2_shard == null:
			failures.append("Level 2 collectible visual is missing")
		elif l2_shard.texture == null or absf(
			float(l2_shard.texture.get_height()) * l2_shard.scale.y - 48.0
		) > 0.5:
			failures.append("Level 2 collectible visual is not 48px high")
		for legacy_name in ["ShardSprite", "Polygon2D"]:
			var legacy := collectible.get_node_or_null(legacy_name) as CanvasItem
			if legacy != null and legacy.visible:
				failures.append("legacy collectible visual is visible: %s" % legacy_name)
	scene._on_collected()
	if score_label == null or not score_label.text.contains("✦ 1"):
		failures.append("collectible HUD did not update after pickup")
	scene._on_obstacle_passed()
	if score_label == null or not score_label.text.contains("✦ 1"):
		failures.append("score update erased collectible HUD count")
	var camera := scene.get_node_or_null("GameCamera") as Camera2D
	var target_position: Vector2 = scene.get("_gameplay_cam_pos")
	if camera == null or camera.position.distance_to(target_position) > 1.0:
		failures.append("camera reveal did not complete")

	# Checkpoint lifecycle: enter Ali encounter, complete reward, then resume.
	if not scene.has_method("debug_trigger_ali_checkpoint_for_smoke"):
		failures.append("missing checkpoint smoke helper")
	else:
		scene.debug_trigger_ali_checkpoint_for_smoke()
		await process_frame
		var npc := scene.get_node_or_null("EncounterNPC")
		if not bool(scene.get("checkpoint_active")):
			failures.append("Ali checkpoint did not activate")
		var speaker_label := scene.get_node_or_null("UI/CheckpointPanel/Card/SpeakerName") as Label
		if speaker_label == null or not speaker_label.text.contains("علي"):
			failures.append("Ali checkpoint speaker label is incorrect")
		if player != null:
			var checkpoint_mouse := InputEventMouseButton.new()
			checkpoint_mouse.button_index = MOUSE_BUTTON_LEFT
			checkpoint_mouse.pressed = true
			player.velocity = Vector2.ZERO
			scene._input(checkpoint_mouse)
			if player.velocity.y < 0.0:
				failures.append("checkpoint click caused an accidental jump")
		if npc == null or not npc.visible:
			failures.append("Ali checkpoint NPC is not visible")
		elif npc.get_node_or_null("CheckpointArt") == null and npc.get_node_or_null("NPCCard") == null:
			failures.append("Ali checkpoint has neither portrait nor fallback card")
		scene.debug_complete_checkpoint_for_smoke()
		await create_timer(0.55).timeout
		if bool(scene.get("checkpoint_active")) or bool(scene.get("countdown_active")):
			failures.append("checkpoint/countdown did not finish")
		if npc != null and npc.visible:
			failures.append("checkpoint NPC remained visible after resume")
		if player == null or not bool(player.get("_gameplay_active")):
			failures.append("player did not resume after checkpoint")
		if obstacle_timer == null or obstacle_timer.is_stopped():
			failures.append("obstacles did not resume after checkpoint")
		if collectible_spawner == null or not collectible_spawner.is_spawning():
			failures.append("collectibles did not resume after checkpoint")
		if camera == null or camera.position.distance_to(target_position) > 1.0:
			failures.append("gameplay camera was not restored after checkpoint")

	if not scene.has_method("debug_show_ending_for_smoke"):
		failures.append("missing ending smoke helper")
	else:
		scene.debug_show_ending_for_smoke()
		await process_frame
		var ending_image := scene.get_node_or_null("UI/GameOverPanel/EndingImage") as TextureRect
		if ending_image == null or not ending_image.visible or ending_image.texture == null:
			failures.append("family ending image is not visible")
		var retry_button := scene.get_node_or_null("UI/GameOverPanel/Card/RetryButton") as Button
		var restart_button := scene.get_node_or_null("UI/GameOverPanel/Card/RestartButton") as Button
		if retry_button == null or restart_button == null or not retry_button.visible or not restart_button.visible:
			failures.append("ending replay/menu buttons are unavailable")

	if failures.is_empty():
		print("LEVEL2_INPUT_SMOKE=PASS mouse=10/10 touch=true space=true ui_gated=true")
		print("LEVEL2_CHECKPOINT_RESUME_SMOKE=PASS obstacles=true collectibles=true")
		print("LEVEL2_RUNTIME_SMOKE=PASS")
		quit(0)
	else:
		for failure in failures:
			push_error("LEVEL2_RUNTIME_SMOKE failure: %s" % failure)
		print("LEVEL2_RUNTIME_SMOKE=FAIL count=%d" % failures.size())
		quit(1)
