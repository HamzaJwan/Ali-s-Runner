class_name Player

extends CharacterBody2D

signal died

const ASSET_UTILS := preload("res://scripts/asset_utils.gd")
const ALI_IDLE_TEXTURE_PATH := "res://assets/characters/ali/ali_idle.png"
const PLAYER_VISUAL_HEIGHT := 100.0
const COLLISION_BOTTOM_Y := 24.0
const GRAVITY := 1050.0
const JUMP_VELOCITY := -440.0
const MAX_FALL_SPEED := 700.0
const JUMP_BUFFER_TIME := 0.12

@onready var ali_sprite: Sprite2D = $AliSprite
@onready var placeholder_shape: Polygon2D = $Polygon2D

var _alive := true
var _jump_buffer_remaining := 0.0


func _ready() -> void:
	_apply_optional_texture()


func _physics_process(delta: float) -> void:
	if not _alive:
		return

	_jump_buffer_remaining = maxf(_jump_buffer_remaining - delta, 0.0)
	if not is_on_floor():
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)
	elif _jump_buffer_remaining > 0.0:
		velocity.y = JUMP_VELOCITY
		_jump_buffer_remaining = 0.0

	move_and_slide()


func jump() -> void:
	if not _alive:
		return

	_jump_buffer_remaining = JUMP_BUFFER_TIME
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
		_jump_buffer_remaining = 0.0


func reset_player(start_position: Vector2) -> void:
	global_position = start_position
	velocity = Vector2.ZERO
	_jump_buffer_remaining = 0.0
	_alive = true
	show()
	_apply_optional_texture()


func kill() -> void:
	_alive = false
	velocity = Vector2.ZERO
	_jump_buffer_remaining = 0.0
	hide()
	emit_signal("died")


func _apply_optional_texture() -> void:
	if ASSET_UTILS.set_sprite_texture_if_exists(ali_sprite, ALI_IDLE_TEXTURE_PATH):
		ali_sprite.centered = true
		ASSET_UTILS.fit_sprite_visible_to_height(ali_sprite, PLAYER_VISUAL_HEIGHT)
		ASSET_UTILS.align_sprite_visible_bottom(
			ali_sprite, COLLISION_BOTTOM_Y
		)
		print("[layout] Ali final_scale=", ali_sprite.scale,
			" visible_bottom=", COLLISION_BOTTOM_Y,
			" collision_bottom=", COLLISION_BOTTOM_Y)
		placeholder_shape.visible = false
	else:
		placeholder_shape.visible = true
