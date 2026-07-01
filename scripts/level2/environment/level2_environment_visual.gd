## level2_environment_visual.gd
## Level 2 environment layer loader — auto-detects real PNG assets when present,
## falls back to current procedural shapes silently (non-fatal).
##
## To activate real art:
##   Drop PNGs into assets/level2/marsa/backgrounds/
##   (see docs/level2/LEVEL2_ENVIRONMENT_ASSET_REQUIREMENTS.md)
##   Re-open Level2_Marsa_Playable.tscn — no code change needed.
##
## Lane: Environment Lane only. Do NOT call from Level 1 or shared scripts.
extends Node

const ASSET_ROOT := "res://assets/level2/marsa/backgrounds/"

const LAYER_SPECS: Array[Dictionary] = [
	{
		"name": "L2_SkyLayer",
		"file": "bg_sky_marsa.png",
		"parallax_ratio": 0.01,
		"z": -30,
		"loop": false,
	},
	{
		"name": "L2_SeaBreakwaterLayer",
		"file": "bg_sea_breakwater.png",
		"parallax_ratio": 0.05,
		"z": -20,
		"loop": true,
	},
	{
		"name": "L2_FarBuildingsLayer",
		"file": "bg_harbor_buildings.png",
		"parallax_ratio": 0.15,
		"z": -15,
		"loop": true,
	},
	{
		"name": "L2_BoatsMidLayer",
		"file": "mg_boats_mid.png",
		"parallax_ratio": 0.35,
		"z": -10,
		"loop": true,
	},
	{
		"name": "L2_ForegroundPierLayer",
		"file": "fg_pier_ground.png",
		"parallax_ratio": 1.0,
		"z": -5,
		"loop": true,
	},
]

var _loaded_count := 0
var _missing: Array[String] = []


## Call from Level2_Marsa_Playable._ready() with the Background node reference.
## Returns true if at least one real asset was loaded.
func setup(background_node: Node2D, view_w: float) -> bool:
	_loaded_count = 0
	_missing.clear()

	for spec: Dictionary in LAYER_SPECS:
		var layer: Node2D = background_node.get_node_or_null(spec["name"])
		if layer == null:
			continue
		var full_path: String = ASSET_ROOT + spec["file"]
		var tex := load(full_path) as Texture2D
		if tex != null:
			_apply_layer_sprite(layer, tex, view_w, spec)
			_loaded_count += 1
		else:
			_missing.append(spec["file"])

	if _missing.size() > 0:
		var warn_msg: String = (
			"[Level2 Environment] %d layer(s) missing — using procedural placeholder: %s. Drop PNGs in %s"
			% [_missing.size(), ", ".join(_missing), ASSET_ROOT]
		)
		push_warning(warn_msg)

	return _loaded_count > 0


func get_loaded_count() -> int:
	return _loaded_count


func get_missing_files() -> Array[String]:
	return _missing.duplicate()


func _apply_layer_sprite(layer: Node2D, tex: Texture2D, view_w: float, spec: Dictionary) -> void:
	# Clear any existing procedural children from the layer
	for child: Node in layer.get_children():
		child.queue_free()

	var sprite := Sprite2D.new()
	sprite.name = "LayerSprite_" + spec["name"]
	sprite.texture = tex
	sprite.centered = false
	sprite.position = Vector2.ZERO

	# Scale sprite to fit viewport width while preserving aspect
	var tex_w: float = float(tex.get_width())
	if tex_w > 0.0:
		sprite.scale = Vector2(view_w / tex_w, view_w / tex_w)

	sprite.z_index = spec.get("z", 0)
	layer.add_child(sprite)
