extends Node

const FRAME_COLUMNS := 8
const FRAME_ROWS := 8
const FRAME_COUNT := FRAME_COLUMNS * FRAME_ROWS
const FULL_SURFACE_FRAME := 16
const SUBMERGE_START_FRAME := 48
const DIRECTIONS := ["E", "SE", "S", "SO", "O", "NO", "N", "NE"]
const ANGLE_STEP := TAU / 8.0
const FRAME_RATE := 18.0
const EDGE_PADDING := Vector2(56.0, 48.0)
const SOUTH_WALL_CLEARANCE := 64.0
const ORCA_RIPPLE_SCRIPT = preload("res://src/terrain/orca_ripple.gd")

const ORCA_SHEETS := {
	"E": preload("res://assets/textures/entities/orca/orca_E.png"),
	"N": preload("res://assets/textures/entities/orca/orca_N.png"),
	"NE": preload("res://assets/textures/entities/orca/orca_NE.png"),
	"NO": preload("res://assets/textures/entities/orca/orca_NO.png"),
	"O": preload("res://assets/textures/entities/orca/orca_O.png"),
	"S": preload("res://assets/textures/entities/orca/orca_S.png"),
	"SE": preload("res://assets/textures/entities/orca/orca_SE.png"),
	"SO": preload("res://assets/textures/entities/orca/orca_SO.png"),
}

@export_range(4.0, 60.0, 1.0) var minimum_interval := 10.0
@export_range(4.0, 60.0, 1.0) var maximum_interval := 18.0
@export_range(0.0, 160.0, 4.0) var shoreline_offset := 112.0

@onready var arena: Node2D = get_node("../Arena")
@onready var ice_boundary: CollisionPolygon2D = get_node("../Arena/IceArea/Ground")

var _event_timer: Timer
var _sprite_frames: SpriteFrames
var _active_orca: AnimatedSprite2D
var _active_ripples: Array[Node2D] = []
var _events_active := false


func _ready() -> void:
	_event_timer = Timer.new()
	_event_timer.one_shot = true
	_event_timer.timeout.connect(_show_orca)
	add_child(_event_timer)
	_sprite_frames = _make_sprite_frames()


func start_events() -> void:
	if _sprite_frames == null:
		push_warning("No se pudieron cargar las animaciones de la orca.")
		return
	_events_active = true
	_schedule_next()


func stop_events() -> void:
	_events_active = false
	_event_timer.stop()
	if is_instance_valid(_active_orca):
		_active_orca.queue_free()
	_active_orca = null
	for ripple in _active_ripples:
		if is_instance_valid(ripple):
			ripple.queue_free()
	_active_ripples.clear()
	_clear_camera_focus()


func _schedule_next() -> void:
	if not _events_active or is_instance_valid(_active_orca):
		return
	var low := minf(minimum_interval, maximum_interval)
	var high := maxf(minimum_interval, maximum_interval)
	_event_timer.start(randf_range(low, high))


func _show_orca() -> void:
	if not _events_active:
		return
	var outward := Vector2.RIGHT.rotated(randf_range(0.0, TAU))
	var spawn_position := _get_shoreline_position(outward)
	var facing_direction := -outward
	var direction_index := posmod(roundi(facing_direction.angle() / ANGLE_STEP), DIRECTIONS.size())

	_active_orca = AnimatedSprite2D.new()
	_active_orca.sprite_frames = _sprite_frames
	_active_orca.animation = DIRECTIONS[direction_index]
	_active_orca.centered = true
	_active_orca.position = spawn_position
	_active_orca.z_index = -7
	_active_orca.frame_changed.connect(_on_orca_frame_changed.bind(_active_orca))
	_active_orca.animation_finished.connect(_on_orca_animation_finished.bind(_active_orca), CONNECT_ONE_SHOT)
	add_child(_active_orca)
	_active_ripples.append(_create_ripple_half(spawn_position, false, -8))
	_active_ripples.append(_create_ripple_half(spawn_position, true, -6))
	_update_ripple_surface(_get_surface_amount(_active_orca.frame))
	var camera := get_node_or_null("../SharedCamera")
	if camera != null:
		camera.call("set_event_focus", spawn_position)
	_active_orca.play()


func _get_shoreline_position(outward: Vector2) -> Vector2:
	var arena_origin := arena.global_position
	var arena_size: Vector2 = arena.get("world_size")
	var arena_center := arena_origin + arena_size * 0.5
	var boundary_points: Array[Vector2] = []
	for point in ice_boundary.polygon:
		boundary_points.append(ice_boundary.to_global(point))
	var distance_to_shore := _ray_distance_to_polygon(arena_center, outward, boundary_points)
	if distance_to_shore == INF:
		distance_to_shore = minf(arena_size.x, arena_size.y) * 0.35
	var shoreline_point := arena_center + outward * distance_to_shore
	var safe_min := arena_origin + EDGE_PADDING
	var safe_max := arena_origin + arena_size - EDGE_PADDING
	var available_offset := INF
	if outward.x > 0.0001:
		available_offset = minf(available_offset, (safe_max.x - shoreline_point.x) / outward.x)
	elif outward.x < -0.0001:
		available_offset = minf(available_offset, (safe_min.x - shoreline_point.x) / outward.x)
	if outward.y > 0.0001:
		available_offset = minf(available_offset, (safe_max.y - shoreline_point.y) / outward.y)
	elif outward.y < -0.0001:
		available_offset = minf(available_offset, (safe_min.y - shoreline_point.y) / outward.y)
	var perimeter_offset := minf(shoreline_offset, maxf(available_offset, 0.0))
	var south_weight := _smooth_unit(clampf((outward.y - 0.15) / 0.85, 0.0, 1.0))
	var southern_offset := minf(SOUTH_WALL_CLEARANCE * south_weight, maxf(available_offset - perimeter_offset, 0.0))
	perimeter_offset += southern_offset
	return shoreline_point + outward * perimeter_offset


func _ray_distance_to_polygon(origin: Vector2, direction: Vector2, points: Array[Vector2]) -> float:
	var nearest_distance := INF
	for index in range(points.size()):
		var start := points[index]
		var edge := points[(index + 1) % points.size()] - start
		var denominator := direction.cross(edge)
		if absf(denominator) < 0.0001:
			continue
		var offset := start - origin
		var ray_distance := offset.cross(edge) / denominator
		var edge_progress := offset.cross(direction) / denominator
		if ray_distance >= 0.0 and edge_progress >= 0.0 and edge_progress <= 1.0:
			nearest_distance = minf(nearest_distance, ray_distance)
	return nearest_distance


func _create_ripple_half(spawn_position: Vector2, draw_front_half: bool, layer: int) -> Node2D:
	var ripple := ORCA_RIPPLE_SCRIPT.new() as Node2D
	ripple.position = spawn_position
	ripple.z_index = layer
	ripple.set("draw_front_half", draw_front_half)
	add_child(ripple)
	return ripple


func _on_orca_frame_changed(orca: AnimatedSprite2D) -> void:
	if is_instance_valid(orca):
		_update_ripple_surface(_get_surface_amount(orca.frame))


func _get_surface_amount(frame: int) -> float:
	if frame < FULL_SURFACE_FRAME:
		return _smooth_unit(float(frame) / FULL_SURFACE_FRAME)
	if frame < SUBMERGE_START_FRAME:
		return 1.0
	var submerge_length := FRAME_COUNT - 1 - SUBMERGE_START_FRAME
	var submerge_progress := float(frame - SUBMERGE_START_FRAME) / submerge_length
	return 1.0 - _smooth_unit(submerge_progress)


func _smooth_unit(value: float) -> float:
	var clamped_value := clampf(value, 0.0, 1.0)
	return clamped_value * clamped_value * (3.0 - 2.0 * clamped_value)


func _update_ripple_surface(surface_amount: float) -> void:
	for ripple in _active_ripples:
		if is_instance_valid(ripple):
			ripple.call("set_surface_amount", surface_amount)


func _make_sprite_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	for direction in DIRECTIONS:
		var sheet := ORCA_SHEETS[direction] as Texture2D
		if sheet == null:
			return null
		var frame_size := Vector2(sheet.get_width() / FRAME_COLUMNS, sheet.get_height() / FRAME_ROWS)
		frames.add_animation(direction)
		frames.set_animation_speed(direction, FRAME_RATE)
		frames.set_animation_loop(direction, false)
		for index in range(FRAME_COUNT):
			var atlas_frame := AtlasTexture.new()
			atlas_frame.atlas = sheet
			atlas_frame.region = Rect2(
				Vector2((index % FRAME_COLUMNS) * frame_size.x, floori(float(index) / FRAME_COLUMNS) * frame_size.y),
				frame_size
			)
			frames.add_frame(direction, atlas_frame)
	return frames


func _on_orca_animation_finished(orca: AnimatedSprite2D) -> void:
	if is_instance_valid(orca):
		orca.queue_free()
	if _active_orca == orca:
		_active_orca = null
	_update_ripple_surface(0.0)
	for ripple in _active_ripples:
		if is_instance_valid(ripple):
			ripple.call("stop_emitting")
	_active_ripples.clear()
	_clear_camera_focus()
	_schedule_next()


func _clear_camera_focus() -> void:
	var camera := get_node_or_null("../SharedCamera")
	if camera != null:
		camera.call("clear_event_focus")
