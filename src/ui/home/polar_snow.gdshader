shader_type canvas_item;
render_mode unshaded;

float random(vec2 cell) {
	return fract(sin(dot(cell, vec2(127.1, 311.7))) * 43758.5453);
}

float snowfall(vec2 point, float spacing, float speed, float flake_size) {
	vec2 moving = point + vec2(TIME * speed, -TIME * speed * 0.5);
	vec2 cell = floor(moving / spacing);
	vec2 local = mod(moving, spacing);
	vec2 center = spacing * vec2(0.15 + random(cell) * 0.7, 0.15 + random(cell + 8.7) * 0.7);
	vec2 distance = abs(local - center);
	return (1.0 - step(flake_size, distance.x)) * (1.0 - step(flake_size * 0.65, distance.y));
}

void fragment() {
	vec2 point = floor(FRAGCOORD.xy / 2.0) * 2.0;
	float far_snow = snowfall(point, 74.0, 24.0, 1.7) * 0.4;
	float near_snow = snowfall(point + 215.0, 120.0, 43.0, 3.0) * 0.65;
	COLOR = vec4(0.94, 0.98, 1.0, max(far_snow, near_snow));
}
