extends RefCounted


static func load_texture_with_fallback(path: String) -> Texture2D:
	var candidates: Array[String] = [path]
	if path.ends_with(".png"):
		candidates.append(path + ".png")

	for candidate in candidates:
		var exists := ResourceLoader.exists(candidate, &"Texture2D")
		print("[asset] checking ", candidate, " exists=", exists)
		if exists:
			var texture := load(candidate) as Texture2D
			if texture != null:
				print("[asset] loaded ", candidate, " size=", texture.get_size())
				return texture

	print("[asset] missing ", path)
	return null


static func set_sprite_texture_if_exists(sprite: Sprite2D, path: String) -> bool:
	var texture := load_texture_with_fallback(path)
	if texture == null:
		sprite.texture = null
		sprite.visible = false
		return false

	sprite.texture = texture
	sprite.visible = true
	return true


static func fit_sprite_to_width(sprite: Sprite2D, target_width: float) -> void:
	if sprite.texture == null or sprite.texture.get_width() <= 0:
		return

	var uniform_scale := target_width / float(sprite.texture.get_width())
	sprite.scale = Vector2(uniform_scale, uniform_scale)
	print("[asset] applied ", sprite.name, " size=", sprite.texture.get_size(),
		", target_width=", target_width, ", final_scale=", sprite.scale)


static func fit_sprite_visible_to_width(sprite: Sprite2D, target_width: float) -> void:
	var visible_rect := get_texture_visible_rect(sprite.texture)
	if visible_rect.size.x <= 0.0:
		return

	var uniform_scale := target_width / visible_rect.size.x
	sprite.scale = Vector2(uniform_scale, uniform_scale)
	print("[asset] applied ", sprite.name, " visible_bounds=", visible_rect,
		", target_width=", target_width, ", final_scale=", sprite.scale)


static func fit_sprite_to_height(sprite: Sprite2D, target_height: float) -> void:
	if sprite.texture == null or sprite.texture.get_height() <= 0:
		return

	var uniform_scale := target_height / float(sprite.texture.get_height())
	sprite.scale = Vector2(uniform_scale, uniform_scale)
	print("[asset] applied ", sprite.name, " size=", sprite.texture.get_size(),
		", target_height=", target_height, ", final_scale=", sprite.scale)


static func fit_sprite_visible_to_height(sprite: Sprite2D, target_height: float) -> void:
	var visible_rect := get_texture_visible_rect(sprite.texture)
	if visible_rect.size.y <= 0.0:
		return

	var uniform_scale := target_height / visible_rect.size.y
	sprite.scale = Vector2(uniform_scale, uniform_scale)
	print("[asset] applied ", sprite.name, " visible_bounds=", visible_rect,
		", target_height=", target_height, ", final_scale=", sprite.scale)


static func fit_sprite_to_size(
		sprite: Sprite2D, target_width: float, target_height: float
) -> void:
	if sprite.texture == null:
		return
	if sprite.texture.get_width() <= 0 or sprite.texture.get_height() <= 0:
		return

	sprite.scale = Vector2(
		target_width / float(sprite.texture.get_width()),
		target_height / float(sprite.texture.get_height())
	)
	print("[asset] applied ", sprite.name, " size=", sprite.texture.get_size(),
		", target_size=", Vector2(target_width, target_height),
		", final_scale=", sprite.scale)


static func fit_sprite_visible_to_size(
		sprite: Sprite2D, target_width: float, target_height: float
) -> void:
	var visible_rect := get_texture_visible_rect(sprite.texture)
	if visible_rect.size.x <= 0.0 or visible_rect.size.y <= 0.0:
		return

	sprite.scale = Vector2(
		target_width / visible_rect.size.x,
		target_height / visible_rect.size.y
	)
	print("[asset] applied ", sprite.name, " visible_bounds=", visible_rect,
		", target_size=", Vector2(target_width, target_height),
		", final_scale=", sprite.scale)


static func align_sprite_visible_bottom(
		sprite: Sprite2D, target_bottom: float, target_center_x: float = 0.0
) -> void:
	var visible_rect := get_texture_visible_rect(sprite.texture)
	var texture_origin := Vector2.ZERO
	if sprite.centered:
		texture_origin = sprite.texture.get_size() / 2.0

	var visible_center_x := visible_rect.position.x + visible_rect.size.x / 2.0
	var visible_bottom := visible_rect.position.y + visible_rect.size.y
	sprite.position = Vector2(
		target_center_x - (visible_center_x - texture_origin.x) * sprite.scale.x,
		target_bottom - (visible_bottom - texture_origin.y) * sprite.scale.y
	)


static func align_sprite_visible_left_bottom(
		sprite: Sprite2D, target_left: float, target_bottom: float
) -> void:
	var visible_rect := get_texture_visible_rect(sprite.texture)
	var texture_origin := Vector2.ZERO
	if sprite.centered:
		texture_origin = sprite.texture.get_size() / 2.0

	var visible_bottom := visible_rect.position.y + visible_rect.size.y
	sprite.position = Vector2(
		target_left - (visible_rect.position.x - texture_origin.x) * sprite.scale.x,
		target_bottom - (visible_bottom - texture_origin.y) * sprite.scale.y
	)


static func align_sprite_visible_top_left(
		sprite: Sprite2D, target_top_left: Vector2
) -> void:
	var visible_rect := get_texture_visible_rect(sprite.texture)
	var texture_origin := Vector2.ZERO
	if sprite.centered:
		texture_origin = sprite.texture.get_size() / 2.0

	sprite.position = target_top_left - (
		visible_rect.position - texture_origin
	) * sprite.scale


static func get_texture_visible_rect(texture: Texture2D) -> Rect2:
	if texture == null:
		return Rect2()

	var image := texture.get_image()
	if image == null or image.is_empty():
		return Rect2(Vector2.ZERO, texture.get_size())

	var used_rect := image.get_used_rect()
	if used_rect.size == Vector2i.ZERO:
		return Rect2(Vector2.ZERO, texture.get_size())

	return Rect2(Vector2(used_rect.position), Vector2(used_rect.size))
