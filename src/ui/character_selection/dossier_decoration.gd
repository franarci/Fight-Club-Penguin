extends Control


func _ready() -> void:
	resized.connect(queue_redraw)


func _draw() -> void:
	var grid_color := Color(0.55, 0.76, 0.93, 0.055)
	for x in range(8, int(size.x) - 8, 16):
		draw_line(Vector2(x, 8), Vector2(x, size.y - 8), grid_color)
	for y in range(8, int(size.y) - 8, 16):
		draw_line(Vector2(8, y), Vector2(size.x - 8, y), grid_color)
	for corner in [Vector2(7, 7), Vector2(size.x - 7, 7), Vector2(7, size.y - 7), size - Vector2(7, 7)]:
		draw_circle(corner, 3, Color("8398aa"))
		draw_line(corner - Vector2(1, 1), corner + Vector2(1, 1), Color("253d55"), 1)
	var clip_center := Vector2(size.x * 0.5, 0)
	draw_rect(Rect2(clip_center - Vector2(22, 7), Vector2(44, 14)), Color("1b3046"))
	draw_rect(Rect2(clip_center - Vector2(20, 6), Vector2(40, 10)), Color("a8bac9"))
	draw_line(clip_center - Vector2(15, 3), clip_center + Vector2(15, -3), Color("d8e8f1"), 2)
	for index in range(3):
		var points := PackedVector2Array()
		for step in range(8):
			points.append(Vector2(10 + step * (size.x - 20) / 7.0, size.y - 18 - index * 9 - sin(step * 1.7 + index) * 7))
		draw_polyline(points, Color(0.6, 0.8, 0.95, 0.09), 1)
