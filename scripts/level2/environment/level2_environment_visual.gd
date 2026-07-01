## level2_environment_visual.gd — Level 2 environment PNG auto-loader.
## Reads paths from Level2AssetManifest. Each layer can be dropped independently.
## Falls back to procedural shapes if any layer is missing. Non-fatal.
extends Node

const MANIFEST := preload("res://scripts/level2/level2_asset_manifest.gd")

const VIEW_W := 1152.0
const VIEW_H := 648.0

var _loaded_count := 0
var _missing: Array[String] = []


## Approximate sky blue from bg_sky_marsa.png — used as solid backdrop fill
## so any gap between layers shows sky color instead of white/black.
const SKY_FILL_COLOR := Color(0.53, 0.78, 0.96, 1.0)

## Call once from Level2_Marsa_Playable._ready() with the $Background node.
## Returns true if at least one real layer was loaded.
func setup(background_node: Node2D) -> bool:
	_loaded_count = 0
	_missing.clear()

	# Add a sky-colored fill FIRST so any seam between layers shows sky, not white.
	# This ColorRect is camera-relative; the parallax code repositions it each frame
	# alongside the sky layer via the L2_SkyLayer node.
	var sky_fill := background_node.get_node_or_null("L2_SkyFill")
	if sky_fill == null:
		var fill := ColorRect.new()
		fill.name = "L2_SkyFill"
		fill.color = SKY_FILL_COLOR
		# Very large so it always covers even at zoom 0.95; sky layer re-positions it.
		fill.size = Vector2(VIEW_W * 3.0, VIEW_H * 4.0)
		fill.position = Vector2(-VIEW_W, -VIEW_H * 1.5)
		fill.z_index = -10
		var sky_node := background_node.get_node_or_null("L2_SkyLayer")
		if sky_node != null:
			sky_node.add_child(fill)
		else:
			background_node.add_child(fill)

	var layers := MANIFEST.get_background_layers()
	for node_name: String in layers:
		var path: String = layers[node_name]
		var layer: Node2D = background_node.get_node_or_null(node_name)
		if layer == null:
			push_warning("[L2 Env] Layer node '%s' not found in scene." % node_name)
			continue
		var tex := load(path) as Texture2D
		if tex != null:
			_apply_layer(layer, tex, node_name)
			_loaded_count += 1
		else:
			_missing.append(path.get_file())

	if _missing.size() > 0:
		push_warning(
			"[L2 Env] %d background layer(s) using procedural placeholder: %s" %
			[_missing.size(), ", ".join(_missing)]
		)
	return _loaded_count > 0


func get_loaded_count() -> int:
	return _loaded_count


func _apply_layer(layer: Node2D, tex: Texture2D, node_name: String) -> void:
	# Remove procedural children before placing real sprite.
	for child: Node in layer.get_children():
		child.queue_free()

	var sprite := Sprite2D.new()
	sprite.name = "RealBG_" + node_name
	sprite.texture = tex
	sprite.centered = false
	sprite.position = Vector2.ZERO

	var tw: float = float(tex.get_width())
	var th: float = float(tex.get_height())
	if tw > 0.0 and th > 0.0:
		var s_x := VIEW_W / tw
		if node_name == "L2_SkyLayer":
			# Sky is the full-screen backdrop. Scale height to 2× viewport so it
			# fills completely at any camera zoom level (0.95 start → 1.38 gameplay).
			sprite.scale = Vector2(s_x, VIEW_H * 2.0 / th)
		else:
			# Other layers preserve aspect; the parallax loop positions them correctly.
			sprite.scale = Vector2(s_x, s_x)

	layer.add_child(sprite)
