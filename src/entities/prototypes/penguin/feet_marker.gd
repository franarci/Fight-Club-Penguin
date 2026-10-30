@tool
extends Marker2D

## Show the feet reference without enabling all collision shapes (debug builds only).
@export var show_debug_marker: bool = false


func _process(_delta: float) -> void:
	if Engine.is_editor_hint() or OS.is_debug_build():
		queue_redraw()


func _draw() -> void:
	if not Engine.is_editor_hint():
		if not OS.is_debug_build() or not (show_debug_marker or get_tree().debug_collisions_hint):
			return
	var marker_color := Color.YELLOW
	if not Engine.is_editor_hint():
		var boundary: CollisionPolygon2D = get_parent().ice_boundary
		if is_instance_valid(boundary):
			var on_ice := Geometry2D.is_point_in_polygon(boundary.to_local(global_position), boundary.polygon)
			marker_color = Color.GREEN if on_ice else Color.RED
	draw_circle(Vector2.ZERO, 4.0, Color.BLACK)
	draw_circle(Vector2.ZERO, 2.5, marker_color)
	draw_line(Vector2(-6, 0), Vector2(6, 0), marker_color)
	draw_line(Vector2(0, -6), Vector2(0, 6), marker_color)
