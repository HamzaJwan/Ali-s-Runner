## mobile_rotate_overlay.gd — "Please rotate to landscape" gate for mobile players.
##
## Registered as an autoload so it works in EVERY scene with zero per-scene setup.
## On desktop/editor it stays invisible. On a phone in portrait it covers the screen
## and pauses the game tree until the user rotates back to landscape.
##
## Autoload entry in project.godot:
##   MobileRotateOverlay = "*res://scripts/ui/mobile_rotate_overlay.gd"
extends CanvasLayer

## Set false to disable globally (e.g. for a headless CI run or specific build).
const ENABLE := true

## How often we re-check viewport size (seconds). 0.25 is fast enough to feel instant.
const CHECK_INTERVAL := 0.25

var _panel: Control   = null
var _check_timer: float = 0.0
var _we_paused: bool = false     # true only when WE issued get_tree().paused = true
var _is_mobile_runtime := false


func _ready() -> void:
	layer = 100                              # render above every CanvasLayer in the game
	process_mode = Node.PROCESS_MODE_ALWAYS  # keep running even when game tree is paused
	_is_mobile_runtime = _detect_mobile_runtime()
	_build_overlay()
	_check_orientation()                     # evaluate immediately on scene load


func _process(delta: float) -> void:
	_check_timer += delta
	if _check_timer >= CHECK_INTERVAL:
		_check_timer = 0.0
		_check_orientation()


# ── Orientation logic ─────────────────────────────────────────────────────

func _check_orientation() -> void:
	if not ENABLE:
		_apply(false)
		return
	if not _is_mobile_runtime:
		_apply(false)
		return

	var vp := get_viewport()
	if vp == null:
		return
	var size := vp.get_visible_rect().size
	var w := size.x
	var h := size.y
	if w <= 0.0 or h <= 0.0:
		return

	var is_portrait   := h > w
	_apply(is_portrait)


func _detect_mobile_runtime() -> bool:
	if OS.has_feature("mobile") and not OS.has_feature("web"):
		return true
	if not OS.has_feature("web"):
		return false

	# Window dimensions alone misclassify narrow desktop browser windows as phones.
	# Touch capability is not a safe discriminator: touch-enabled Windows laptops
	# report it too. Android tablets and iPads are already covered by their UA.
	var detected: Variant = JavaScriptBridge.eval("""
		(function () {
			var ua = navigator.userAgent || '';
			return /Android|iPhone|iPad|iPod|Mobile/i.test(ua);
		})()
	""", true)
	return bool(detected)


func _apply(should_block: bool) -> void:
	if _panel == null:
		return
	if _panel.visible == should_block:
		return   # already in the right state — skip tree pause/resume

	_panel.visible = should_block

	if should_block:
		# Pause only if we're not already paused (e.g. checkpoint dialogue).
		if not get_tree().paused:
			get_tree().paused = true
			_we_paused = true
	else:
		# Unpause only if we were the ones who paused.
		if _we_paused:
			get_tree().paused = false
			_we_paused = false


# ── UI construction ───────────────────────────────────────────────────────

func _build_overlay() -> void:
	# Full-screen blocking panel — consumes all mouse/touch so nothing leaks through.
	_panel = Panel.new()
	_panel.name = "MobilePortraitBlock"
	_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.04, 0.08, 0.92)
	_panel.add_theme_stylebox_override("panel", style)
	_panel.visible = false
	add_child(_panel)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.add_child(center)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 24)
	center.add_child(vbox)

	# Phone icon — drawn from two ColorRects (body + arrow)
	_add_phone_icon(vbox)

	# Main Arabic title
	var title := Label.new()
	title.text = "\u200fاقلب الهاتف بالعرض"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(1.0, 0.90, 0.55, 1.0))
	title.add_theme_constant_override("outline_size", 3)
	title.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.8))
	title.set("text_direction", TextServer.DIRECTION_RTL)
	title.set("language", "ar")
	vbox.add_child(title)

	# Subtitle
	var sub := Label.new()
	sub.text = "\u200fاللعبة مصممة للعب بالعرض"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 18)
	sub.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85, 0.9))
	sub.set("text_direction", TextServer.DIRECTION_RTL)
	sub.set("language", "ar")
	vbox.add_child(sub)

	# Small tip
	var tip := Label.new()
	tip.text = "\u200fبعد قلب الهاتف المس الشاشة للمتابعة"
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip.add_theme_font_size_override("font_size", 14)
	tip.add_theme_color_override("font_color", Color(0.6, 0.6, 0.65, 0.8))
	tip.set("text_direction", TextServer.DIRECTION_RTL)
	tip.set("language", "ar")
	vbox.add_child(tip)


func _add_phone_icon(parent: Control) -> void:
	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.layout_direction = Control.LAYOUT_DIRECTION_LTR
	hbox.add_theme_constant_override("separation", 16)
	parent.add_child(hbox)

	# Portrait phone rectangle
	var phone := ColorRect.new()
	phone.color = Color(0.9, 0.85, 0.5, 0.9)
	phone.custom_minimum_size = Vector2(28, 52)
	hbox.add_child(phone)

	# Draw the arrow from shapes so it never depends on a font glyph.
	var arrow := Control.new()
	arrow.custom_minimum_size = Vector2(42, 24)
	hbox.add_child(arrow)

	var arrow_bar := ColorRect.new()
	arrow_bar.color = Color(1.0, 0.85, 0.3, 1.0)
	arrow_bar.position = Vector2(3, 10)
	arrow_bar.size = Vector2(28, 4)
	arrow.add_child(arrow_bar)

	var arrow_head := Polygon2D.new()
	arrow_head.color = Color(1.0, 0.85, 0.3, 1.0)
	arrow_head.position = Vector2(30, 5)
	arrow_head.polygon = PackedVector2Array([Vector2.ZERO, Vector2(10, 7), Vector2(0, 14)])
	arrow.add_child(arrow_head)

	# Landscape phone rectangle
	var phone2 := ColorRect.new()
	phone2.color = Color(0.9, 0.85, 0.5, 0.9)
	phone2.custom_minimum_size = Vector2(52, 28)
	hbox.add_child(phone2)
