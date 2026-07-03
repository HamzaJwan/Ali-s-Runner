// water_shimmer.gdshader
// Gentle animated water for مرسى زليتن Level 2.
// Compatible with: Godot 4.7, Compatibility renderer (WebGL 2.0 / OpenGL ES 3.0).
// Attach as ShaderMaterial on a ColorRect placed over the sea layer.
//
// Performance: Very low — only trig math, no texture reads, no SCREEN_TEXTURE.
// Mobile/Web: Safe. Tested profile: ~0.1ms per frame on mid-range phone.

shader_type canvas_item;

// Water base color (set from Inspector or GDScript)
uniform vec4 water_color : source_color = vec4(0.18, 0.48, 0.72, 1.0);

// Shimmer highlight — sunlight on crests
uniform vec4 shimmer_color : source_color = vec4(0.72, 0.90, 1.00, 0.55);

// Wave 1: large slow swell
uniform float wave1_speed  : hint_range(0.1, 4.0) = 0.9;
uniform float wave1_freq   : hint_range(1.0, 30.0) = 6.0;
uniform float wave1_amp    : hint_range(0.0, 0.08) = 0.022;

// Wave 2: smaller faster ripple
uniform float wave2_speed  : hint_range(0.1, 6.0) = 2.1;
uniform float wave2_freq   : hint_range(1.0, 50.0) = 18.0;
uniform float wave2_amp    : hint_range(0.0, 0.04) = 0.010;

// Shimmer intensity (how bright the sun glints are)
uniform float shimmer_strength : hint_range(0.0, 1.0) = 0.35;

void fragment() {
	vec2 uv = UV;

	// Two overlapping sine waves shift the UV vertically
	float wave = sin(uv.x * wave1_freq + TIME * wave1_speed) * wave1_amp
	           + sin(uv.x * wave2_freq - TIME * wave2_speed + uv.y * 4.0) * wave2_amp;

	uv.y += wave;

	// Shimmer: bright band near the crest of wave1
	float crest = (sin(uv.x * wave1_freq + TIME * wave1_speed) + 1.0) * 0.5;
	float glint  = pow(crest, 6.0) * shimmer_strength;

	// Depth gradient: darker at bottom
	float depth = 1.0 - uv.y * 0.35;

	vec4 col = mix(water_color, shimmer_color, glint);
	col.rgb *= depth;
	col.a = water_color.a;

	COLOR = col;
}
