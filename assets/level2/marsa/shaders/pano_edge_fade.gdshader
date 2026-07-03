// pano_edge_fade.gdshader
// Fades the panorama sprite at left, right, and top edges.
// Left+right fades: when two copies overlap at the join, their fading edges
// blend together so the seam between copy A and copy B disappears.
// Top fade: blends panorama top into the sky layer above.
shader_type canvas_item;

uniform float fade_left  : hint_range(0.0, 300.0) = 140.0;
uniform float fade_right : hint_range(0.0, 300.0) = 140.0;
uniform float fade_top   : hint_range(0.0, 120.0) = 45.0;

void fragment() {
	vec4 col  = texture(TEXTURE, UV);
	float w   = 1.0 / TEXTURE_PIXEL_SIZE.x;
	float h   = 1.0 / TEXTURE_PIXEL_SIZE.y;
	float x   = UV.x * w;
	float y   = UV.y * h;

	float a_l = clamp(x              / max(fade_left,  1.0), 0.0, 1.0);
	float a_r = clamp((w - x)        / max(fade_right, 1.0), 0.0, 1.0);
	float a_t = clamp(y              / max(fade_top,   1.0), 0.0, 1.0);

	// Combine: left and right multiply so they both must be full for center to be opaque.
	// Top fade stacked on top of that.
	COLOR = vec4(col.rgb, col.a * a_l * a_r * a_t);
}
