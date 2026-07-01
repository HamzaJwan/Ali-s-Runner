## seagull_loop.gd — Decorative seagull that flies across the sky.
## Uses owner PNG sheet if present; falls back to tiny invisible node (no triangles).
## No collision, no enemy, purely decorative.
class_name SeagullLoop
extends Node2D

@export var flight_y: float     = 130.0
@export var speed: float        = 70.0
@export var from_right: bool    = false
@export var wing_beat_hz: float = 1.4

const VIEW_W := 1152.0

const SHEET_PATH   := "res://assets/level2/marsa/ambient/seagulls/seagull_fly_sheet_4f.png"
const SHEET_FRAMES := 4
const SHEET_W      := 610
const SHEET_H      := 147
const GULL_SCALE   := 0.14   # small distant bird

var _dir: float = 1.0


func _ready() -> void:
	_dir = -1.0 if from_right else 1.0
	position.y = flight_y
	position.x = -SHEET_W * 0.5 if not from_right else VIEW_W + SHEET_W * 0.5

	if ResourceLoader.exists(SHEET_PATH):
		_build_sprite_seagull()
	# If sheet is missing, node stays invisible (no triangle placeholder).


func _build_sprite_seagull() -> void:
	var tex := load(SHEET_PATH) as Texture2D
	if tex == null:
		return

	var anim := AnimatedSprite2D.new()
	var sf := SpriteFrames.new()
	sf.add_animation("fly")
	sf.set_animation_speed("fly", wing_beat_hz * 4.0)   # 4 poses per beat cycle
	sf.set_animation_loop("fly", true)

	var fw := SHEET_W / SHEET_FRAMES   # 152 px per frame
	for i: int in SHEET_FRAMES:
		var atlas := AtlasTexture.new()
		atlas.atlas = tex
		atlas.region = Rect2(i * fw, 0, fw, SHEET_H)
		sf.add_frame("fly", atlas)

	anim.sprite_frames = sf
	# Sprite sheet faces LEFT by default.
	# Flying right (from_right=false, _dir=1) → flip horizontally to face right.
	# Flying left  (from_right=true,  _dir=-1) → no flip (already faces left).
	anim.flip_h = not from_right
	anim.scale = Vector2(GULL_SCALE, GULL_SCALE)
	add_child(anim)
	anim.play("fly")


func _process(delta: float) -> void:
	position.x += speed * _dir * delta
	var margin := SHEET_W * GULL_SCALE * 4.0
	if _dir > 0.0 and position.x > VIEW_W + margin:
		position.x = -margin
		position.y = flight_y + randf_range(-20.0, 20.0)
	elif _dir < 0.0 and position.x < -margin:
		position.x = VIEW_W + margin
		position.y = flight_y + randf_range(-20.0, 20.0)
