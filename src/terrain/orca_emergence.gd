extends Node

const DIRECTIONS: Array[String] = ["E", "SE", "S", "SO", "O", "NO", "N", "NE"]
const ANGLE_STEP := TAU / 8.0
const SOUTH_WALL_CLEARANCE := 64.0
const ATTACK_VISUAL_PADDING := Vector2(136.0, 120.0)
const ORCA_RIPPLE_SCRIPT = preload("res://src/terrain/orca_ripple.gd")
const ORCA_ATTACK_SCENE = preload("res://src/terrain/OrcaAttack.tscn")
const DANGER_VIGNETTE_SHADER = preload("res://src/terrain/orca_danger_vignette.gdshader")

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

@export_group("Animaciones editables")
@export var surface_sprite_frames: SpriteFrames
@export_range(0, 512, 1) var full_surface_frame := 16
@export_range(0, 512, 1) var submerge_start_frame := 48

@onready var arena: Node2D = get_node("../Arena")
@onready var ice_boundary: CollisionPolygon2D = get_node("../Arena/IceArea/Ground")
@onready var players: Node2D = get_node("../Players")
@onready var _asomo_audio: AudioStreamPlayer = $AsomoAudio
@onready var _inmersion_audio: AudioStreamPlayer = $InmersionAudio

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


func _ready() -> void:
	_event_timer = Timer.new()
	_event_timer.one_shot = true
	_event_timer.timeout.connect(_show_orca)
	add_child(_event_timer)
	_attack_timer = Timer.new()
	_attack_timer.one_shot = true
	_attack_timer.timeout.connect(_on_attack_timer_timeout)
	add_child(_attack_timer)
	_sprite_frames = surface_sprite_frames
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
	_asomo_audio.stop()
	_inmersion_audio.stop()
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
	var animation_name: String = DIRECTIONS[direction_index]
	if not _sprite_frames.has_animation(animation_name) or _sprite_frames.get_frame_count(animation_name) == 0:
		push_warning("Falta una animación de asomo editable para la dirección %s." % animation_name)
		return
	var facing_direction := Vector2.RIGHT.rotated(direction_index * ANGLE_STEP)
	var outward := -facing_direction
	var spawn_position := _get_shoreline_position(outward)
	_last_surface_position = spawn_position
	_last_attack_direction = DIRECTIONS[direction_index]

	_active_orca = AnimatedSprite2D.new()
	_active_orca.sprite_frames = _sprite_frames
	_active_orca.animation = animation_name
	_active_orca.centered = true
	_active_orca.position = spawn_position
	_active_orca.scale = Vector2.ONE * orca_scale
	_active_orca.z_index = -7
	_active_orca.frame_changed.connect(_on_orca_frame_changed.bind(_active_orca))
	_active_orca.animation_finished.connect(_on_orca_animation_finished.bind(_active_orca), CONNECT_ONE_SHOT)
	add_child(_active_orca)
	_asomo_audio.stop()
	_inmersion_audio.stop()
	if not _attack_pending:
		_asomo_audio.play()
	_active_ripples.append(_create_ripple_half(spawn_position, false, -8))
	_active_ripples.append(_create_ripple_half(spawn_position, true, -6))
	_update_ripple_surface(_get_surface_amount(
		_active_orca.frame,
		_sprite_frames.get_frame_count(_active_orca.animation)
	))
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
	if is_instance_valid(_active_orca):
		_active_orca.scale = Vector2.ONE * orca_scale
	for ripple in _active_ripples:
		if is_instance_valid(ripple):
			ripple.set("ripple_scale", orca_scale)
	if is_instance_valid(_active_attack):
		_active_attack.set("sprite_scale", orca_scale)


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
	_asomo_audio.stop()
	_inmersion_audio.stop()
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
	if not _attack_pending and not _attack_active and orca.frame == submerge_start_frame:
		_inmersion_audio.play()
	_update_ripple_surface(_get_surface_amount(
		orca.frame,
		orca.sprite_frames.get_frame_count(orca.animation)
	))
	if _attack_pending and _active_orca == orca and _is_attack_window(orca):
		_begin_attack()


func _is_attack_window(orca: AnimatedSprite2D) -> bool:
	var frame_count := orca.sprite_frames.get_frame_count(orca.animation)
	if frame_count < 2:
		return false
	var fully_emerged_at := clampi(full_surface_frame, 0, frame_count - 1)
	var submerge_at := clampi(submerge_start_frame, fully_emerged_at + 1, frame_count)
	return orca.frame >= fully_emerged_at and orca.frame < submerge_at


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


func _get_surface_amount(frame: int, frame_count: int) -> float:
	if frame_count < 2:
		return 0.0
	var fully_emerged_at := clampi(full_surface_frame, 1, frame_count - 1)
	var submerge_at := clampi(submerge_start_frame, fully_emerged_at + 1, frame_count - 1)
	if frame < fully_emerged_at:
		return _smooth_unit(float(frame) / fully_emerged_at)
	if frame < submerge_at:
		return 1.0
	var submerge_length := maxi(frame_count - 1 - submerge_at, 1)
	var submerge_progress := float(frame - submerge_at) / submerge_length
	return 1.0 - _smooth_unit(submerge_progress)


func _smooth_unit(value: float) -> float:
	var clamped_value := clampf(value, 0.0, 1.0)
	return clamped_value * clamped_value * (3.0 - 2.0 * clamped_value)


func _update_ripple_surface(surface_amount: float) -> void:
	for ripple in _active_ripples:
		if is_instance_valid(ripple):
			ripple.call("set_surface_amount", surface_amount)


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
