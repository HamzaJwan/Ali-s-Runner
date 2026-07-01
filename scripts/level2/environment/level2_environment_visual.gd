## level2_environment_visual.gd — Level 2 environment PNG auto-loader.
## Reads paths from Level2AssetManifest. Each layer can be dropped independently.
## Creates TWO side-by-side sprite copies per layer so parallax drift never
## causes gaps — 2×1152 world units of coverage is safe for any session.
extends Node

const MANIFEST := preload("res://scripts/level2/level2_asset_manifest.gd")

const VIEW_W := 1152.0
const VIEW_H := 648.0

## Sky fill: solid sky-blue behind all layers to eliminate any white seam gaps.
const SKY_FILL_COLOR := Color(0.53, 0.78, 0.96, 1.0)

## Layer z-indices (absolute).
const LAYER_Z: Dictionary = {
	"L2_SkyLayer":            -30,
	"L2_SeaBreakwaterLayer":  -25,
	"L2_FarBuildingsLayer":   -20,
	"L2_BoatsMidLayer":       -15,
	"L2_ForegroundPierLayer": -5,
}

var _loaded_count := 0
var _missing: Array[String] = []


## Call once from Level2_Marsa_Playable._ready() with the $Background node.
## Returns true if at least one real layer was loaded.
func setup(background_node: Node2D) -> bool:
	_loaded_count = 0
	_missing.clear()

	# Solid sky-fill rect as lowest backdrop — eliminates white gaps between layers.
	var sky_node := background_node.get_node_or_null("L2_SkyLayer")
	if sky_node != null and sky_node.get_node_or_null("L2_SkyFill") == null:
		var fill := ColorRect.new()
		fill.name = "L2_SkyFill"
		fill.color = SKY_FILL_COLOR
		fill.size = Vector2(VIEW_W * 4.0, VIEW_H * 6.0)
		fill.position = Vector2(-VIEW_W * 1.5, -VIEW_H * 2.5)
		fill.z_index = -99
		sky_node.add_child(fill)

	# Set z-index on each layer node for correct render order.
	for node_name: String in LAYER_Z:
		var layer: Node2D = background_node.get_node_or_null(node_name)
		if layer != null:
			layer.z_index = LAYER_Z[node_name]
			layer.z_as_relative = false

	var layers := MANIFEST.get_background_layers()
	for node_name: String in layers:
		var path: String = layers[node_name]
		var layer: Node2D = background_node.get_node_or_null(node_name)
		if layer == null:
			push_warning("[L2 Env] Layer node '%s' not found." % node_name)
			continue
		var tex := load(path) as Texture2D
		if tex != null:
			_apply_layer(layer, tex, node_name)
			_loaded_count += 1
		else:
			_missing.append(path.get_file())

	if _missing.size() > 0:
		push_warning("[L2 Env] %d layer(s) using procedural placeholder: %s" %
			[_missing.size(), ", ".join(_missing)])
	return _loaded_count > 0


func get_loaded_count() -> int:
	return _loaded_count


func _apply_layer(layer: Node2D, tex: Texture2D, node_name: String) -> void:
	# Remove any existing procedural or previous sprites.
	for child: Node in layer.get_children():
		if child.name != "L2_SkyFill":   # keep the sky fill
			child.queue_free()

	var tw := float(tex.get_width())
	var th := float(tex.get_height())
	if tw <= 0.0 or th <= 0.0:
		return

	var s_x := VIEW_W / tw

	if node_name == "L2_SkyLayer":
		# Sky: single sprite stretched to cover full backdrop at any zoom.
		var sky_spr := Sprite2D.new()
		sky_spr.name = "RealBG_Sky"
		sky_spr.texture = tex
		sky_spr.centered = false
		sky_spr.position = Vector2.ZERO
		sky_spr.scale = Vector2(s_x, VIEW_H * 2.0 / th)  # tall enough for any zoom
		layer.add_child(sky_spr)
		return

	# Non-sky: TWO side-by-side sprites, each VIEW_W wide.
	# Together they span 2×VIEW_W = 2304 world units, absorbing any parallax drift.
	# A drift of up to 1302 world units is safe before the rightmost sprite goes
	# off-screen — sufficient for ~48,000 world units of camera travel.
	for i in 2:
		var sprite := Sprite2D.new()
		sprite.name = "RealBG_%s_%d" % [node_name, i]
		sprite.texture = tex
		sprite.centered = false
		sprite.position = Vector2(i * VIEW_W, 0.0)
		sprite.scale = Vector2(s_x, s_x)
		layer.add_child(sprite)

	print("[L2 Env] loaded %s (2 copies × %.0fw)" % [node_name, VIEW_W])
