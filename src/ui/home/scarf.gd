extends Node2D

var phase := 0.0


func _process(delta: float) -> void:
	phase = fmod(phase + delta * 3.0, TAU)
	queue_redraw()


func _draw() -> void:
	_draw_ribbon(78.0, 0.0, 0.0, Color("ca173b"))
	_draw_ribbon(65.0, 6.0, 1.3, Color("ef294a"))


func _draw_ribbon(length: float, base_y: float, offset: float, color: Color) -> void:
	var upper := PackedVector2Array()
	var lower := PackedVector2Array()
	for index in range(13):
		var progress := float(index) / 12.0
		var x := progress * length
		var y := base_y + sin(phase - progress * 6.0 + offset) * 4.0 * progress - progress * 5.0
		var half_width := lerpf(3.5, 1.2, progress)
		upper.append(Vector2(roundf(x), roundf(y - half_width)))
		lower.append(Vector2(roundf(x), roundf(y + half_width)))
	lower.reverse()
	upper.append_array(lower)
	draw_colored_polygon(upper, color)
	upper.append(upper[0])
	draw_polyline(upper, Color("8f1632"), 1.0)
