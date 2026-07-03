## level2_environment_visual.gd — Level 2 Marsa background compositor.
##
## ARCHITECTURE NOTE (2026-07-02):
## All five background PNGs are opaque 24-bit RGB plates.  Stacking five opaque
## plates creates visible horizontal strip seams.  The active composition uses
## THREE plates only:
##
##   1. bg_sky_marsa.png       — full-screen sky backdrop, camera-fixed.
##   2. bg_harbor_buildings.png — harbor middle plate with top-fade shader so its
##                                sky-like top blends into the real sky image.
##   3. fg_pier_ground.png     — foreground pier/road, aligned to gameplay lane.
##
## bg_sea_breakwater.png and mg_boats_mid.png are kept in the manifest for future
## use but NOT rendered in the active stack — they are opaque and create seams.
## Transparent ambient assets (boat_blue_01.png etc.) handle mid-ground life.
##
## True five-layer parallax requires transparent cutout layers or newly authored
## seamless plates — document this for the art pipeline.
extends Node

const MANIFEST    := preload("res://scripts/level2/level2_asset_manifest.gd")
const TOP_FADE_SH := preload("res://assets/level2/marsa/shaders/bg_top_fade.gdshader")

const VIEW_W := 1152.0
const VIEW_H := 648.0

## Sky fill: solid sky-blue rendered behind every layer.
const SKY_FILL_COLOR := Color(0.53, 0.78, 0.96, 1.0)

## Active layer z-indices (absolute, z_as_relative=false).
const LAYER_Z: Dictionary = {
	"L2_SkyLayer":            -30,
	"L2_FarBuildingsLayer":   -18,   # buildings between sky and pier
	"L2_BoatsMidLayer":       -12,   # sea/boats strip, drifts slowly for motion feel
	"L2_ForegroundPierLayer": -5,
}

## bg_sea_breakwater: still skipped — too tall and wrong colour register for this stack.
## mg_boats_mid: loaded here for texture caching; its position/drift is driven every
## frame by level2_marsa_playable._update_background_parallax() via boats_layer.
const SKIPPED_LAYERS := ["L2_SeaBreakwaterLayer"]

var _loaded_count := 0
var _missing: Array[String] = []


## Call once from Level2_Marsa_Playable._ready() with the $Background node.
## Returns true if at least one real layer loaded.
func setup(background_node: Node2D) -> bool:
	_loaded_count = 0
	_missing.clear()

	# Solid sky-fill backdrop behind ALL layers — eliminates any color gap.
	var sky_node := background_node.get_node_or_null("L2_SkyLayer")
	if sky_node != null and sky_node.get_node_or_null("L2_SkyFill") == null:
		var fill := ColorRect.new()
		fill.name = "L2_SkyFill"
		fill.color = SKY_FILL_COLOR
		fill.size = Vector2(VIEW_W * 4.0, VIEW_H * 6.0)
		fill.position = Vector2(-VIEW_W * 1.5, -VIEW_H * 2.5)
		fill.z_index = -99
		sky_node.add_child(fill)

	# Apply z-indices on ALL five layer nodes (including the skipped ones, so
	# their z-order is correct if they ever re-enter the active stack).
	for layer_name: String in background_node.get_children().map(func(n: Node) -> String: return n.name):
		var layer: Node = background_node.get_node_or_null(layer_name)
		if layer == null:
			continue
		if LAYER_Z.has(layer_name):
			(layer as Node2D).z_index = LAYER_Z[layer_name]
			(layer as Node2D).z_as_relative = false
		else:
			(layer as Node2D).z_index = -10   # safe default for skipped layers
			(layer as Node2D).z_as_relative = false

	# Hide skipped layers completely so they don't contribute any pixels.
	for name: String in SKIPPED_LAYERS:
		var node := background_node.get_node_or_null(name)
		if node != null:
			(node as Node2D).visible = false

	# Load the four active plates.
	# L2_BoatsMidLayer (sea/boats mid) is loaded here so its texture is ready
	# but its X/Y position is driven every frame by level2_marsa_playable.gd
	# to create a slow sea-drift effect.
	var active_map := {
		"L2_SkyLayer":            MANIFEST.BG_SKY,
		"L2_FarBuildingsLayer":   MANIFEST.BG_BUILDINGS,
		"L2_BoatsMidLayer":       MANIFEST.BG_BOATS,
		"L2_ForegroundPierLayer": MANIFEST.BG_PIER,
	}
	for node_name: String in active_map:
		var path: String = active_map[node_name]
		var layer: Node2D = background_node.get_node_or_null(node_name)
		if layer == null:
			push_warning("[L2 Env] Layer node '%s' not found." % node_name)
			continue
		layer.visible = true
		var tex := load(path) as Texture2D
		if tex != null:
			_apply_layer(layer, tex, node_name)
			_loaded_count += 1
			print("[L2 Env] loaded %s" % node_name)
		else:
			_missing.append(path.get_file())

	if _missing.size() > 0:
		push_warning("[L2 Env] Missing textures (procedural fallback): %s" %
			", ".join(_missing))
	return _loaded_count > 0


func get_loaded_count() -> int:
	return _loaded_count


## Returns true if the pier (fg_pier_ground) was successfully loaded.
## Caller should hide GroundBase when this returns true.
func is_pier_loaded() -> bool:
	return MANIFEST.file_exists(MANIFEST.BG_PIER)


func _apply_layer(layer: Node2D, tex: Texture2D, node_name: String) -> void:
	for child: Node in layer.get_children():
		if child.name != "L2_SkyFill":
			child.queue_free()

	var tw := float(tex.get_width())
	var th := float(tex.get_height())
	if tw <= 0.0 or th <= 0.0:
		return

	var s_x := VIEW_W / tw

	if node_name == "L2_SkyLayer":
		# Sky: single sprite tall enough for any camera zoom (0.88 open → 1.18 play).
		var sky := Sprite2D.new()
		sky.name = "RealBG_Sky"
		sky.texture = tex
		sky.centered = false
		sky.position = Vector2.ZERO
		sky.scale = Vector2(s_x, VIEW_H * 2.0 / th)
		layer.add_child(sky)
		return

	# Non-sky: TWO side-by-side copies so parallax drift never creates a right-edge gap.
	# Each copy is VIEW_W world units wide; two together = 2×VIEW_W for safe coverage.
	for i in 2:
		var spr := Sprite2D.new()
		spr.name = "RealBG_%s_%d" % [node_name, i]
		spr.texture = tex
		spr.centered = false
		spr.position = Vector2(i * VIEW_W, 0.0)
		spr.scale = Vector2(s_x, s_x)

		# Apply top-fade shader to the buildings plate so it blends into the sky
		# instead of showing a hard rectangular top edge.
		if node_name == "L2_FarBuildingsLayer":
			var mat := ShaderMaterial.new()
			mat.shader = TOP_FADE_SH
			mat.set_shader_parameter("fade_px", 55.0)
			spr.material = mat

		layer.add_child(spr)
