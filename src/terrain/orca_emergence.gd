extends Node

const FRAME_COLUMNS := 8
const FRAME_ROWS := 8
const FRAME_COUNT := FRAME_COLUMNS * FRAME_ROWS
const FULL_SURFACE_FRAME := 16
const SUBMERGE_START_FRAME := 48
const DIRECTIONS := ["E", "SE", "S", "SO", "O", "NO", "N", "NE"]
const ANGLE_STEP := TAU / 8.0
const FRAME_RATE := 18.0
const SOUTH_WALL_CLEARANCE := 64.0
const ATTACK_VISUAL_PADDING := Vector2(136.0, 120.0)
const ORCA_RIPPLE_SCRIPT = preload("res://src/terrain/orca_ripple.gd")
const ORCA_ATTACK_SCENE = preload("res://src/terrain/OrcaAttack.tscn")
const DANGER_VIGNETTE_SHADER = preload("res://src/terrain/orca_danger_vignette.gdshader")

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
@export_range(20.0, 180.0, 1.0) var minimum_attack_interval := 60.0
@export_range(20.0, 180.0, 1.0) var maximum_attack_interval := 90.0
@export_range(0.0, 240.0, 4.0) var shoreline_offset := 144.0
@export_group("Presentación")
@export_range(0.25, 2.0, 0.05) var orca_scale := 1.0:
	set(value):
		orca_scale = clampf(value, 0.25, 2.0)
		if is_node_ready():
			_apply_scale_settings()

@onready var arena: Node2D = get_node("../Arena")
@onready var ice_boundary: CollisionPolygon2D = get_node("../Arena/IceArea/Ground")
@onready var players: Node2D = get_node("../Players")

var _event_timer: Timer
var _attack_timer: Timer
var _sprite_frames: SpriteFrames
var _active_orca: AnimatedSprite2D
var _active_attack: Node2D
var _danger_overlay: ColorRect
var _danger_material: ShaderMaterial
var _danger_strength := 0.0
var _active_ripples: Array[Node2D] = []
var _last_surface_position := Vector2.ZERO
var _last_attack_direction := ""
var _attack_pending := false
var _attack_active := false
var _events_active := false
var _base_background_margin := 0.0
var _attack_exit_clearance := 144.0


func _ready() -> void:
	_event_timer = Timer.new()
	_event_timer.one_shot = true
	_event_timer.timeout.connect(_show_orca)
	add_child(_event_timer)
	_attack_timer = Timer.new()
	_attack_timer.one_shot = true
	_attack_timer.timeout.connect(_on_attack_timer_timeout)
	add_child(_attack_timer)
	_sprite_frames = _make_sprite_frames()
	_base_background_margin = float(arena.get("background_margin"))
	var attack_settings := ORCA_ATTACK_SCENE.instantiate() as Node2D
	_attack_exit_clearance = float(attack_settings.get("far_side_clearance"))
	attack_settings.free()
	_apply_scale_settings()
	_create_danger_overlay()


func _process(delta: float) -> void:
	if not is_instance_valid(_danger_material):
		return
	var target_strength := 1.0 if _attack_active else 0.0
	_danger_strength = move_toward(_danger_strength, target_strength, delta * 2.5)
	_danger_material.set_shader_parameter("intensity", _danger_strength)
	_danger_overlay.visible = _danger_strength > 0.001 or _attack_active


func _create_danger_overlay() -> void:
	var danger_layer := CanvasLayer.new()
	danger_layer.name = "AttackDangerOverlay"
	danger_layer.layer = 9
	add_child(danger_layer)

	_danger_overlay = ColorRect.new()
	_danger_overlay.name = "RedEdgeVignette"
	_danger_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_danger_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_danger_overlay.visible = false
	_danger_material = ShaderMaterial.new()
	_danger_material.shader = DANGER_VIGNETTE_SHADER
	_danger_material.set_shader_parameter("intensity", 0.0)
	_danger_overlay.material = _danger_material
	danger_layer.add_child(_danger_overlay)


func start_events() -> void:
	if _sprite_frames == null:
		push_warning("No se pudieron cargar las animaciones de la orca.")
		return
	_events_active = true
	_schedule_next()
	_schedule_attack()


func stop_events() -> void:
	_events_active = false
	_event_timer.stop()
	_attack_timer.stop()
	_attack_pending = false
	_attack_active = false
	if is_instance_valid(_active_orca):
		_active_orca.queue_free()
	_active_orca = null
	if is_instance_valid(_active_attack):
		_active_attack.queue_free()
	_active_attack = null
	for ripple in _active_ripples:
		if is_instance_valid(ripple):
			ripple.queue_free()
	_active_ripples.clear()
	_clear_camera_focus()


func _schedule_next() -> void:
	if not _events_active or _attack_pending or _attack_active or is_instance_valid(_active_orca):
		return
	var low := minf(minimum_interval, maximum_interval)
	var high := maxf(minimum_interval, maximum_interval)
	_event_timer.start(randf_range(low, high))


func _show_orca() -> void:
	if not _events_active or _attack_active or is_instance_valid(_active_orca):
		return
	var direction_index := randi_range(0, DIRECTIONS.size() - 1)
	var facing_direction := Vector2.RIGHT.rotated(direction_index * ANGLE_STEP)
	var outward := -facing_direction
	var spawn_position := _get_shoreline_position(outward)
	_last_surface_position = spawn_position
	_last_attack_direction = DIRECTIONS[direction_index]

	_active_orca = AnimatedSprite2D.new()
	_active_orca.sprite_frames = _sprite_frames
	_active_orca.animation = DIRECTIONS[direction_index]
	_active_orca.centered = true
	_active_orca.position = spawn_position
	_active_orca.scale = Vector2.ONE * orca_scale
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
	var background_margin := float(arena.get("background_margin"))
	var scaled_padding := ATTACK_VISUAL_PADDING * orca_scale
	var safe_min := arena_origin - Vector2.ONE * background_margin + scaled_padding
	var safe_max := arena_origin + arena_size + Vector2.ONE * background_margin - scaled_padding
	var available_offset := INF
	if outward.x > 0.0001:
		available_offset = minf(available_offset, (safe_max.x - shoreline_point.x) / outward.x)
	elif outward.x < -0.0001:
		available_offset = minf(available_offset, (safe_min.x - shoreline_point.x) / outward.x)
	if outward.y > 0.0001:
		available_offset = minf(available_offset, (safe_max.y - shoreline_point.y) / outward.y)
	elif outward.y < -0.0001:
		available_offset = minf(available_offset, (safe_min.y - shoreline_point.y) / outward.y)
	var perimeter_offset := minf(shoreline_offset * orca_scale, maxf(available_offset, 0.0))
	var south_weight := _smooth_unit(clampf((outward.y - 0.15) / 0.85, 0.0, 1.0))
	var southern_offset := minf(SOUTH_WALL_CLEARANCE * orca_scale * south_weight, maxf(available_offset - perimeter_offset, 0.0))
	perimeter_offset += southern_offset
	return shoreline_point + outward * perimeter_offset


func _apply_scale_settings() -> void:
	if not is_instance_valid(arena):
		return
	var required_margin := _calculate_background_margin()
	if not is_equal_approx(float(arena.get("background_margin")), required_margin):
		arena.call("set_background_margin", required_margin)
	var camera := get_node_or_null("../SharedCamera")
	if camera != null:
		camera.call("set_background_margin", required_margin)
	if is_instance_valid(_active_orca):
		_active_orca.scale = Vector2.ONE * orca_scale
	for ripple in _active_ripples:
		if is_instance_valid(ripple):
			ripple.set("ripple_scale", orca_scale)
	if is_instance_valid(_active_attack):
		_active_attack.set("sprite_scale", orca_scale)


func _calculate_background_margin() -> float:
	var arena_origin := arena.global_position
	var arena_size: Vector2 = arena.get("world_size")
	var arena_end := arena_origin + arena_size
	var arena_center := arena_origin + arena_size * 0.5
	var boundary_points: Array[Vector2] = []
	for point in ice_boundary.polygon:
		boundary_points.append(ice_boundary.to_global(point))
	var visual_padding := ATTACK_VISUAL_PADDING * orca_scale
	var needed_margin := _base_background_margin
	for direction_index in range(DIRECTIONS.size()):
		var outward := -Vector2.RIGHT.rotated(direction_index * ANGLE_STEP)
		var shore_distance := _ray_distance_to_polygon(arena_center, outward, boundary_points)
		if shore_distance == INF:
			continue
		var shoreline_point := arena_center + outward * shore_distance
		var south_weight := _smooth_unit(clampf((outward.y - 0.15) / 0.85, 0.0, 1.0))
		var surface_offset := (shoreline_offset + SOUTH_WALL_CLEARANCE * south_weight) * orca_scale
		var surface_position := shoreline_point + outward * surface_offset
		needed_margin = maxf(needed_margin, _margin_for_visual_bounds(surface_position, visual_padding, arena_origin, arena_end))

		var attack_direction := -outward
		var attack_distances := _ray_distances_to_polygon(surface_position, attack_direction, boundary_points)
		if attack_distances.size() < 2:
			continue
		var crossing_end := surface_position + attack_direction * (attack_distances[-1] + _attack_exit_clearance * orca_scale)
		needed_margin = maxf(needed_margin, _margin_for_visual_bounds(crossing_end, visual_padding, arena_origin, arena_end))
	return needed_margin


func _margin_for_visual_bounds(position: Vector2, padding: Vector2, arena_origin: Vector2, arena_end: Vector2) -> float:
	var visual_min := position - padding
	var visual_max := position + padding
	return maxf(
		maxf(arena_origin.x - visual_min.x, arena_end.x - visual_max.x),
		maxf(arena_origin.y - visual_min.y, arena_end.y - visual_max.y)
	)


func _ray_distances_to_polygon(origin: Vector2, direction: Vector2, points: Array[Vector2]) -> Array[float]:
	var distances: Array[float] = []
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
			distances.append(ray_distance)
	distances.sort()
	return distances


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
	ripple.set("ripple_scale", orca_scale)
	ripple.z_index = layer
	ripple.set("draw_front_half", draw_front_half)
	add_child(ripple)
	return ripple


func _schedule_attack() -> void:
	if not _events_active:
		return
	var low := minf(minimum_attack_interval, maximum_attack_interval)
	var high := maxf(minimum_attack_interval, maximum_attack_interval)
	_attack_timer.start(randf_range(low, high))


func _on_attack_timer_timeout() -> void:
	if not _events_active or _attack_active:
		return
	_event_timer.stop()
	_attack_pending = true
	if is_instance_valid(_active_orca):
		if _is_attack_window(_active_orca):
			_begin_attack()
		return
	_show_orca()


func _begin_attack() -> void:
	if not _events_active or _attack_active or not _attack_pending or not is_instance_valid(_active_orca):
		return
	if not _is_attack_window(_active_orca):
		return
	_attack_pending = false
	_attack_active = true
	_event_timer.stop()
	_clear_surface_visuals()
	_active_attack = ORCA_ATTACK_SCENE.instantiate() as Node2D
	_active_attack.set("sprite_scale", orca_scale)
	_active_attack.connect("finished", _on_attack_finished.bind(_active_attack), CONNECT_ONE_SHOT)
	add_child(_active_attack)
	_active_attack.call(
		"begin",
		_last_attack_direction,
		_last_surface_position,
		ice_boundary,
		players,
		arena,
		get_node_or_null("../SharedCamera")
	)


func _on_attack_finished(attack: Node2D) -> void:
	if is_instance_valid(attack):
		attack.queue_free()
	if _active_attack == attack:
		_active_attack = null
	_attack_active = false
	_clear_camera_focus()
	if _events_active:
		_schedule_next()
		_schedule_attack()


func _on_orca_frame_changed(orca: AnimatedSprite2D) -> void:
	if not is_instance_valid(orca):
		return
	_update_ripple_surface(_get_surface_amount(orca.frame))
	if _attack_pending and _active_orca == orca and _is_attack_window(orca):
		_begin_attack()


func _is_attack_window(orca: AnimatedSprite2D) -> bool:
	return orca.frame >= FULL_SURFACE_FRAME and orca.frame < SUBMERGE_START_FRAME


func _clear_surface_visuals() -> void:
	if is_instance_valid(_active_orca):
		_active_orca.stop()
		_active_orca.queue_free()
	_active_orca = null
	_update_ripple_surface(0.0)
	for ripple in _active_ripples:
		if is_instance_valid(ripple):
			ripple.call("stop_emitting")
	_active_ripples.clear()
	_clear_camera_focus()


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
	if _active_orca != orca:
		return
	_clear_surface_visuals()
	if _attack_pending:
		_show_orca()
	else:
		_schedule_next()


func _clear_camera_focus() -> void:
	var camera := get_node_or_null("../SharedCamera")
	if camera != null:
		camera.call("clear_event_focus")
