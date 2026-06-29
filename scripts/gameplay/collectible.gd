class_name Collectible
extends Area2D

## "شظية نور" (light shard) - a small golden collectible, fully separate
## from the story checkpoint reward system. Movement/animation/pickup-
## visuals are self-contained here; collectible_spawner.gd only places one
## and sets its speed, and main.gd only listens for `collected`.

signal collected

const ASSET_UTILS := preload("res://scripts/asset_utils.gd")
const DEFAULT_SPEED := 225.0
const VISUAL_TARGET_HEIGHT := 28.0
const DESPAWN_X := -120.0

# Real sourced asset (docs/ASSET_CREDITS.md: Eiyeron, CC0 1.0, OpenGameArt
# "Spinning heart and star trinkets", HUMAN_VISUAL_REVIEW_REQUIRED). Measured
# directly (64x96px, 6 frames stacked VERTICALLY at 64x16 each - confirmed
# with PIL, not assumed) - Sprite2D's vframes, not hframes, slices it
# correctly. If this exact path is ever missing/replaced, the static and
# placeholder fallbacks below still apply safely.
const SHEET_PATH := "res://assets/collectibles/light_shard/light_shard_sheet.png"
const SHEET_VFRAMES := 6
const SHEET_HFRAMES := 1
const SHEET_ANIMATION_FPS := 8.0

# Static-image fallback paths, checked only if the sheet is missing.
const STATIC_ASSET_PATHS := [
	"res://assets/collectibles/light_shard/light_shard.png",
	"res://assets/collectibles/light_shard/light_shard_1.png",
]

# Pulse applies in every visual mode (sheet, static, or placeholder) - a
# small shared "breathing" cue. Rotation is only applied to the static/
# placeholder fallback: the sheet's own 6 frames already convey a
# spin/shimmer, so adding node rotation on top of it would double up and
# look busy rather than "subtle."
const PULSE_PERIOD := 0.9
const PULSE_SCALE_MIN := 0.92
const PULSE_SCALE_MAX := 1.1
const FALLBACK_ROTATION_SPEED := 1.6

# Pickup juice: a brief sparkle burst plus a quick scale/fade pop, then the
# node frees itself. No new particle framework - the same cheap one-shot
# CPUParticles2D approach already used for obstacle/player dust.
const PICKUP_SPARKLE_LIFETIME := 0.35
const PICKUP_POP_SCALE := 1.6
const PICKUP_POP_TIME := 0.22

const GOLDEN_COLOR := Color(1.0, 0.82, 0.25, 1.0)
const GOLDEN_SPARKLE_COLOR := Color(1.0, 0.92, 0.55, 0.85)

@export var speed := DEFAULT_SPEED

@onready var shard_sprite: Sprite2D = $ShardSprite
@onready var placeholder_shape: Polygon2D = $Polygon2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var pickup_sparkle: CPUParticles2D = $PickupSparkle

var _active := true
var _collected := false
var _pulse_time := 0.0
var _frame_anim_time := 0.0
var _base_scale := Vector2.ONE
var _visual_node: Node2D
var _is_animated_sheet := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_apply_visual()


func _apply_visual() -> void:
	if ASSET_UTILS.set_sprite_texture_if_exists(shard_sprite, SHEET_PATH):
		shard_sprite.centered = true
		shard_sprite.vframes = SHEET_VFRAMES
		shard_sprite.hframes = SHEET_HFRAMES
		shard_sprite.frame = 0
		var frame_height := float(shard_sprite.texture.get_height()) / SHEET_VFRAMES
		var uniform_scale := VISUAL_TARGET_HEIGHT / frame_height
		shard_sprite.scale = Vector2(uniform_scale, uniform_scale)
		placeholder_shape.visible = false
		_visual_node = shard_sprite
		_base_scale = shard_sprite.scale
		_is_animated_sheet = true
		return

	for path in STATIC_ASSET_PATHS:
		if ASSET_UTILS.set_sprite_texture_if_exists(shard_sprite, path):
			shard_sprite.centered = true
			ASSET_UTILS.fit_sprite_visible_to_height(shard_sprite, VISUAL_TARGET_HEIGHT)
			placeholder_shape.visible = false
			_visual_node = shard_sprite
			_base_scale = shard_sprite.scale
			return

	shard_sprite.visible = false
	placeholder_shape.visible = true
	_build_placeholder_star()
	_visual_node = placeholder_shape
	_base_scale = Vector2.ONE


## Missing-asset fallback: a procedural 5-point golden star, built once
## from plain geometry - never a texture, so it can never fail to load.
func _build_placeholder_star() -> void:
	var points := PackedVector2Array()
	var outer_radius := VISUAL_TARGET_HEIGHT / 2.0
	var inner_radius := outer_radius * 0.45
	for i in 10:
		var angle := -PI / 2.0 + i * PI / 5.0
		var point_radius := outer_radius if i % 2 == 0 else inner_radius
		points.append(Vector2(cos(angle) * point_radius, sin(angle) * point_radius))
	placeholder_shape.polygon = points
	placeholder_shape.color = GOLDEN_COLOR


func _process(delta: float) -> void:
	if not _active:
		return

	global_position.x -= speed * delta

	_pulse_time += delta
	var pulse_phase := sin(_pulse_time * TAU / PULSE_PERIOD) * 0.5 + 0.5
	var pulse_scale := lerpf(PULSE_SCALE_MIN, PULSE_SCALE_MAX, pulse_phase)
	_visual_node.scale = _base_scale * pulse_scale

	if _is_animated_sheet:
		_frame_anim_time += delta
		var frame_duration := 1.0 / SHEET_ANIMATION_FPS
		while _frame_anim_time >= frame_duration:
			_frame_anim_time -= frame_duration
			shard_sprite.frame = (shard_sprite.frame + 1) % (SHEET_VFRAMES * SHEET_HFRAMES)
	else:
		_visual_node.rotation += FALLBACK_ROTATION_SPEED * delta

	if global_position.x < DESPAWN_X:
		_active = false
		queue_free()


func _on_body_entered(body: Node) -> void:
	if not _active or _collected:
		return
	if body.name == "Player":
		_collect()


func _collect() -> void:
	_active = false
	_collected = true
	collision_shape.set_deferred("disabled", true)
	emit_signal("collected")
	_play_pickup_effect()


func _play_pickup_effect() -> void:
	pickup_sparkle.color = GOLDEN_SPARKLE_COLOR
	pickup_sparkle.restart()
	pickup_sparkle.emitting = true

	var pop_tween := create_tween().set_parallel()
	pop_tween.tween_property(
		_visual_node, "scale", _base_scale * PICKUP_POP_SCALE, PICKUP_POP_TIME
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	pop_tween.tween_property(
		_visual_node, "modulate:a", 0.0, PICKUP_POP_TIME
	)
	await get_tree().create_timer(PICKUP_SPARKLE_LIFETIME).timeout
	queue_free()
