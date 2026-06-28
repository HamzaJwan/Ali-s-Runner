extends Area2D

signal passed
signal hit

const ASSET_UTILS := preload("res://scripts/asset_utils.gd")
const OBSTACLE_TEXTURE_PATH := "res://assets/objects/obstacle_block.png"
const OBSTACLE_VISUAL_HEIGHT := 56.0
const COLLISION_BOTTOM_Y := 25.0
const DEFAULT_SPEED := 225.0

@export var speed := DEFAULT_SPEED

@onready var obstacle_sprite: Sprite2D = $ObstacleSprite
@onready var placeholder_shape: Polygon2D = $Polygon2D

var _active := true


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_apply_optional_texture()


func _process(delta: float) -> void:
	if not _active:
		return

	global_position.x -= speed * delta

	if global_position.x < -120.0:
		_active = false
		emit_signal("passed")
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		_active = false
		emit_signal("hit")
		queue_free()


func _apply_optional_texture() -> void:
	if ASSET_UTILS.set_sprite_texture_if_exists(obstacle_sprite, OBSTACLE_TEXTURE_PATH):
		obstacle_sprite.centered = true
		ASSET_UTILS.fit_sprite_visible_to_height(
			obstacle_sprite, OBSTACLE_VISUAL_HEIGHT
		)
		ASSET_UTILS.align_sprite_visible_bottom(
			obstacle_sprite, COLLISION_BOTTOM_Y
		)
		print("[layout] Obstacle final_scale=", obstacle_sprite.scale,
			" visible_bottom=", COLLISION_BOTTOM_Y,
			" collision_bottom=", COLLISION_BOTTOM_Y)
		placeholder_shape.visible = false
	else:
		placeholder_shape.visible = true
