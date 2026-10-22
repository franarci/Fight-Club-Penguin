extends Camera2D

## Maximum close-up. Smaller zoom values show more of the arena.
@export_range(0.1, 4.0) var close_zoom: float = 1.4
## Screen-space room for bodies, indicators, weapons, and the HUD.
@export var screen_padding := Vector2(150, 170)
@export_range(0.1, 20.0) var follow_speed: float = 5.0
@export_range(0.1, 20.0) var zoom_in_speed: float = 2.0

var players: Node2D
var arena_size := Vector2.ZERO


func show_arena(size: Vector2) -> void:
	arena_size = size
	frame_points([Vector2.ZERO, size], 0.0, true)


func follow_players(container: Node2D) -> void:
	players = container
	_update_frame(0.0, true)


func _process(delta: float) -> void:
	if is_instance_valid(players):
		_update_frame(delta, false)
	elif arena_size != Vector2.ZERO:
		show_arena(arena_size)


func _update_frame(delta: float, snap: bool) -> void:
	var points: Array[Vector2] = []
	for character in players.get_children():
		var penguin := character.get_child(0) as Penguin
		if penguin == null or penguin.is_eliminated:
			continue
		# Keep respawn locations framed while a penguin is temporarily dead.
		points.append(penguin.respawn_position if penguin.is_dead else penguin.global_position)
	if not points.is_empty():
		frame_points(points, delta, snap)


func frame_points(points: Array[Vector2], delta: float, snap: bool = false) -> void:
	var bounds := Rect2(points[0], Vector2.ZERO)
	for point in points:
		bounds = bounds.expand(point)
	var viewport_size := get_viewport_rect().size
	var padding := screen_padding.min(viewport_size * 0.35) if is_instance_valid(players) else Vector2.ZERO
	var available := (viewport_size - padding * 2.0).max(Vector2.ONE)
	var extent := bounds.size.max(Vector2.ONE)
	var fit_zoom := minf(available.x / extent.x, available.y / extent.y)
	var target_zoom := minf(close_zoom, fit_zoom)
	var center := bounds.get_center()
	if snap:
		global_position = center
		zoom = Vector2.ONE * target_zoom
	else:
		global_position = global_position.lerp(center, 1.0 - exp(-follow_speed * delta))
		# Zoom out immediately when needed; ease in when players regroup.
		# Account for center lag so smoothing cannot leave a player offscreen.
		var half_extent := (bounds.position - global_position).abs().max((bounds.end - global_position).abs()).max(Vector2.ONE)
		var safe_zoom := minf(available.x / (half_extent.x * 2.0), available.y / (half_extent.y * 2.0))
		var smoothed := lerpf(zoom.x, target_zoom, 1.0 - exp(-zoom_in_speed * delta))
		zoom = Vector2.ONE * minf(smoothed, safe_zoom)
