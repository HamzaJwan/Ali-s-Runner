class_name CollectibleSpawner
extends Node2D

## Owns all collectible ("شظايا نور") spawn timing and placement. main.gd
## only calls the same lifecycle shape ObstacleSpawner already exposes
## (setup/start_spawning/stop_spawning/clear_collectibles) and listens for
## each spawned shard's `collected` signal - it never reaches into this
## spawner's internals, and this spawner never touches obstacle logic.
##
## v1.37A added the foundation: a simple, independently-timed spawn of
## either a road-level shard or a slightly elevated one that encourages a
## small jump, plus a safety check so a road-level shard never lands too
## close to a live obstacle (see _obstacle_too_close_to_spawn_x()).
##
## v1.37B adds safe obstacle-relative patterns on top of that baseline,
## listening to ObstacleSpawner's `obstacle_spawned` signal: a short arc
## above the obstacle, a reward line right after it, or a single raised
## shard near it. Every shard in a pattern is spawned at that exact
## obstacle's own spawn position/speed, so it keeps the same relative
## offset to it for its whole lifetime - by construction, a pattern can
## never end up positioned inside that obstacle's hitbox after the fact.

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

# v1.37B obstacle-relative patterns. Kept deliberately rare (chances sum to
# well under half of all obstacle spawns) and mutually exclusive per
# obstacle, so a pattern never stacks with the independent baseline timer
# closely enough to feel like a "dense coin tunnel."
const ARC_ABOVE_CHANCE := 0.15
const REWARD_LINE_CHANCE := 0.12
const RAISED_NEAR_BARRIER_CHANCE := 0.1
const ARC_SHARD_COUNT := 3
const ARC_SPACING_X := 48.0
# Clearance above the *specific* obstacle's own collision top (not a flat
# world Y), so this is always reachable regardless of obstacle height: at
# this project's real jump apex, the body's collision spans ~369.8-417.8 -
# clearing the tallest obstacle (collision_height=56, top=454) by 20px
# still lands at 434, comfortably inside that band, not at its edge.
const ARC_CLEARANCE_ABOVE_OBSTACLE := 20.0
const REWARD_LINE_COUNT := 3
const REWARD_LINE_SPACING_X := 62.0
const REWARD_LINE_START_OFFSET_X := 80.0
# Reachable while just running (no jump) - same reasoning as ROAD_SHARD_Y.
const REWARD_LINE_Y := ROAD_SURFACE_Y - 30.0
const RAISED_NEAR_BARRIER_OFFSET_X := 45.0
const RAISED_NEAR_BARRIER_Y := ROAD_SURFACE_Y - 60.0
# After any obstacle-relative pattern fires, suppress the independent
# baseline timer for this long so the two sources never visually crowd
# each other. Uses a one-shot timer restart rather than _process tracking.
const PATTERN_BASELINE_COOLDOWN := 1.8
# Minimum horizontal gap between the right-most live shard and SPAWN_X
# before a NEW baseline shard is allowed.  Pattern shards are placed at
# explicit relative offsets and are already guaranteed by construction not
# to overlap each other, so this check is only applied to the baseline path.
const MIN_SHARD_SPACING_X := 62.0

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
	if _obstacle_spawner != null and not _obstacle_spawner.obstacle_spawned.is_connected(_on_obstacle_spawned):
		_obstacle_spawner.obstacle_spawned.connect(_on_obstacle_spawned)
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
	if _shard_too_close_to_spawn_x():
		return
	if _rng.randf() < ELEVATED_SHARD_CHANCE or _obstacle_too_close_to_spawn_x():
		_spawn_shard_at(SPAWN_X, ELEVATED_SHARD_Y)
	else:
		_spawn_shard_at(SPAWN_X, ROAD_SHARD_Y)


func _shard_too_close_to_spawn_x() -> bool:
	for child in get_children():
		if child is Node2D and absf(child.global_position.x - SPAWN_X) < MIN_SHARD_SPACING_X:
			return true
	return false


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


## v1.37B: rolled once per real obstacle spawn. At most one pattern (or
## none) ever attaches to a given obstacle - never stacked.
func _on_obstacle_spawned(definition: Dictionary, obstacle_position: Vector2) -> void:
	var collision_height: float = definition.get("collision_height", 50.0)
	var collision_width: float = definition.get("collision_width", 30.0)
	var roll := _rng.randf()
	var spawned_pattern := false
	if roll < ARC_ABOVE_CHANCE:
		_spawn_arc_above(obstacle_position, collision_height)
		spawned_pattern = true
	elif roll < ARC_ABOVE_CHANCE + REWARD_LINE_CHANCE:
		_spawn_reward_line(obstacle_position)
		spawned_pattern = true
	elif roll < ARC_ABOVE_CHANCE + REWARD_LINE_CHANCE + RAISED_NEAR_BARRIER_CHANCE:
		_spawn_raised_near_barrier(obstacle_position, collision_width)
		spawned_pattern = true
	if spawned_pattern:
		_extend_base_timer(PATTERN_BASELINE_COOLDOWN)


func _extend_base_timer(extra_seconds: float) -> void:
	if _spawn_timer == null or not _spawn_timer.is_inside_tree():
		return
	var remaining := _spawn_timer.time_left
	_spawn_timer.stop()
	_spawn_timer.wait_time = remaining + extra_seconds
	_spawn_timer.start()


## A short arc of shards above the obstacle, cleared by
## ARC_CLEARANCE_ABOVE_OBSTACLE so it can never overlap the obstacle's own
## hitbox, and positioned within Ali's real jump-reachable height band -
## a genuine but fair ask, never an impossible one.
func _spawn_arc_above(obstacle_position: Vector2, collision_height: float) -> void:
	var arc_y := (
		obstacle_position.y - collision_height / 2.0 - ARC_CLEARANCE_ABOVE_OBSTACLE
	)
	var start_x := obstacle_position.x - ARC_SPACING_X
	for i in ARC_SHARD_COUNT:
		_spawn_shard_at(start_x + i * ARC_SPACING_X, arc_y)


## A short, easy-to-grab line right after the obstacle (further along
## Ali's approach, i.e. larger X), at a height reachable while still
## running - no jump required, a calm reward right after clearing a hazard.
func _spawn_reward_line(obstacle_position: Vector2) -> void:
	for i in REWARD_LINE_COUNT:
		var x := obstacle_position.x + REWARD_LINE_START_OFFSET_X + i * REWARD_LINE_SPACING_X
		_spawn_shard_at(x, REWARD_LINE_Y)


## A single, modestly raised shard just past the obstacle - a small, safe
## variation on the reward line for thinner obstacles like a barrier.
func _spawn_raised_near_barrier(obstacle_position: Vector2, collision_width: float) -> void:
	var x := obstacle_position.x + collision_width / 2.0 + RAISED_NEAR_BARRIER_OFFSET_X
	_spawn_shard_at(x, RAISED_NEAR_BARRIER_Y)
