shader_type canvas_item;
uniform bool preserve_original = false;

uniform vec4 source_shadow : source_color = vec4(0.188, 0.231, 0.106, 1.0);
uniform vec4 source_mid : source_color = vec4(0.294, 0.361, 0.157, 1.0);
uniform vec4 source_highlight : source_color = vec4(0.420, 0.482, 0.227, 1.0);
uniform float tolerance : hint_range(0.001, 0.2, 0.001) = 0.065;
uniform float hue_tolerance : hint_range(0.001, 0.2, 0.001) = 0.055;
uniform vec4 player_color : source_color = vec4(0.9, 0.3, 0.2, 1.0);
uniform float shadow_strength : hint_range(0.0, 1.0) = 0.45;
uniform float highlight_strength : hint_range(0.0, 1.0) = 0.25;

varying vec4 sprite_modulate;

void vertex() {
	sprite_modulate = COLOR;
}

float color_distance(vec3 a, vec3 b) {
	vec3 difference = abs(a - b);
	return max(difference.r, max(difference.g, difference.b));
}

vec3 color_proportions(vec3 color) {
	return color / max(color.r + color.g + color.b, 0.0001);
}

void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	float distance_to_palette = min(color_distance(pixel.rgb, source_shadow.rgb),
		min(color_distance(pixel.rgb, source_mid.rgb), color_distance(pixel.rgb, source_highlight.rgb)));
	vec3 proportions = color_proportions(pixel.rgb);
	float hue_distance = min(color_distance(proportions, color_proportions(source_shadow.rgb)),
		min(color_distance(proportions, color_proportions(source_mid.rgb)),
		color_distance(proportions, color_proportions(source_highlight.rgb))));
	if (!preserve_original && distance_to_palette <= tolerance && hue_distance <= hue_tolerance && pixel.a > 0.0) {
		vec3 weights = vec3(0.2126, 0.7152, 0.0722);
		float value = dot(pixel.rgb, weights);
		float middle = dot(source_mid.rgb, weights);
		vec3 shadow = player_color.rgb * (1.0 - shadow_strength);
		vec3 highlight = mix(player_color.rgb, vec3(1.0), highlight_strength);
		if (value <= middle) {
			float blend = clamp((value - dot(source_shadow.rgb, weights)) /
				max(middle - dot(source_shadow.rgb, weights), 0.0001), 0.0, 1.0);
			pixel.rgb = mix(shadow, player_color.rgb, blend);
		} else {
			float blend = clamp((value - middle) /
				max(dot(source_highlight.rgb, weights) - middle, 0.0001), 0.0, 1.0);
			pixel.rgb = mix(player_color.rgb, highlight, blend);
		}
	}
	COLOR = pixel * sprite_modulate;
}
