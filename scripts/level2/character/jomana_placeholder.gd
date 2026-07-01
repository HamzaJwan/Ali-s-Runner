## jomana_placeholder.gd
## Standalone placeholder character node for Level 2.
## Attach to JomanaPlaceholder.tscn.
##
## Does NOT extend Player.gd — this is a visual-only decoration node
## for static placement in mockups, cutscenes, or checkpoint moments.
## The actual gameplay runner uses Player.tscn with a teal tint.
extends Node2D

@export var label_text: String = "جمانة"
@export var scale_factor: float = 1.0

const ROAD_Y := 510.0
const JOMANA_COLOR := Color(0.28, 0.72, 0.58, 1.0)
const SKIN_COLOR   := Color(0.85, 0.68, 0.50, 1.0)
const HIJAB_COLOR  := Color(0.22, 0.42, 0.32, 1.0)


func _ready() -> void:
	_build_silhouette()


func _build_silhouette() -> void:
	# Body / dress
	var body := Polygon2D.new()
	body.color = JOMANA_COLOR
	body.polygon = PackedVector2Array([
		Vector2(-12, -68), Vector2(12, -68),
		Vector2(15, -28), Vector2(-15, -28),
	])
	body.position = Vector2(0, ROAD_Y - 24.0)
	body.scale = Vector2(scale_factor, scale_factor)
	add_child(body)

	# Legs
	for side: int in [-1, 1]:
		var leg := ColorRect.new()
		leg.color = JOMANA_COLOR.darkened(0.15)
		leg.size = Vector2(9.0, 24.0)
		leg.position = Vector2(side * 3.0 - 4.5, ROAD_Y - 28.0)
		add_child(leg)

	# Head
	var head := Polygon2D.new()
	head.color = SKIN_COLOR
	var pts := PackedVector2Array()
	for i: int in 10:
		var a := i * TAU / 10.0
		pts.append(Vector2(cos(a) * 10.0, sin(a) * 10.0))
	head.polygon = pts
	head.position = Vector2(0, ROAD_Y - 88.0)
	add_child(head)

	# Hijab
	var hijab := Polygon2D.new()
	hijab.color = HIJAB_COLOR
	var hpts := PackedVector2Array()
	for i: int in 8:
		var a := i * PI / 7.0 + PI * 0.08
		hpts.append(Vector2(cos(a) * 12.0, sin(a) * 12.0))
	hpts.append(Vector2(-12.0, 5.0))
	hijab.polygon = hpts
	hijab.position = Vector2(0, ROAD_Y - 90.0)
	add_child(hijab)

	# Name label
	var lbl := Label.new()
	lbl.text = label_text
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.88))
	lbl.add_theme_constant_override("outline_size", 2)
	lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.size = Vector2(44.0, 16.0)
	lbl.position = Vector2(-22.0, ROAD_Y - 108.0)
	lbl.set("text_direction", TextServer.DIRECTION_RTL)
	add_child(lbl)

	# Foot alignment marker (thin gold line)
	var foot := ColorRect.new()
	foot.color = Color(1.0, 0.92, 0.38, 0.45)
	foot.size = Vector2(34.0, 2.0)
	foot.position = Vector2(-17.0, ROAD_Y - 24.0)
	add_child(foot)
