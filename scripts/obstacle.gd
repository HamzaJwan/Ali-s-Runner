extends Area2D

signal passed
signal hit

const ASSET_UTILS := preload("res://scripts/asset_utils.gd")
const DEFAULT_SPEED := 225.0
const DEFAULT_DEFINITION := {
	"id": "block",
	"asset_path": "res://assets/objects/obstacle_block.png",
	"placeholder_color": Color(1.0, 0.35, 0.25),
	"visual_target_height": 56.0,
	"collision_width": 30.0,
	"collision_height": 50.0,
}

@export var speed := DEFAULT_SPEED

@onready var obstacle_sprite: Sprite2D = $ObstacleSprite
@onready var placeholder_shape: Polygon2D = $Polygon2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var _active := true
var _definition: Dictionary = DEFAULT_DEFINITION.duplicate(true)


func configure(definition: Dictionary, movement_speed: float) -> void:
	_definition = definition.duplicate(true)
	speed = movement_speed


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_apply_definition()


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


func _apply_definition() -> void:
	var collision_width: float = _definition["collision_width"]
	var collision_height: float = _definition["collision_height"]
	var collision_bottom_y := collision_height / 2.0
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(collision_width, collision_height)
	collision_shape.shape = rectangle
	placeholder_shape.polygon = PackedVector2Array([
		Vector2(-collision_width / 2.0, -collision_height / 2.0),
		Vector2(collision_width / 2.0, -collision_height / 2.0),
		Vector2(collision_width / 2.0, collision_height / 2.0),
		Vector2(-collision_width / 2.0, collision_height / 2.0),
	])
	placeholder_shape.color = _definition["placeholder_color"]

	if ASSET_UTILS.set_sprite_texture_if_exists(
			obstacle_sprite, _definition["asset_path"]
	):
		obstacle_sprite.centered = true
		ASSET_UTILS.fit_sprite_visible_to_height(
			obstacle_sprite, _definition["visual_target_height"]
		)
		ASSET_UTILS.align_sprite_visible_bottom(
			obstacle_sprite, collision_bottom_y
		)
		print("[layout] Obstacle id=", _definition["id"],
			" final_scale=", obstacle_sprite.scale,
			" visible_bottom=", collision_bottom_y,
			" collision_bottom=", collision_bottom_y)
		placeholder_shape.visible = false
	else:
		obstacle_sprite.visible = false
		placeholder_shape.visible = true
		print("[layout] Obstacle id=", _definition["id"],
			" using placeholder size=", rectangle.size)
