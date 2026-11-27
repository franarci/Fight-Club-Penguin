shader_type canvas_item;
render_mode unshaded;

uniform vec2 world_dimensions = vec2(2035.0, 1228.8);
uniform vec2 arena_dimensions = vec2(1843.2, 1036.8);
uniform float background_margin = 96.0;
uniform sampler2D source_texture : source_color;

void fragment() {
	vec2 world_position = UV * world_dimensions - vec2(background_margin);
	vec2 raw_source_uv = world_position / arena_dimensions;
	// The source image has no ocean outside its rectangle; use it only for a soft seam.
	vec2 source_uv = clamp(raw_source_uv, vec2(0.0025), vec2(0.9975));
	vec3 edge_water = texture(source_texture, source_uv).rgb;
	float outside_distance = max(
		max(max(-world_position.x, world_position.x - arena_dimensions.x), max(-world_position.y, world_position.y - arena_dimensions.y)),
		0.0
	);
	float extension_blend = smoothstep(0.0, max(background_margin * 0.45, 64.0), outside_distance);
	// Mirror a water-only crop from the source image to avoid stretching its border pixels.
	vec2 tile_phase = world_position / vec2(460.0, 320.0);
	vec2 tile_uv = abs(fract(tile_phase * 0.5) * 2.0 - 1.0);
	vec2 water_patch_uv = vec2(0.025, 0.025) + tile_uv * vec2(0.17, 0.17);
	vec3 extended_water = texture(source_texture, water_patch_uv).rgb;
	vec3 water = mix(edge_water, extended_water, extension_blend);
	float swell = sin(world_position.y * 0.035 + sin(world_position.x * 0.006 + TIME * 0.18) * 1.8 + TIME * 0.7);
	float ripple = sin(world_position.y * 0.14 + world_position.x * 0.025 - TIME * 1.1);
	float glint = smoothstep(0.93, 1.0, ripple) * (0.5 + 0.5 * sin(world_position.x * 0.08));
	vec3 subtle_motion = water * (0.985 + swell * 0.012) + vec3(0.004, 0.012, 0.02) * glint;
	COLOR = vec4(subtle_motion, 1.0);
}
