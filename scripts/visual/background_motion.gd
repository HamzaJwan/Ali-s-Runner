class_name BackgroundMotion
extends RefCounted

var _view_width := 1152.0
var _layers: Array[Dictionary] = []


func setup(view_width: float) -> void:
	_view_width = view_width


func add_layer(sprite: Sprite2D, speed_factor: float) -> bool:
	if sprite == null or sprite.texture == null:
		print("[parallax] layer ", sprite.name if sprite != null else "?",
			" skipped (no texture)")
		return false

	var duplicate := Sprite2D.new()
	duplicate.texture = sprite.texture
	duplicate.centered = sprite.centered
	duplicate.scale = sprite.scale
	duplicate.modulate = sprite.modulate
	duplicate.z_index = sprite.z_index
	duplicate.z_as_relative = sprite.z_as_relative
	sprite.get_parent().add_child(duplicate)
	duplicate.global_position = sprite.global_position + Vector2(_view_width, 0.0)

	_layers.append({"a": sprite, "b": duplicate, "speed": speed_factor})
	print("[parallax] layer ", sprite.name, " ready, speed_factor=", speed_factor)
	return true


func update(delta: float, obstacle_speed: float) -> void:
	for layer: Dictionary in _layers:
		var move := obstacle_speed * float(layer["speed"]) * delta
		var sprite_a: Sprite2D = layer["a"]
		var sprite_b: Sprite2D = layer["b"]
		sprite_a.global_position.x -= move
		sprite_b.global_position.x -= move
		if sprite_a.global_position.x + _view_width <= 0.0:
			sprite_a.global_position.x = sprite_b.global_position.x + _view_width
		if sprite_b.global_position.x + _view_width <= 0.0:
			sprite_b.global_position.x = sprite_a.global_position.x + _view_width


func has_layers() -> bool:
	return not _layers.is_empty()
