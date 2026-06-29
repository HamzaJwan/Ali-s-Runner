class_name CollectibleSpawner
extends Node2D

## Owns all collectible ("شظايا نور") spawn timing and placement. main.gd
## only calls the same lifecycle shape ObstacleSpawner already exposes
## (setup/start_spawning/stop_spawning/clear_collectibles) and listens for
## each spawned shard's `collected` signal - it never reaches into this
## spawner's internals, and this spawner never touches obstacle logic.
##
## v1.37A scope (foundation only): a simple, independently-timed spawn of
## either a road-level shard or a slightly elevated one that encourages a
## small jump. Obstacle-relative patterns (an arc above an obstacle, a
## reward line right after one, etc.) are intentionally deferred to v1.37B
## - this milestone only guarantees a road-level shard never lands too
## close to a live obstacle (see _obstacle_too_close_to_spawn_x()).

signal collectible_spawned(collectible: Node)

const COLLECTIBLE_SCENE := preload("res://scenes/Collectible.tscn")
const VIEW_W := 1152.0
const ROAD_SURFACE_Y := 510.0
const SPAWN_MARGIN := 140.0
const SPAWN_X := VIEW_W + SPAWN_MARGIN

# Randomized and wider than the fixed obstacle interval (2.25s) so
# collectibles never feel mechanically tied to obstacle spawns.
const BASE_SPAWN_MIN_INTERVAL := 3.0
const BASE_SPAWN_MAX_INTERVAL := 5.0
const ELEVATED_SHARD_CHANCE := 0.4

# Road shard: comfortably grabbable while just running, no jump needed.
# Ali's grounded collision spans world Y 462-510 (PLAYER_COLLISION_HALF_
# HEIGHT=24 around a center at ROAD_SURFACE_Y-24); a shard centered here
# (460) overlaps that band by a forgiving margin.
const ROAD_SHARD_Y := ROAD_SURFACE_Y - 50.0
# Elevated/"jump" shard: measured against this project's actual jump arc,
# not guessed. Max rise = JUMP_VELOCITY^2 / (2*GRAVITY) = 440^2/(2*1050)
# ~= 92.19px, so the body's collision box (48 tall, centered on the body
# origin) spans world Y ~369.8-417.8 at the exact apex. 385 sits well
# inside that band (not at its razor edge), so this is reachable across a
# real, not pixel-perfect, slice of the jump arc - deliberately forgiving
# for a child-friendly first pass, per this task's own request.
const ELEVATED_SHARD_Y := ROAD_SURFACE_Y - 125.0

# Safety margin for the ground-level shard only: if a live obstacle is
# already this close to SPAWN_X, a road-level shard could land on or just
# behind it, so an elevated shard (always well above any obstacle's own
# height) is used instead that cycle. Elevated shards never need this
# check - they sit well above any obstacle's collision top already.
const ROAD_SHARD_OBSTACLE_SAFETY_X := 200.0

var current_speed := 225.0
var _spawn_timer: Timer
var _obstacle_spawner: Node
var _rng := RandomNumberGenerator.new()


func setup(spawn_timer: Timer, obstacle_spawner: Node) -> void:
	_spawn_timer = spawn_timer
	_spawn_timer.one_shot = true
	_obstacle_spawner = obstacle_spawner
	if not _spawn_timer.timeout.is_connected(_on_base_timer_timeout):
		_spawn_timer.timeout.connect(_on_base_timer_timeout)
	_rng.randomize()


func start_spawning(obstacle_speed: float) -> void:
	current_speed = obstacle_speed
	_restart_base_timer()


func stop_spawning() -> void:
	if _spawn_timer != null:
		_spawn_timer.stop()


func clear_collectibles() -> void:
	for child in get_children():
		child.queue_free()


func _restart_base_timer() -> void:
	_spawn_timer.wait_time = _rng.randf_range(
		BASE_SPAWN_MIN_INTERVAL, BASE_SPAWN_MAX_INTERVAL
	)
	_spawn_timer.start()


func _on_base_timer_timeout() -> void:
	_spawn_baseline_shard()
	_restart_base_timer()


func _spawn_baseline_shard() -> void:
	if _rng.randf() < ELEVATED_SHARD_CHANCE or _obstacle_too_close_to_spawn_x():
		_spawn_shard_at(SPAWN_X, ELEVATED_SHARD_Y)
	else:
		_spawn_shard_at(SPAWN_X, ROAD_SHARD_Y)


func _obstacle_too_close_to_spawn_x() -> bool:
	if _obstacle_spawner == null:
		return false
	for obstacle in _obstacle_spawner.get_children():
		if (
			obstacle is Node2D
			and absf(obstacle.global_position.x - SPAWN_X) < ROAD_SHARD_OBSTACLE_SAFETY_X
		):
			return true
	return false


func _spawn_shard_at(x: float, y: float) -> Node:
	var shard := COLLECTIBLE_SCENE.instantiate()
	shard.speed = current_speed
	shard.position = Vector2(x, y)
	add_child(shard)
	collectible_spawned.emit(shard)
	return shard
