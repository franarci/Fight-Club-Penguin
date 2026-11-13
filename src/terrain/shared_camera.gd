extends Camera2D

## Maximum close-up. Smaller zoom values show more of the arena.
@export_range(0.1, 4.0) var close_zoom: float = 1.4
## Screen-space room for bodies, indicators, weapons, and the HUD.
@export var screen_padding := Vector2(150, 170)
@export_range(0.1, 20.0) var follow_speed: float = 5.0
@export_range(0.1, 20.0) var zoom_in_speed: float = 2.0
@export_range(0.1, 20.0) var zoom_out_speed: float = 3.0
@export_range(0.0, 3.0) var zoom_in_delay: float = 0.8

var players: Node2D
var round_anchors: Array[Vector2] = []
var zoom_in_wait := 0.0
var arena_size := Vector2.ZERO
var background_margin := 0.0
var shake_strength := 0.0
var shake_duration := 0.0
var shake_time_left := 0.0


func show_arena(size: Vector2, margin: float = 0.0) -> void:
	arena_size = size
	background_margin = maxf(margin, 0.0)
	frame_points([Vector2.ZERO, size], 0.0, true)


func follow_players(container: Node2D) -> void:
	players = container
	round_anchors.clear()
	for character in players.get_children():
		var penguin := character.get_child(0) as Penguin
		if penguin != null:
			round_anchors.append(penguin.respawn_position)
	_update_frame(0.0, true)


func _process(delta: float) -> void:
	if is_instance_valid(players):
		_update_frame(delta, false)
	elif arena_size != Vector2.ZERO:
		show_arena(arena_size, background_margin)
	_update_shake(delta)
	_clamp_view_to_arena()


func request_shake(strength: float, duration: float) -> void:
	shake_strength = maxf(shake_strength, strength)
	shake_duration = maxf(shake_duration, duration)
	shake_time_left = maxf(shake_time_left, duration)


func _update_shake(delta: float) -> void:
	if shake_time_left <= 0.0:
		offset = Vector2.ZERO
		shake_strength = 0.0
		shake_duration = 0.0
		return
	shake_time_left = maxf(shake_time_left - delta, 0.0)
	var fade := shake_time_left / maxf(shake_duration, 0.001)
	offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake_strength * fade
	if shake_time_left == 0.0:
		offset = Vector2.ZERO
		shake_strength = 0.0
		shake_duration = 0.0


func _update_frame(delta: float, snap: bool) -> void:
	var points: Array[Vector2] = round_anchors.duplicate()
	for character in players.get_children():
		var penguin := character.get_child(0) as Penguin
		if penguin == null or penguin.is_eliminated:
			continue
		# Keep respawn locations framed while a penguin is temporarily dead.
		points.append(penguin.respawn_position if penguin.is_dead else penguin.global_position)
	if not points.is_empty():
		frame_points(points, delta, snap)


func frame_points(points: Array[Vector2], delta: float, snap: bool = false) -> void:
	if points.is_empty():
		return
	var bounds := Rect2(points[0], Vector2.ZERO)
	for point in points:
		bounds = bounds.expand(point)
	var viewport_size := get_viewport_rect().size
	var padding := screen_padding.min(viewport_size * 0.35) if is_instance_valid(players) else Vector2.ZERO
	var available := (viewport_size - padding * 2.0).max(Vector2.ONE)
	var extent := bounds.size.max(Vector2.ONE)
	var fit_zoom := minf(available.x / extent.x, available.y / extent.y)
	var target_zoom := minf(close_zoom, fit_zoom)
	var minimum_zoom := 0.0
	if arena_size.x > 0.0 and arena_size.y > 0.0:
		var background_size := arena_size + Vector2.ONE * background_margin * 2.0
		minimum_zoom = maxf(viewport_size.x / background_size.x, viewport_size.y / background_size.y) * 1.001
		target_zoom = maxf(target_zoom, minimum_zoom)
	var center := bounds.get_center()
	if snap:
		global_position = center
		zoom = Vector2.ONE * target_zoom
		zoom_in_wait = zoom_in_delay
	else:
		global_position = global_position.lerp(center, 1.0 - exp(-follow_speed * delta))
		var half_extent := (bounds.position - global_position).abs().max((bounds.end - global_position).abs()).max(Vector2.ONE)
		var safety_padding := Vector2(24, 64).min(viewport_size * 0.15)
		var safety_space := (viewport_size - safety_padding * 2.0).max(Vector2.ONE)
		var safe_zoom := minf(safety_space.x / (half_extent.x * 2.0), safety_space.y / (half_extent.y * 2.0))
		var smoothed := zoom.x
		if target_zoom < zoom.x - 0.005:
			zoom_in_wait = zoom_in_delay
			smoothed = lerpf(zoom.x, target_zoom, 1.0 - exp(-zoom_out_speed * delta))
		else:
			zoom_in_wait = maxf(0.0, zoom_in_wait - delta)
			if zoom_in_wait == 0.0 and target_zoom > zoom.x + 0.005:
				smoothed = lerpf(zoom.x, target_zoom, 1.0 - exp(-zoom_in_speed * delta))
		zoom = Vector2.ONE * maxf(minimum_zoom, minf(smoothed, safe_zoom))
	_clamp_view_to_arena()


func _clamp_view_to_arena() -> void:
	if arena_size.x <= 0.0 or arena_size.y <= 0.0:
		return
	var half_view := get_viewport_rect().size / (zoom * 2.0)
	var start := Vector2.ONE * -background_margin
	var end := arena_size + Vector2.ONE * background_margin
	global_position = Vector2(
		clampf(global_position.x, start.x + half_view.x, end.x - half_view.x),
		clampf(global_position.y, start.y + half_view.y, end.y - half_view.y)
	)
	offset = Vector2(
		clampf(offset.x, start.x + half_view.x - global_position.x, end.x - half_view.x - global_position.x),
		clampf(offset.y, start.y + half_view.y - global_position.y, end.y - half_view.y - global_position.y)
	)
