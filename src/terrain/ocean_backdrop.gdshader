shader_type canvas_item;
render_mode unshaded;

uniform vec2 world_dimensions = vec2(2035.0, 1228.8);
uniform vec2 arena_dimensions = vec2(1843.2, 1036.8);
uniform float background_margin = 96.0;
uniform sampler2D source_texture : source_color;

void fragment() {
	vec2 world_position = UV * world_dimensions - vec2(background_margin);
	vec2 source_uv = clamp(world_position / arena_dimensions, vec2(0.0), vec2(1.0));
	vec3 water = texture(source_texture, source_uv).rgb;
	float swell = sin(world_position.y * 0.035 + sin(world_position.x * 0.006 + TIME * 0.18) * 1.8 + TIME * 0.7);
	float ripple = sin(world_position.y * 0.14 + world_position.x * 0.025 - TIME * 1.1);
	float glint = smoothstep(0.93, 1.0, ripple) * (0.5 + 0.5 * sin(world_position.x * 0.08));
	vec3 subtle_motion = water * (0.985 + swell * 0.012) + vec3(0.004, 0.012, 0.02) * glint;
	COLOR = vec4(subtle_motion, 1.0);
}
