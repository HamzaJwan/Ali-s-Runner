extends SceneTree

const LEVEL2_SCENE := preload("res://scenes/level2/Level2_Marsa_Playable.tscn")


func _initialize() -> void:
	call_deferred("_run_smoke")


func _run_smoke() -> void:
	var scene := LEVEL2_SCENE.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	var failures: Array[String] = []
	if not scene.has_method("debug_start_gameplay_for_smoke"):
		failures.append("missing debug start helper")
	else:
		scene.debug_start_gameplay_for_smoke()

	# Covers camera reveal and the first 2.25s obstacle interval.
	await create_timer(2.5).timeout
	if not bool(scene.get("started")):
		failures.append("started is false")
	var player := scene.get_node_or_null("Player")
	if player == null or not bool(player.get("_gameplay_active")):
		failures.append("player gameplay is inactive")
	var obstacle_timer := scene.get_node_or_null("SpawnTimer") as Timer
	if obstacle_timer == null or obstacle_timer.is_stopped():
		failures.append("obstacle timer is stopped")
	var obstacles := scene.get_node_or_null("Obstacles")
	if obstacles == null or obstacles.get_child_count() == 0:
		failures.append("first obstacle did not spawn")
	else:
		var obstacle := obstacles.get_child(0)
		if obstacle.get_node_or_null("L2Skin") == null:
			failures.append("Level 2 obstacle skin is missing")
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

	if failures.is_empty():
		print("LEVEL2_RUNTIME_SMOKE=PASS")
		quit(0)
	else:
		for failure in failures:
			push_error("LEVEL2_RUNTIME_SMOKE failure: %s" % failure)
		print("LEVEL2_RUNTIME_SMOKE=FAIL count=%d" % failures.size())
		quit(1)
