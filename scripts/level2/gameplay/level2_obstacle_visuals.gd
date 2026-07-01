## level2_obstacle_visuals.gd — Level 2 obstacle visual skin manager.
## Adds a harbor-themed Sprite2D skin on top of each Level 1 obstacle,
## without touching Level 1 ObstacleSpawner or its collision logic.
##
## Usage: call apply_skin(obstacle_node, obstacle_type_string) right after
## the spawner creates an obstacle. The spawner remains untouched.
extends RefCounted

const MANIFEST := preload("res://scripts/level2/level2_asset_manifest.gd")

# Cache loaded textures so each is only loaded once per session.
var _tex_cache: Dictionary = {}


## Apply harbor skin to an existing obstacle node.
## obstacle_type: string key from ObstacleSpawner definition (block/barrier/cone/crate/sign)
## Returns true if a real texture was applied; false = procedural placeholder stays.
func apply_skin(obstacle: Node2D, obstacle_type: String) -> bool:
	if obstacle == null:
		return false

	# Remove any previously applied skin.
	var old := obstacle.get_node_or_null("L2Skin")
	if old != null:
		old.queue_free()

	var tex := _get_texture(obstacle_type)
	if tex == null:
		return false

	# Hide the Level 1 procedural Polygon2D under the L2 skin.
	var old_poly := obstacle.get_node_or_null("Polygon2D")
	if old_poly != null:
		old_poly.visible = false

	var skin := Sprite2D.new()
	skin.name = "L2Skin"
	skin.texture = tex
	skin.centered = true
	skin.position = Vector2.ZERO
	var obs_h: float = _get_obstacle_visual_height(obstacle_type)
	if obs_h > 0.0 and tex.get_height() > 0:
		var s := obs_h / float(tex.get_height())
		skin.scale = Vector2(s, s)

	obstacle.add_child(skin)
	return true


func _get_texture(obs_type: String) -> Texture2D:
	if _tex_cache.has(obs_type):
		return _tex_cache[obs_type]
	var tex := MANIFEST.get_obstacle_texture(obs_type)
	_tex_cache[obs_type] = tex  # cache even if null (avoids repeated disk checks)
	return tex


func _get_obstacle_visual_height(obs_type: String) -> float:
	# Match Level 1 obstacle visual_target_height from OBSTACLE_DEFINITIONS.
	match obs_type:
		"block":   return 56.0
		"barrier": return 56.0
		"cone":    return 48.0
		"crate":   return 54.0
		"sign":    return 58.0
	return 54.0
