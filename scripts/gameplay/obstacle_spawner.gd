class_name ObstacleSpawner
extends Node2D

signal obstacle_passed
signal obstacle_hit

const OBSTACLE_SCENE := preload("res://scenes/Obstacle.tscn")
const DIFFICULTY_MANAGER := preload("res://scripts/gameplay/difficulty_manager.gd")
const VIEW_W := 1152.0
const ROAD_SURFACE_Y := 510.0
const SPAWN_INTERVAL := 2.25
const SPAWN_MARGIN := 140.0
const SPAWN_X := VIEW_W + SPAWN_MARGIN

const OBSTACLE_DEFINITIONS := [
	{
		"id": "block",
		"asset_path": "res://assets/objects/obstacle_block.png",
		"placeholder_color": Color(1.0, 0.35, 0.25),
		"visual_target_height": 56.0,
		"collision_width": 30.0,
		"collision_height": 50.0,
		"min_chapter": 1,
		"weight": 8,
	},
	{
		"id": "barrier",
		"asset_path": "res://assets/objects/obstacle_barrier.png",
		"placeholder_color": Color(0.96, 0.62, 0.18),
		"visual_target_height": 56.0,
		"collision_width": 68.0,
		"collision_height": 46.0,
		"min_chapter": 2,
		"weight": 4,
	},
	{
		"id": "cone",
		"asset_path": "res://assets/objects/obstacle_cone.png",
		"placeholder_color": Color(1.0, 0.76, 0.16),
		"visual_target_height": 48.0,
		"collision_width": 30.0,
		"collision_height": 44.0,
		"min_chapter": 3,
		"weight": 3,
	},
	{
		"id": "crate",
		"asset_path": "res://assets/objects/obstacle_crate.png",
		"placeholder_color": Color(0.55, 0.34, 0.18),
		"visual_target_height": 54.0,
		"collision_width": 48.0,
		"collision_height": 52.0,
		"min_chapter": 4,
		"weight": 3,
	},
	{
		"id": "sign",
		"asset_path": "res://assets/objects/obstacle_sign.png",
		"placeholder_color": Color(0.28, 0.62, 0.76),
		"visual_target_height": 58.0,
		"collision_width": 38.0,
		"collision_height": 56.0,
		"min_chapter": 4,
		"weight": 2,
	},
]

var current_speed := 225.0
var _spawn_timer: Timer


func setup(spawn_timer: Timer) -> void:
	_spawn_timer = spawn_timer
	_spawn_timer.wait_time = SPAWN_INTERVAL
	if not _spawn_timer.timeout.is_connected(_spawn_obstacle):
		_spawn_timer.timeout.connect(_spawn_obstacle)


func start_spawning(obstacle_speed: float) -> void:
	current_speed = obstacle_speed
	_spawn_timer.start()


func stop_spawning() -> void:
	if _spawn_timer != null:
		_spawn_timer.stop()


func clear_obstacles() -> void:
	for obstacle in get_children():
		obstacle.queue_free()


func _spawn_obstacle() -> void:
	var chapter := DIFFICULTY_MANAGER.get_chapter_for_speed(current_speed)
	var definition := _choose_weighted_definition(chapter)
	var obstacle := OBSTACLE_SCENE.instantiate()
	obstacle.configure(definition, current_speed)
	obstacle.position = Vector2(
		SPAWN_X,
		ROAD_SURFACE_Y - float(definition["collision_height"]) / 2.0
	)
	obstacle.passed.connect(obstacle_passed.emit)
	obstacle.hit.connect(obstacle_hit.emit)
	add_child(obstacle)
	print("[spawn] id=", definition["id"], " chapter=", chapter,
		" obstacle_x=", SPAWN_X, " margin=", SPAWN_MARGIN)


func _choose_weighted_definition(chapter: int) -> Dictionary:
	var allowed: Array[Dictionary] = []
	var total_weight := 0
	for definition: Dictionary in OBSTACLE_DEFINITIONS:
		if definition["min_chapter"] <= chapter:
			allowed.append(definition)
			total_weight += definition["weight"]

	var roll := randi_range(1, total_weight)
	for definition in allowed:
		roll -= definition["weight"]
		if roll <= 0:
			return definition.duplicate(true)
	return allowed[0].duplicate(true)
