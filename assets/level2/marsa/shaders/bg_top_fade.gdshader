// bg_top_fade.gdshader
// Fades the top N pixels of an opaque RGB background sprite to transparent.
// This blends the top edge of the harbor buildings plate into the sky above,
// eliminating the visible horizontal seam line.
// Apply to the Sprite2D holding bg_harbor_buildings.png.
shader_type canvas_item;

uniform float fade_px : hint_range(0.0, 120.0) = 60.0;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	float tex_h = 1.0 / TEXTURE_PIXEL_SIZE.y;
	float y_px  = UV.y * tex_h;
	float alpha  = clamp(y_px / max(fade_px, 1.0), 0.0, 1.0);
	COLOR = vec4(col.rgb, alpha);
}
