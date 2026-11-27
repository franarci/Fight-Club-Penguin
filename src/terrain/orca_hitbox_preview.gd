@tool
extends Node2D

@export_range(0.0, 400.0, 1.0) var half_length := 0.0:
	set(value):
		half_length = maxf(value, 0.0)
		queue_redraw()

@export_range(0.0, 240.0, 1.0) var half_width := 0.0:
	set(value):
		half_width = maxf(value, 0.0)
		queue_redraw()


func _draw() -> void:
	if not Engine.is_editor_hint() and not get_parent().get("show_hitbox_in_gameplay"):
		return
	if half_length <= 0.0 or half_width <= 0.0:
		return
	var points := PackedVector2Array()
	const SEGMENTS := 64
	for index in range(SEGMENTS):
		var angle := TAU * float(index) / float(SEGMENTS)
		points.append(Vector2(cos(angle) * half_length, sin(angle) * half_width))
	draw_colored_polygon(points, Color(1.0, 0.12, 0.12, 0.16))
	for index in range(points.size()):
		draw_line(points[index], points[(index + 1) % points.size()], Color(1.0, 0.2, 0.12, 0.95), 3.0, true)
	draw_line(Vector2(-8.0, 0.0), Vector2(8.0, 0.0), Color(1.0, 0.2, 0.12, 0.95), 2.0, true)
	draw_line(Vector2(0.0, -8.0), Vector2(0.0, 8.0), Color(1.0, 0.2, 0.12, 0.95), 2.0, true)
