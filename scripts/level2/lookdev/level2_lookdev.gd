## level2_lookdev.gd — Level 2 LookDev Scene Controller
## جمانة وأثر الكلمة — مرسى زليتن
##
## This is a VISUAL PROTOTYPE only. No gameplay, no production logic.
## Purpose: let the owner imagine the Level 2 harbor atmosphere.
##
## Every visual element is built procedurally (ColorRect / Polygon2D / Label)
## so the scene runs with ZERO external assets.
## Once real assets arrive, replace each node's Color/Polygon with a Sprite2D.
extends Node2D

# ── View / world constants ─────────────────────────────────────────────────
const VIEW_W := 1152.0
const VIEW_H  := 648.0
const ROAD_Y  := 510.0           # pier surface Y (same as Level 1)
const CURB_Y  := 470.0

# ── Palette — warm Libyan harbor ──────────────────────────────────────────
const SKY_TOP     := Color(0.40, 0.68, 0.90, 1.0)  # bright Mediterranean blue
const SKY_BOTTOM  := Color(0.72, 0.88, 0.98, 1.0)  # hazy horizon
const SEA_DEEP    := Color(0.15, 0.42, 0.66, 1.0)  # deep sea
const SEA_SHALLOW := Color(0.28, 0.60, 0.78, 1.0)  # shallow near pier
const FOAM_COLOR  := Color(0.92, 0.96, 1.00, 0.55)
const BREAKWATER  := Color(0.52, 0.48, 0.42, 1.0)  # stone grey
const HARBOR_BLDG := Color(0.74, 0.66, 0.54, 1.0)  # sandstone buildings
const BOAT_HULL   := Color(0.22, 0.34, 0.56, 1.0)  # blue boat hull
const BOAT_CABIN  := Color(0.88, 0.84, 0.72, 1.0)  # cream cabin
const PIER_STONE  := Color(0.68, 0.60, 0.48, 1.0)  # warm stone pier
const PIER_EDGE   := Color(0.56, 0.50, 0.40, 1.0)  # darker pier edge

const JOMANA_COLOR   := Color(0.30, 0.72, 0.58, 1.0)  # teal dress
const OBSTACLE_COLOR := Color(0.50, 0.45, 0.38, 1.0)  # stone/crate
const COLLECTIBLE_COLOR := Color(0.95, 0.55, 0.75, 1.0)  # pink أثر gem
const COLLECTIBLE_GLOW  := Color(1.00, 0.88, 0.38, 0.55)  # gold shimmer

# ── Node refs (set in scene) ───────────────────────────────────────────────
@onready var sky_layer:        Node2D = $Layers/L2_SkyLayer
@onready var sea_layer:        Node2D = $Layers/L2_SeaBreakwaterLayer
@onready var buildings_layer:  Node2D = $Layers/L2_FarBuildingsLayer
@onready var boats_layer:      Node2D = $Layers/L2_BoatsMidLayer
@onready var foreground_layer: Node2D = $Layers/L2_ForegroundPierLayer
@onready var ambient_layer:    Node2D = $AmbientLife
@onready var gameplay_layer:   Node2D = $GameplayLane
@onready var ui_layer:         CanvasLayer = $UI


func _ready() -> void:
	_build_sky()
	_build_sea_and_breakwater()
	_build_far_buildings()
	_build_boats()
	_build_pier_foreground()
	_build_ambient_life()
	_build_jomana()
	_build_obstacles()
	_build_collectibles()
	_build_ui_overlay()


# ── Layer 1: Sky ──────────────────────────────────────────────────────────

func _build_sky() -> void:
	# Top sky rectangle
	var sky := ColorRect.new()
	sky.name = "SkyRect"
	sky.color = SKY_TOP
	sky.size = Vector2(VIEW_W, 340.0)
	sky.position = Vector2.ZERO
	sky_layer.add_child(sky)

	# Horizon fade strip
	var horizon := ColorRect.new()
	horizon.name = "HorizonFade"
	horizon.color = SKY_BOTTOM
	horizon.size = Vector2(VIEW_W, 80.0)
	horizon.position = Vector2(0.0, 270.0)
	horizon.modulate.a = 0.6
	sky_layer.add_child(horizon)

	# Layer annotation
	_annotate(sky_layer, "⬆ L1 السماء — Sky", Vector2(8.0, 4.0))


# ── Layer 2: Sea + Breakwater ─────────────────────────────────────────────

func _build_sea_and_breakwater() -> void:
	# Sea body
	var sea := ColorRect.new()
	sea.name = "Sea"
	sea.color = SEA_DEEP
	sea.size = Vector2(VIEW_W, 180.0)
	sea.position = Vector2(0.0, 290.0)
	sea_layer.add_child(sea)

	# Shallow water near pier
	var shallow := ColorRect.new()
	shallow.color = SEA_SHALLOW
	shallow.size = Vector2(VIEW_W, 60.0)
	shallow.position = Vector2(0.0, 400.0)
	sea_layer.add_child(shallow)

	# Sea shimmer strip
	var shimmer := ColorRect.new()
	shimmer.color = FOAM_COLOR
	shimmer.size = Vector2(VIEW_W, 18.0)
	shimmer.position = Vector2(0.0, 330.0)
	sea_layer.add_child(shimmer)

	# Breakwater silhouette (stone polygon)
	var bw := Polygon2D.new()
	bw.name = "Breakwater"
	bw.color = BREAKWATER
	bw.polygon = PackedVector2Array([
		Vector2(0,     350), Vector2(200,  340), Vector2(420,  338),
		Vector2(500,  352), Vector2(680,  335), Vector2(900,  345),
		Vector2(1152, 340), Vector2(1152, 380), Vector2(0,    380),
	])
	sea_layer.add_child(bw)

	# ── Water shimmer shader overlay ──────────────────────────────────────
	# Loads water_shimmer.gdshader if available; falls back to tween-alpha.
	var shimmer_rect := ColorRect.new()
	shimmer_rect.name = "WaterShimmerShader"
	shimmer_rect.size = Vector2(VIEW_W, 130.0)
	shimmer_rect.position = Vector2(0.0, 295.0)
	var shader_res := load("res://scripts/level2/ambient/water_shimmer.gdshader") as Shader
	if shader_res != null:
		var mat := ShaderMaterial.new()
		mat.shader = shader_res
		shimmer_rect.material = mat
		shimmer_rect.color = Color(0.18, 0.48, 0.72, 1.0)  # passed to shader uniform
	else:
		# Fallback: animated alpha tween if shader can't load
		shimmer_rect.color = Color(0.55, 0.78, 0.95, 0.10)
		var t := shimmer_rect.create_tween()
		t.set_loops()
		t.tween_property(shimmer_rect, "modulate:a", 1.8, 2.8).set_trans(Tween.TRANS_SINE)
		t.tween_property(shimmer_rect, "modulate:a", 0.5, 2.8).set_trans(Tween.TRANS_SINE)
	sea_layer.add_child(shimmer_rect)

	_annotate(sea_layer, "⬆ L2 البحر والحاجز — Sea & Breakwater", Vector2(8.0, 293.0))


# ── Layer 3: Far Harbor Buildings ────────────────────────────────────────

func _build_far_buildings() -> void:
	var buildings := [
		# x, width, height, color_variation
		[60.0,  80.0, 70.0, 0.0],
		[160.0, 60.0, 85.0, 0.05],
		[240.0, 90.0, 55.0, -0.03],
		[400.0, 70.0, 90.0, 0.07],
		[490.0, 50.0, 60.0, 0.0],
		[620.0, 110.0, 75.0, -0.05],
		[750.0, 65.0, 80.0, 0.04],
		[850.0, 80.0, 65.0, 0.0],
		[950.0, 55.0, 88.0, 0.02],
		[1040.0, 75.0, 70.0, -0.02],
	]
	for b in buildings:
		var rect := ColorRect.new()
		var base := HARBOR_BLDG
		rect.color = Color(
			clampf(base.r + b[3], 0.0, 1.0),
			clampf(base.g + b[3] * 0.8, 0.0, 1.0),
			clampf(base.b + b[3] * 0.5, 0.0, 1.0),
			0.85
		)
		rect.size = Vector2(b[1] as float, b[2] as float)
		rect.position = Vector2(b[0] as float, 300.0 - b[2] as float + 50.0)
		buildings_layer.add_child(rect)

		# Simple window dots
		var win := ColorRect.new()
		win.color = Color(0.28, 0.24, 0.18, 0.6)
		win.size = Vector2(8.0, 8.0)
		win.position = Vector2(b[0] as float + 8.0, 300.0 - b[2] as float + 70.0)
		buildings_layer.add_child(win)

	_annotate(buildings_layer, "⬆ L3 مباني الميناء — Harbor Buildings", Vector2(8.0, 305.0))


# ── Layer 4: Boats / Mid Harbor ───────────────────────────────────────────

func _build_boats() -> void:
	_add_boat(boats_layer, Vector2(280.0, 372.0), 120.0, 0.0)
	_add_boat(boats_layer, Vector2(680.0, 368.0), 100.0, 1.3)
	_add_boat(boats_layer, Vector2(950.0, 374.0), 90.0,  0.7)
	_annotate(boats_layer, "⬆ L4 القوارب — Boats", Vector2(8.0, 378.0))


func _add_boat(parent: Node2D, pos: Vector2, w: float, bob_phase: float) -> void:
	var container := Node2D.new()
	container.position = pos
	container.set_meta("bob_base_y", pos.y)
	parent.add_child(container)

	# Hull
	var hull := Polygon2D.new()
	hull.color = BOAT_HULL
	var hw := w / 2.0
	hull.polygon = PackedVector2Array([
		Vector2(-hw, 0), Vector2(hw, 0),
		Vector2(hw * 0.85, 16.0), Vector2(-hw * 0.85, 16.0),
	])
	container.add_child(hull)

	# Cabin
	var cabin := ColorRect.new()
	cabin.color = BOAT_CABIN
	cabin.size = Vector2(w * 0.32, 20.0)
	cabin.position = Vector2(-w * 0.16, -20.0)
	container.add_child(cabin)

	# Mast — Polygon2D so sway script (extends Node2D) can be attached
	var mast := Polygon2D.new()
	mast.color = Color(0.35, 0.28, 0.18, 1.0)
	mast.polygon = PackedVector2Array([
		Vector2(-1.5, 0), Vector2(1.5, 0),
		Vector2(1.5, -38.0), Vector2(-1.5, -38.0),
	])
	mast.position = Vector2(0.0, -20.0)
	container.add_child(mast)

	# Attach sway to mast (Polygon2D extends Node2D — compatible)
	var sway_script := load("res://scripts/level2/ambient/harbor_ambient_sway.gd")
	if sway_script != null:
		mast.set_script(sway_script)
		mast.set("max_angle_deg", 3.5)
		mast.set("phase_offset", bob_phase * 0.7)

	# Attach bob to the whole boat container (Node2D — compatible)
	var bob_script := load("res://scripts/level2/ambient/harbor_ambient_bob.gd")
	if bob_script != null:
		container.set_script(bob_script)
		container.set("amplitude", 2.8)
		container.set("period", 2.8)
		container.set("phase_offset", bob_phase)


# ── Layer 5: Foreground Pier + Ground ─────────────────────────────────────

func _build_pier_foreground() -> void:
	# Main pier stone ground
	var pier := ColorRect.new()
	pier.name = "PierGround"
	pier.color = PIER_STONE
	pier.size = Vector2(VIEW_W, VIEW_H - CURB_Y)
	pier.position = Vector2(0.0, CURB_Y)
	foreground_layer.add_child(pier)

	# Edge darker strip
	var edge := ColorRect.new()
	edge.color = PIER_EDGE
	edge.size = Vector2(VIEW_W, 8.0)
	edge.position = Vector2(0.0, CURB_Y)
	foreground_layer.add_child(edge)

	# Stone texture suggestion (horizontal lines)
	for i in 4:
		var line := ColorRect.new()
		line.color = Color(0.0, 0.0, 0.0, 0.06)
		line.size = Vector2(VIEW_W, 2.0)
		line.position = Vector2(0.0, CURB_Y + 30.0 + i * 30.0)
		foreground_layer.add_child(line)

	# Water visible below pier edge (near side of sea)
	var near_water := ColorRect.new()
	near_water.color = SEA_SHALLOW
	near_water.size = Vector2(VIEW_W, 30.0)
	near_water.position = Vector2(0.0, CURB_Y - 28.0)
	near_water.modulate.a = 0.45
	foreground_layer.add_child(near_water)

	_annotate(foreground_layer, "⬆ L5 رصيف المرسى — Pier Foreground", Vector2(8.0, CURB_Y + 4.0))


# ── Ambient Life ─────────────────────────────────────────────────────────

func _build_ambient_life() -> void:
	# 2 seagulls
	var gull_script := load("res://scripts/level2/ambient/seagull_loop.gd")
	if gull_script != null:
		var g1 := Node2D.new()
		g1.name = "Seagull1"
		g1.set_script(gull_script)
		g1.set("flight_y", 105.0)
		g1.set("speed", 65.0)
		g1.set("from_right", false)
		g1.set("wing_beat_hz", 1.3)
		ambient_layer.add_child(g1)

		var g2 := Node2D.new()
		g2.name = "Seagull2"
		g2.set_script(gull_script)
		g2.set("flight_y", 145.0)
		g2.set("speed", 82.0)
		g2.set("from_right", true)
		g2.set("wing_beat_hz", 1.6)
		ambient_layer.add_child(g2)

	# Distant fisherman silhouette (tiny colored dot near breakwater)
	var fisherman := Polygon2D.new()
	fisherman.name = "DistantFisherman"
	fisherman.color = Color(0.18, 0.14, 0.10, 0.75)
	fisherman.polygon = PackedVector2Array([
		Vector2(-4, 0), Vector2(4, 0), Vector2(3, -14), Vector2(-3, -14),
	])
	fisherman.position = Vector2(460.0, 342.0)
	ambient_layer.add_child(fisherman)

	# Fishing rod
	var rod := Line2D.new()
	rod.default_color = Color(0.35, 0.28, 0.18, 0.65)
	rod.width = 1.5
	rod.points = PackedVector2Array([Vector2(460.0, 328.0), Vector2(490.0, 310.0)])
	ambient_layer.add_child(rod)

	# Sea shimmer (pulsing alpha color strip)
	var shimmer := ColorRect.new()
	shimmer.name = "SeaShimmerAmbient"
	shimmer.color = Color(0.75, 0.90, 1.00, 0.09)
	shimmer.size = Vector2(VIEW_W, 22.0)
	shimmer.position = Vector2(0.0, 355.0)
	ambient_layer.add_child(shimmer)

	# Animate the shimmer alpha
	var t := shimmer.create_tween()
	t.set_loops()
	t.tween_property(shimmer, "modulate:a", 2.2, 3.0).set_trans(Tween.TRANS_SINE)
	t.tween_property(shimmer, "modulate:a", 0.6, 3.0).set_trans(Tween.TRANS_SINE)

	# Rope / flag wind sway near pier
	var rope := Polygon2D.new()
	rope.name = "RopeSway"
	rope.color = Color(0.48, 0.40, 0.28, 0.90)
	rope.polygon = PackedVector2Array([
		Vector2(-1.5, 0), Vector2(1.5, 0), Vector2(2.5, 32.0), Vector2(-2.5, 32.0),
	])
	rope.position = Vector2(820.0, CURB_Y - 40.0)
	ambient_layer.add_child(rope)

	var sway_s := load("res://scripts/level2/ambient/harbor_ambient_sway.gd")
	if sway_s != null:
		rope.set_script(sway_s)
		rope.set("max_angle_deg", 5.0)
		rope.set("period", 2.1)

	# Wooden post under rope
	var post := ColorRect.new()
	post.color = Color(0.38, 0.30, 0.20, 1.0)
	post.size = Vector2(6.0, 44.0)
	post.position = Vector2(817.0, CURB_Y - 42.0)
	ambient_layer.add_child(post)


# ── Jomana Placeholder ────────────────────────────────────────────────────

func _build_jomana() -> void:
	var container := Node2D.new()
	container.name = "JomanaPlaceholder"
	container.position = Vector2(220.0, 0.0)
	gameplay_layer.add_child(container)

	# Body (dress: teal rectangle)
	var body := Polygon2D.new()
	body.name = "JomanaBody"
	body.color = JOMANA_COLOR
	# Simple runner silhouette: head + body + legs (pixel-art-inspired)
	body.polygon = PackedVector2Array([
		# body+dress
		Vector2(-11, -72), Vector2(11, -72),
		Vector2(14, -30),  Vector2(-14, -30),
	])
	body.position = Vector2(0.0, ROAD_Y - 24.0)
	container.add_child(body)

	# Head circle approximation
	var head := Polygon2D.new()
	head.name = "JomanaHead"
	head.color = Color(0.88, 0.70, 0.52, 1.0)  # warm skin tone
	var hp := PackedVector2Array()
	for i in 10:
		var a := i * TAU / 10.0
		hp.append(Vector2(cos(a) * 10.0, sin(a) * 10.0))
	head.polygon = hp
	head.position = Vector2(0.0, ROAD_Y - 88.0)
	container.add_child(head)

	# Hijab / hair layer
	var hijab := Polygon2D.new()
	hijab.color = Color(0.22, 0.40, 0.30, 1.0)  # dark green
	var hpts := PackedVector2Array()
	for i in 8:
		var a := i * PI / 7.0 + PI * 0.1
		hpts.append(Vector2(cos(a) * 12.0, sin(a) * 12.0))
	hpts.append(Vector2(-12.0, 4.0))
	hijab.polygon = hpts
	hijab.position = Vector2(0.0, ROAD_Y - 90.0)
	container.add_child(hijab)

	# Legs
	for side in [-1, 1]:
		var leg := ColorRect.new()
		leg.color = Color(0.20, 0.52, 0.40, 1.0)
		leg.size = Vector2(8.0, 26.0)
		leg.position = Vector2(side * 4.0 - 4.0, ROAD_Y - 28.0)
		container.add_child(leg)

	# Name label
	var label := Label.new()
	label.name = "JomanaLabel"
	label.text = "جمانة"
	label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.90, 1.0))
	label.add_theme_constant_override("outline_size", 3)
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.6))
	label.add_theme_font_size_override("font_size", 13)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-22.0, ROAD_Y - 110.0)
	label.size = Vector2(44.0, 20.0)
	label.set("text_direction", TextServer.DIRECTION_RTL)
	container.add_child(label)

	# Foot alignment marker (thin line at ROAD_Y)
	var foot := ColorRect.new()
	foot.color = Color(1.0, 1.0, 0.4, 0.55)
	foot.size = Vector2(32.0, 2.0)
	foot.position = Vector2(-16.0, ROAD_Y - 24.0)
	container.add_child(foot)


# ── Obstacle Placeholders ─────────────────────────────────────────────────

func _build_obstacles() -> void:
	# Low concrete block (170px into lane)
	_add_obstacle_block(gameplay_layer, Vector2(500.0, ROAD_Y - 24.0), 46.0, 28.0, "حاجز خرساني")
	# Crate stack (double-height)
	_add_obstacle_block(gameplay_layer, Vector2(740.0, ROAD_Y - 40.0), 40.0, 44.0, "صناديق")
	# Fishing net bundle (wide, low)
	_add_obstacle_block(gameplay_layer, Vector2(960.0, ROAD_Y - 18.0), 62.0, 20.0, "شبكة صيد")


func _add_obstacle_block(parent: Node2D, pos: Vector2, w: float, h: float, label_text: String) -> void:
	var container := Node2D.new()
	container.position = pos
	parent.add_child(container)

	var block := ColorRect.new()
	block.color = OBSTACLE_COLOR
	block.size = Vector2(w, h)
	block.position = Vector2(-w / 2.0, -h)
	container.add_child(block)

	# Top highlight
	var top := ColorRect.new()
	top.color = Color(OBSTACLE_COLOR.r + 0.12, OBSTACLE_COLOR.g + 0.10, OBSTACLE_COLOR.b + 0.08, 1.0)
	top.size = Vector2(w, 5.0)
	top.position = Vector2(-w / 2.0, -h)
	container.add_child(top)

	var lbl := Label.new()
	lbl.text = label_text
	lbl.add_theme_font_size_override("font_size", 9)
	lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.75))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.size = Vector2(w + 10.0, 14.0)
	lbl.position = Vector2(-w / 2.0 - 5.0, -h - 15.0)
	lbl.set("text_direction", TextServer.DIRECTION_RTL)
	container.add_child(lbl)


# ── Collectible Arc ───────────────────────────────────────────────────────

func _build_collectibles() -> void:
	# Arc of 5 أثر gems above a mid-point obstacle
	var arc_center_x := 620.0
	var count := 5
	for i in count:
		var t := float(i) / float(count - 1)
		var x := arc_center_x - 80.0 + t * 160.0
		var arc_y := ROAD_Y - 120.0 - sin(t * PI) * 50.0
		_add_collectible(gameplay_layer, Vector2(x, arc_y), i)

	# Single road-level gem (reward line style)
	for i in 3:
		_add_collectible(gameplay_layer, Vector2(820.0 + i * 60.0, ROAD_Y - 55.0), i)


func _add_collectible(parent: Node2D, pos: Vector2, idx: int) -> void:
	var gem := Polygon2D.new()
	gem.name = "Collectible_%d" % idx
	# Diamond / crystal shape
	gem.color = COLLECTIBLE_COLOR
	gem.polygon = PackedVector2Array([
		Vector2(0, -10), Vector2(7, 0), Vector2(0, 12), Vector2(-7, 0),
	])
	gem.position = pos
	parent.add_child(gem)

	# Gentle pulse
	var pulse := gem.create_tween()
	pulse.set_loops()
	pulse.tween_property(gem, "scale", Vector2(1.15, 1.15), 0.55) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT) \
		.set_delay(idx * 0.12)
	pulse.tween_property(gem, "scale", Vector2.ONE, 0.55) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Glow halo
	var glow := Polygon2D.new()
	glow.color = COLLECTIBLE_GLOW
	glow.polygon = PackedVector2Array([
		Vector2(0, -14), Vector2(9, 0), Vector2(0, 16), Vector2(-9, 0),
	])
	glow.position = pos
	glow.z_index = -1
	parent.add_child(glow)


# ── UI Overlay ────────────────────────────────────────────────────────────

func _build_ui_overlay() -> void:
	# LookDev title banner
	var title := Label.new()
	title.name = "LookDevTitle"
	title.text = "LOOKDEV — جمانة وأثر الكلمة — مرسى زليتن"
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(1.0, 0.92, 0.55, 0.90))
	title.add_theme_constant_override("outline_size", 2)
	title.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	title.position = Vector2(8.0, 6.0)
	title.set("text_direction", TextServer.DIRECTION_RTL)
	ui_layer.add_child(title)

	# Layer legend
	var legend_texts := [
		"L1 السماء", "L2 البحر", "L3 المباني", "L4 القوارب", "L5 الرصيف"
	]
	var legend_colors := [SKY_TOP, SEA_DEEP, HARBOR_BLDG, BOAT_HULL, PIER_STONE]
	for i in legend_texts.size():
		var dot := ColorRect.new()
		dot.color = legend_colors[i]
		dot.size = Vector2(10.0, 10.0)
		dot.position = Vector2(8.0, 35.0 + i * 18.0)
		ui_layer.add_child(dot)
		var lbl := Label.new()
		lbl.text = legend_texts[i]
		lbl.add_theme_font_size_override("font_size", 10)
		lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
		lbl.position = Vector2(22.0, 32.0 + i * 18.0)
		ui_layer.add_child(lbl)

	# Family checkpoint plan (right side of screen)
	var cp_data := [
		["15 أثر", "علي", Color(0.55, 0.88, 0.65, 1.0)],
		["35 أثر", "فاطمة", Color(1.0, 0.75, 0.40, 1.0)],
		["60 أثر", "زينب", Color(0.80, 0.45, 0.90, 1.0)],
		["90 أثر", "الأب", Color(0.55, 0.78, 1.0, 1.0)],
	]
	var cp_header := Label.new()
	cp_header.text = "نقاط العائلة"
	cp_header.add_theme_font_size_override("font_size", 10)
	cp_header.add_theme_color_override("font_color", Color(1, 0.92, 0.55, 0.9))
	cp_header.position = Vector2(VIEW_W - 115.0, 30.0)
	cp_header.set("text_direction", TextServer.DIRECTION_RTL)
	ui_layer.add_child(cp_header)
	for i: int in cp_data.size():
		var row: Array = cp_data[i]
		var dot2 := ColorRect.new()
		dot2.color = row[2] as Color
		dot2.size = Vector2(8.0, 8.0)
		dot2.position = Vector2(VIEW_W - 118.0, 48.0 + i * 18.0)
		ui_layer.add_child(dot2)
		var rl := Label.new()
		rl.text = "%s ← %s" % [row[1] as String, row[0] as String]
		rl.add_theme_font_size_override("font_size", 10)
		rl.add_theme_color_override("font_color", Color(1, 1, 1, 0.82))
		rl.position = Vector2(VIEW_W - 110.0, 45.0 + i * 18.0)
		ui_layer.add_child(rl)

	# Camera mode indicator
	var cam_label := Label.new()
	cam_label.name = "CamModeLabel"
	cam_label.text = "📷 Establishing reveal → Gameplay → Checkpoint focus"
	cam_label.add_theme_font_size_override("font_size", 10)
	cam_label.add_theme_color_override("font_color", Color(0.7, 1.0, 0.8, 0.80))
	cam_label.position = Vector2(8.0, VIEW_H - 22.0)
	ui_layer.add_child(cam_label)


# ── Utility: layer annotation ─────────────────────────────────────────────

func _annotate(parent: Node2D, text: String, pos: Vector2) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 9)
	lbl.add_theme_color_override("font_color", Color(1.0, 1.0, 0.3, 0.55))
	lbl.position = pos
	parent.add_child(lbl)
