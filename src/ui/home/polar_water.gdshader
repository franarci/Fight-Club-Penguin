shader_type canvas_item;
render_mode unshaded;

void fragment() {
	vec4 original = texture(TEXTURE, UV);
	float blue = smoothstep(0.04, 0.16, original.b - original.r);
	float shade = 1.0 - smoothstep(0.55, 0.72, original.r);
	float sea = smoothstep(0.64, 0.70, UV.y) * blue * shade;
	vec2 wave = vec2(sin(UV.y * 190.0 + TIME * 1.5), cos(UV.x * 85.0 + TIME)) * TEXTURE_PIXEL_SIZE * 0.85;
	COLOR = texture(TEXTURE, UV + wave * sea);
}
