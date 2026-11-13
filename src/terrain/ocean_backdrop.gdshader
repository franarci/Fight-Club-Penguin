shader_type canvas_item;
render_mode unshaded;

uniform vec2 world_dimensions = vec2(4900.0, 4100.0);

void fragment() {
	vec2 position = UV * world_dimensions;
	float swell = sin(position.y * 0.035 + sin(position.x * 0.006 + TIME * 0.18) * 1.8 + TIME * 0.7);
	float ripple = sin(position.y * 0.14 + position.x * 0.025 - TIME * 1.1);
	float glint = smoothstep(0.93, 1.0, ripple) * (0.5 + 0.5 * sin(position.x * 0.08));
	vec3 deep = vec3(0.055, 0.19, 0.30);
	vec3 water = vec3(0.10, 0.29, 0.43);
	COLOR = vec4(mix(deep, water, swell * 0.25 + 0.5) + vec3(0.04, 0.08, 0.10) * glint, 1.0);
}
