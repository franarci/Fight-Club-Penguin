shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 danger_color : source_color = vec4(0.92, 0.035, 0.06, 1.0);
uniform float fade_width : hint_range(0.1, 0.5) = 0.32;
uniform float edge_opacity : hint_range(0.0, 1.0) = 0.40;
uniform float pulse_speed : hint_range(0.0, 12.0) = 5.0;

void fragment() {
	vec2 edge_distance = min(SCREEN_UV, vec2(1.0) - SCREEN_UV);
	float distance_to_edge = min(edge_distance.x, edge_distance.y);
	float edge = 1.0 - smoothstep(0.005, fade_width, distance_to_edge);
	float pulse = 0.84 + 0.16 * sin(TIME * pulse_speed);
	float alpha = edge * intensity * edge_opacity * pulse;
	COLOR = vec4(danger_color.rgb, danger_color.a * alpha);
}
