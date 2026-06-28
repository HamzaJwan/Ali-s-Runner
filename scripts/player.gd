class_name Player

extends CharacterBody2D

signal died

const ALI_VISUAL := preload("res://scripts/player_visual.gd")
const GRAVITY := 1050.0
const JUMP_VELOCITY := -440.0
const MAX_FALL_SPEED := 700.0
const JUMP_BUFFER_TIME := 0.12
const LAND_POSE_TIME := 0.10

@onready var ali_sprite = $AliSprite
@onready var placeholder_shape: Polygon2D = $Polygon2D

var _alive := true
var _gameplay_active := false
var _was_airborne := false
var _land_pose_remaining := 0.0
var _jump_buffer_remaining := 0.0


func _ready() -> void:
	_set_visual_pose(ALI_VISUAL.IDLE, true)


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
	_update_visual_pose(delta)


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
	_gameplay_active = false
	_was_airborne = false
	_land_pose_remaining = 0.0
	show()
	_set_visual_pose(ALI_VISUAL.IDLE, true)


func set_gameplay_active(active: bool) -> void:
	_gameplay_active = active
	if not active and _alive:
		_set_visual_pose(ALI_VISUAL.IDLE)


func kill() -> void:
	_alive = false
	velocity = Vector2.ZERO
	_jump_buffer_remaining = 0.0
	_gameplay_active = false
	show()
	_set_visual_pose(ALI_VISUAL.HURT)
	emit_signal("died")


func show_victory_pose() -> void:
	_gameplay_active = false
	_set_visual_pose(ALI_VISUAL.VICTORY)


func _update_visual_pose(delta: float) -> void:
	if not _gameplay_active:
		return

	if not is_on_floor():
		_was_airborne = true
		_land_pose_remaining = 0.0
		_update_visual(
			delta,
			ALI_VISUAL.JUMP if velocity.y < 0.0 else ALI_VISUAL.FALL
		)
		return

	if _was_airborne:
		_was_airborne = false
		_land_pose_remaining = LAND_POSE_TIME
	if _land_pose_remaining > 0.0:
		_land_pose_remaining = maxf(_land_pose_remaining - delta, 0.0)
		_update_visual(delta, ALI_VISUAL.LAND)
	else:
		_update_visual(delta, ALI_VISUAL.RUN)


func _set_visual_pose(pose: StringName, force_refresh: bool = false) -> void:
	ali_sprite.show_pose(pose, force_refresh)
	placeholder_shape.visible = not ali_sprite.has_texture()


func _update_visual(delta: float, pose: StringName) -> void:
	ali_sprite.update_visual(delta, pose)
	placeholder_shape.visible = not ali_sprite.has_texture()
