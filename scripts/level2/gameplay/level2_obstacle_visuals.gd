## level2_obstacle_visuals.gd — Level 2 harbor obstacle visual skin manager.
## Adds a harbor-themed Sprite2D skin on each Level 1 obstacle.
## Hides the Level 1 Polygon2D. Keeps collision unchanged.
##
## Bottom alignment: skin.position.y = collision_height/2 - visual_height/2
## This pins the skin's visual bottom to the collision box's bottom edge.
extends RefCounted

const MANIFEST := preload("res://scripts/level2/level2_asset_manifest.gd")

# Target visual heights (px in world space) per obstacle type.
const VISUAL_HEIGHTS: Dictionary = {
	"block":   88.0,
	"barrier": 80.0,
	"cone":    80.0,
	"crate":   96.0,
	"sign":    72.0,
}

# Collision heights from Level 1 OBSTACLE_DEFINITIONS (obstacle_spawner.gd).
const COLLISION_HEIGHTS: Dictionary = {
	"block":   50.0,
	"barrier": 46.0,
	"cone":    44.0,
	"crate":   52.0,
	"sign":    56.0,
}

var _tex_cache: Dictionary = {}


func apply_skin(obstacle: Node2D, obstacle_type: String, visual_lane_offset := 0.0) -> bool:
	if obstacle == null:
		return false

	# Remove any previously applied skin.
	var old := obstacle.get_node_or_null("L2Skin")
	if old != null:
		old.queue_free()

	# Hide ALL Level 1 obstacle visuals:
	# - Polygon2D: procedural coloured rectangle
	# - ObstacleSprite: Sprite2D that configure() loads with the L1 asset_path texture
	for vname in ["Polygon2D", "ObstacleSprite"]:
		var v := obstacle.get_node_or_null(vname)
		if v != null:
			(v as Node2D).visible = false

	var tex := _get_texture(obstacle_type)
	if tex == null:
		push_warning("[L2 obstacle] type=%s texture missing; legacy visuals remain hidden" % obstacle_type)
		return false

	var vis_h: float  = VISUAL_HEIGHTS.get(obstacle_type, 56.0)
	var col_h: float  = COLLISION_HEIGHTS.get(obstacle_type, 50.0)

	# Scale skin so its visual height matches vis_h.
	var raw_h := float(tex.get_height())
	if raw_h <= 0.0:
		return false
	var s := vis_h / raw_h

	var skin := Sprite2D.new()
	skin.name = "L2Skin"
	skin.texture = tex
	skin.centered = true
	skin.scale = Vector2(s, s)
	# Align bottom of visual with bottom of collision box.
	skin.position.y = col_h / 2.0 - vis_h / 2.0 + visual_lane_offset

	obstacle.add_child(skin)
	print("[L2 obstacle] type=%s texture=%s loaded=true legacy_hidden=true vis_h=%.0f visual_bottom_y=%.1f" %
		[obstacle_type, tex.resource_path, vis_h, col_h / 2.0 + visual_lane_offset])
	return true


func _get_texture(obs_type: String) -> Texture2D:
	if _tex_cache.has(obs_type):
		return _tex_cache[obs_type]
	var tex := MANIFEST.get_obstacle_texture(obs_type)
	_tex_cache[obs_type] = tex
	return tex
