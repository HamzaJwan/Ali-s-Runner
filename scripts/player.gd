class_name Player

extends CharacterBody2D

signal died
signal landed
signal jumped

const ALI_VISUAL := preload("res://scripts/player_visual.gd")
const GRAVITY := 1050.0
const JUMP_VELOCITY := -440.0
const MAX_FALL_SPEED := 700.0
const JUMP_BUFFER_TIME := 0.12
const LAND_POSE_TIME := 0.10
const SHADOW_COLOR := Color(0.08, 0.06, 0.05, 0.28)
const SHADOW_SOFT_COLOR := Color(0.08, 0.06, 0.05, 0.12)
const SHADOW_RADIUS := Vector2(14.0, 4.0)
const SHADOW_SOFT_RADIUS := Vector2(20.0, 6.0)
const SHADOW_OVAL_POINTS := 16
const DUST_COLOR := Color(0.82, 0.74, 0.6, 0.5)
const IMPACT_DUST_COLOR := Color(0.78, 0.7, 0.58, 0.6)

@onready var ali_sprite = $AliSprite
@onready var placeholder_shape: Polygon2D = $Polygon2D

var _alive := true
var _gameplay_active := false
var _was_airborne := false
var _land_pose_remaining := 0.0
var _jump_buffer_remaining := 0.0
var _ground_shadow: Polygon2D
var _run_dust: CPUParticles2D
var _impact_dust: CPUParticles2D
var _last_run_contact_frame := -1


func _ready() -> void:
	_set_visual_pose(ALI_VISUAL.IDLE, true)
	_setup_ground_polish()


func _setup_ground_polish() -> void:
	var feet_y: float = ali_sprite.FEET_Y

	var soft_shadow := Polygon2D.new()
	soft_shadow.polygon = _build_oval_polygon(SHADOW_SOFT_RADIUS)
	soft_shadow.color = SHADOW_SOFT_COLOR
	soft_shadow.position = Vector2(0, feet_y)
	soft_shadow.z_as_relative = true
	soft_shadow.z_index = -5
	add_child(soft_shadow)

	_ground_shadow = Polygon2D.new()
	_ground_shadow.polygon = _build_oval_polygon(SHADOW_RADIUS)
	_ground_shadow.color = SHADOW_COLOR
	_ground_shadow.position = Vector2(0, feet_y)
	_ground_shadow.z_as_relative = true
	_ground_shadow.z_index = -5
	add_child(_ground_shadow)

	_run_dust = CPUParticles2D.new()
	_run_dust.position = Vector2(0, feet_y)
	_run_dust.amount = 6
	_run_dust.lifetime = 0.4
	_run_dust.one_shot = false
	_run_dust.emitting = false
	_run_dust.direction = Vector2(-1, -0.3)
	_run_dust.spread = 20.0
	_run_dust.gravity = Vector2(0, 40)
	_run_dust.initial_velocity_min = 18.0
	_run_dust.initial_velocity_max = 32.0
	_run_dust.scale_amount_min = 1.5
	_run_dust.scale_amount_max = 2.5
	_run_dust.color = DUST_COLOR
	add_child(_run_dust)

	_impact_dust = CPUParticles2D.new()
	_impact_dust.position = Vector2(0, feet_y)
	_impact_dust.amount = 10
	_impact_dust.lifetime = 0.45
	_impact_dust.one_shot = true
	_impact_dust.emitting = false
	_impact_dust.direction = Vector2(0, -1)
	_impact_dust.spread = 60.0
	_impact_dust.gravity = Vector2(0, 60)
	_impact_dust.initial_velocity_min = 24.0
	_impact_dust.initial_velocity_max = 48.0
	_impact_dust.scale_amount_min = 1.5
	_impact_dust.scale_amount_max = 3.0
	_impact_dust.color = IMPACT_DUST_COLOR
	add_child(_impact_dust)


func _build_oval_polygon(radius: Vector2) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in SHADOW_OVAL_POINTS:
		var angle := TAU * float(i) / float(SHADOW_OVAL_POINTS)
		points.append(Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	return points


func _play_impact_dust() -> void:
	if _impact_dust == null:
		return
	_impact_dust.restart()
	_impact_dust.emitting = true


## Adds a tiny extra dust accent right on the run cycle's ground-contact
## frames, on top of the existing continuous _run_dust trail (not a
## replacement for it - keeps the already-shipped/validated v1.2B dust look
## intact while adding the requested per-step emphasis). Reuses the same
## one-shot _impact_dust burst as jump/land/Game Over, so this adds no new
## particle system and no extra draw calls.
func _play_run_contact_dust() -> void:
	var frame_index: int = ali_sprite.run_frame_index
	if frame_index == _last_run_contact_frame:
		return
	_last_run_contact_frame = frame_index
	var contact_frames: Array = ALI_VISUAL.contact_frame_indices(
		ali_sprite.run_frame_textures.size()
	)
	if frame_index in contact_frames:
		_play_impact_dust()


func _physics_process(delta: float) -> void:
	if not _alive:
		return

	_jump_buffer_remaining = maxf(_jump_buffer_remaining - delta, 0.0)
	if not is_on_floor():
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)
	elif _jump_buffer_remaining > 0.0:
		velocity.y = JUMP_VELOCITY
		_jump_buffer_remaining = 0.0
		emit_signal("jumped")
		_play_impact_dust()

	move_and_slide()
	_update_visual_pose(delta)


func jump() -> void:
	if not _alive:
		return

	_jump_buffer_remaining = JUMP_BUFFER_TIME
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
		_jump_buffer_remaining = 0.0
		emit_signal("jumped")
		_play_impact_dust()


func reset_player(start_position: Vector2) -> void:
	global_position = start_position
	velocity = Vector2.ZERO
	_jump_buffer_remaining = 0.0
	_alive = true
	_gameplay_active = false
	_was_airborne = false
	_land_pose_remaining = 0.0
	if _run_dust != null:
		_run_dust.emitting = false
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
	if _run_dust != null:
		_run_dust.emitting = false
	show()
	_set_visual_pose(ALI_VISUAL.HURT)
	_play_impact_dust()
	emit_signal("died")


func show_victory_pose() -> void:
	_gameplay_active = false
	_set_visual_pose(ALI_VISUAL.VICTORY)


func _update_visual_pose(delta: float) -> void:
	if not _gameplay_active:
		_run_dust.emitting = false
		return

	if not is_on_floor():
		_was_airborne = true
		_land_pose_remaining = 0.0
		_run_dust.emitting = false
		_last_run_contact_frame = -1
		_update_visual(
			delta,
			ALI_VISUAL.JUMP if velocity.y < 0.0 else ALI_VISUAL.FALL
		)
		return

	if _was_airborne:
		_was_airborne = false
		_land_pose_remaining = LAND_POSE_TIME
		emit_signal("landed")
		_play_impact_dust()
	if _land_pose_remaining > 0.0:
		_land_pose_remaining = maxf(_land_pose_remaining - delta, 0.0)
		_run_dust.emitting = false
		_last_run_contact_frame = -1
		_update_visual(delta, ALI_VISUAL.LAND)
	else:
		_run_dust.emitting = true
		_update_visual(delta, ALI_VISUAL.RUN)
		_play_run_contact_dust()


func _set_visual_pose(pose: StringName, force_refresh: bool = false) -> void:
	ali_sprite.show_pose(pose, force_refresh)
	placeholder_shape.visible = not ali_sprite.has_texture()


func _update_visual(delta: float, pose: StringName) -> void:
	ali_sprite.update_visual(delta, pose)
	placeholder_shape.visible = not ali_sprite.has_texture()
