extends Control


func _ready() -> void:
	resized.connect(queue_redraw)


func _draw() -> void:
	var center := size * 0.5
	var ink := Color("90adc4")
	var outline := PackedVector2Array([
		Vector2(-28, -14), Vector2(-39, -7), Vector2(-46, 23),
		Vector2(-39, 29), Vector2(-27, 18), Vector2(27, 18),
		Vector2(39, 29), Vector2(46, 23), Vector2(39, -7),
		Vector2(28, -14), Vector2(-28, -14)
	])
	for index in range(outline.size()):
		outline[index] += center
	draw_polyline(outline, ink, 3)
	draw_line(center + Vector2(-29, 1), center + Vector2(-15, 1), ink, 3)
	draw_line(center + Vector2(-22, -6), center + Vector2(-22, 8), ink, 3)
	for point in [Vector2(22, -6), Vector2(29, 1), Vector2(22, 8), Vector2(15, 1)]:
		draw_circle(center + point, 2.5, ink)
