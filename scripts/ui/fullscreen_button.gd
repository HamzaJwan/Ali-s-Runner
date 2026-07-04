## Web-only fullscreen toggle shared by every game chapter.
extends CanvasLayer


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not OS.has_feature("web"):
		visible = false
		return

	var button := Button.new()
	button.name = "FSBtn"
	button.text = ""
	button.tooltip_text = "ملء الشاشة"
	button.custom_minimum_size = Vector2(44.0, 44.0)
	button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	button.anchor_left = 1.0
	button.anchor_right = 1.0
	button.offset_left = -52.0
	button.offset_top = 8.0
	button.offset_right = -8.0
	button.offset_bottom = 52.0

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 0.50)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.draw.connect(_draw_fullscreen_icon.bind(button))
	button.pressed.connect(_toggle_fullscreen)
	add_child(button)
	button.queue_redraw()


func _draw_fullscreen_icon(button: Button) -> void:
	# Draw four corner brackets so the icon never depends on font glyph coverage.
	var color := Color(0.95, 0.95, 0.95, 0.95)
	var width := 2.5
	var left := 12.0
	var right := 32.0
	var top := 12.0
	var bottom := 32.0
	var arm := 7.0

	button.draw_line(Vector2(left, top + arm), Vector2(left, top), color, width, true)
	button.draw_line(Vector2(left, top), Vector2(left + arm, top), color, width, true)
	button.draw_line(Vector2(right - arm, top), Vector2(right, top), color, width, true)
	button.draw_line(Vector2(right, top), Vector2(right, top + arm), color, width, true)
	button.draw_line(Vector2(left, bottom - arm), Vector2(left, bottom), color, width, true)
	button.draw_line(Vector2(left, bottom), Vector2(left + arm, bottom), color, width, true)
	button.draw_line(Vector2(right - arm, bottom), Vector2(right, bottom), color, width, true)
	button.draw_line(Vector2(right, bottom), Vector2(right, bottom - arm), color, width, true)


func _toggle_fullscreen() -> void:
	# Browsers accept fullscreen only from a direct user gesture such as this press.
	JavaScriptBridge.eval("""
		(function() {
			var el = document.getElementById('canvas') ||
				document.querySelector('canvas') || document.documentElement;
			if (!document.fullscreenElement && !document.webkitFullscreenElement) {
				var req = el.requestFullscreen || el.webkitRequestFullscreen ||
					el.mozRequestFullScreen || el.msRequestFullscreen;
				if (req) req.call(el);
			} else {
				var exit = document.exitFullscreen || document.webkitExitFullscreen ||
					document.mozCancelFullScreen || document.msExitFullscreen;
				if (exit) exit.call(document);
			}
		})();
	""")
