class_name Level2CollectibleSpawner
extends Node2D

signal collectible_spawned(collectible: Node)

const COLLECTIBLE_SCENE := preload("res://scenes/Collectible.tscn")
const SPAWN_X := 1292.0
const PATTERN_GAP_MIN := 2.8
const PATTERN_GAP_MAX := 4.2
const PATTERN_SPACING_X := 58.0

var current_speed := 225.0
var _timer: Timer
var _obstacle_spawner: Node
var _rng := RandomNumberGenerator.new()
var _pattern_index := 0
var _road_y := 510.0
var _visual_lane_offset := 30.0


func setup(spawn_timer: Timer, obstacle_spawner: Node) -> void:
	_timer = spawn_timer
	_obstacle_spawner = obstacle_spawner
	_timer.one_shot = true
	if not _timer.timeout.is_connected(_on_timer_timeout):
		_timer.timeout.connect(_on_timer_timeout)
	_rng.randomize()


func configure_lanes(road_y: float, visual_lane_offset: float) -> void:
	_road_y = road_y
	_visual_lane_offset = visual_lane_offset
	print("[L2 collectible] lanes run=%.0f light=%.0f full=%.0f" % _lane_values())


func start_spawning(speed: float) -> void:
	current_speed = speed
	_schedule_next()


func stop_spawning() -> void:
	if _timer != null:
		_timer.stop()


func is_spawning() -> bool:
	return _timer != null and not _timer.is_stopped()


func clear_collectibles() -> void:
	for child in get_children():
		child.queue_free()


func _on_timer_timeout() -> void:
	if _has_live_collectibles() or _obstacle_near_spawn_zone():
		_timer.start(0.75)
		return
	_spawn_next_pattern()
	_schedule_next()


func _spawn_next_pattern() -> void:
	var lanes := _lane_values()
	var patterns := [
		{"name": "LOW", "ys": [lanes[0], lanes[0], lanes[0], lanes[0]]},
		{"name": "SMALL", "ys": [lanes[0], lanes[1], lanes[2] + 20.0, lanes[1], lanes[0]]},
		{"name": "FULL", "ys": [lanes[1], lanes[2] + 15.0, lanes[2], lanes[2] + 15.0, lanes[1]]},
	]
	var pattern: Dictionary = patterns[_pattern_index % patterns.size()]
	_pattern_index += 1
	var ys: Array = pattern["ys"]
	for i in ys.size():
		_spawn_shard(SPAWN_X + i * PATTERN_SPACING_X, float(ys[i]))
	print("[L2 collectible] pattern=%s count=%d spawn_x=%.0f" % [pattern["name"], ys.size(), SPAWN_X])


func _spawn_shard(x: float, y: float) -> void:
	var shard := COLLECTIBLE_SCENE.instantiate()
	shard.speed = current_speed
	shard.position = Vector2(x, y)
	add_child(shard)
	collectible_spawned.emit(shard)


func _lane_values() -> Array[float]:
	return [
		_road_y - 55.0 + _visual_lane_offset,
		_road_y - 105.0 + _visual_lane_offset,
		_road_y - 150.0 + _visual_lane_offset,
	]


func _has_live_collectibles() -> bool:
	return get_child_count() > 0


func _obstacle_near_spawn_zone() -> bool:
	if _obstacle_spawner == null:
		return false
	for obstacle in _obstacle_spawner.get_children():
		if obstacle is Node2D and absf(obstacle.global_position.x - SPAWN_X) < 260.0:
			return true
	return false


func _schedule_next() -> void:
	if _timer != null:
		_timer.start(_rng.randf_range(PATTERN_GAP_MIN, PATTERN_GAP_MAX))
