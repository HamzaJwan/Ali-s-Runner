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
	button.text = "⛶"
	button.tooltip_text = "ملء الشاشة"
	button.custom_minimum_size = Vector2(48.0, 48.0)
	button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	button.anchor_left = 1.0
	button.anchor_right = 1.0
	button.offset_left = -56.0
	button.offset_top = 8.0
	button.offset_right = -8.0
	button.offset_bottom = 56.0
	button.add_theme_font_size_override("font_size", 24)

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
	button.pressed.connect(_toggle_fullscreen)
	add_child(button)


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
