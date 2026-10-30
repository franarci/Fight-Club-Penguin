shader_type canvas_item;

uniform float saturation : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 color = COLOR;
	float luminance = dot(color.rgb, vec3(0.299, 0.587, 0.114));
	COLOR = vec4(mix(vec3(luminance), color.rgb, saturation), color.a);
}
