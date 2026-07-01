## seagull_loop.gd
## A single procedural seagull that flies across the sky and repeats.
## Drawn as a small M-shaped white polygon — no external asset required.
## No collision, no enemy behavior, purely decorative.
class_name SeagullLoop
extends Node2D

@export var flight_y: float     = 130.0  # world Y to fly at
@export var speed: float        = 70.0   # pixels per second
@export var from_right: bool    = false  # spawn direction
@export var wing_beat_hz: float = 1.4   # wing flaps per second

const VIEW_W := 1152.0
const GULL_SIZE := 8.0
const GULL_COLOR := Color(1.0, 1.0, 1.0, 0.80)

var _polygon: Polygon2D
var _wing_time: float = 0.0
var _dir: float = 1.0


func _ready() -> void:
	_dir = -1.0 if from_right else 1.0
	position.y = flight_y
	position.x = -GULL_SIZE * 3.0 if not from_right else VIEW_W + GULL_SIZE * 3.0

	_polygon = Polygon2D.new()
	_polygon.color = GULL_COLOR
	_polygon.scale.x = _dir
	add_child(_polygon)
	_update_wing(0.0)


func _process(delta: float) -> void:
	position.x += speed * _dir * delta

	# Wrap around when off-screen
	if _dir > 0.0 and position.x > VIEW_W + GULL_SIZE * 4.0:
		position.x = -GULL_SIZE * 3.0
		position.y = flight_y + randf_range(-15.0, 15.0)
	elif _dir < 0.0 and position.x < -GULL_SIZE * 4.0:
		position.x = VIEW_W + GULL_SIZE * 3.0
		position.y = flight_y + randf_range(-15.0, 15.0)

	_wing_time += delta
	_update_wing(_wing_time)


func _update_wing(t: float) -> void:
	# M-shape: two wings, flap angle varies with time
	var flap := sin(t * TAU * wing_beat_hz) * 0.5 + 0.5  # 0..1
	var up := lerpf(-GULL_SIZE * 0.3, -GULL_SIZE * 0.9, flap)
	var s := GULL_SIZE
	_polygon.polygon = PackedVector2Array([
		Vector2(-s,    0.0),
		Vector2(-s * 0.5, up),
		Vector2(0.0,  0.0),
		Vector2(s * 0.5,  up),
		Vector2(s,    0.0),
	])
