extends Control
## Drawn geometry keeps hearts crisp without a font glyph or external texture.

var filled := true:
	set(value):
		filled = value
		queue_redraw()


func _init() -> void:
	custom_minimum_size = Vector2(26, 26)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var points := PackedVector2Array([
		Vector2(13, 23), Vector2(2, 12), Vector2(2, 6), Vector2(6, 2),
		Vector2(10, 2), Vector2(13, 5), Vector2(16, 2), Vector2(20, 2),
		Vector2(24, 6), Vector2(24, 12),
	])
	draw_colored_polygon(points, Color("ff5978") if filled else Color("26354d"))
	var outline := points.duplicate()
	outline.append(points[0])
	draw_polyline(outline, Color("ffb0be") if filled else Color("506078"), 2.0, true)
	if filled:
		draw_line(Vector2(6, 7), Vector2(9, 7), Color("ffe6ed"), 2.0)
