@tool
extends Node2D

signal finished

const VISUAL_PADDING := Vector2(136.0, 120.0)
const PLAYER_DEPTH_Z := 4095

enum Phase { JUMPING, CROSSING, DIVING }

@export_group("Desplazamiento")
@export_range(80.0, 600.0, 10.0) var jump_speed := 220.0
@export_range(120.0, 1200.0, 10.0) var crossing_speed := 620.0
@export_range(0.0, 120.0, 4.0) var ice_entry_margin := 40.0
@export_range(0.0, 240.0, 4.0) var far_side_clearance := 144.0
@export_range(24.0, 180.0, 2.0) var hitbox_half_length := 78.0:
	set(value):
		hitbox_half_length = value
		_refresh_hitbox_preview()

@export_range(12.0, 100.0, 2.0) var hitbox_half_width := 32.0:
	set(value):
		hitbox_half_width = value
		_refresh_hitbox_preview()

@export_group("Animación")
@export_range(0, 255, 1) var jump_start_frame := 16
@export_range(1, 32, 1) var jump_frame_count := 8
@export_group("Animaciones editables")
@export var attack_sprite_frames: SpriteFrames:
	set(value):
		attack_sprite_frames = value
		_refresh_editor_preview()
@export_group("Audio del ataque")
@export var loop_alarm := true
@export var use_ice_crack_layer := true
@export var duck_music_during_attack := true
@export_range(-60.0, 0.0, 1.0) var music_duck_db := -12.0
@export_range(0.0, 2.0, 0.05) var music_duck_fade_seconds := 0.25
@export_range(0.0, 2.0, 0.05) var music_restore_fade_seconds := 0.45
@export_group("Presentación")
@export_range(0.25, 2.0, 0.05) var sprite_scale := 1.0:
	set(value):
		sprite_scale = clampf(value, 0.25, 2.0)
		if is_instance_valid(_sprite):
			_sprite.scale = Vector2.ONE * sprite_scale
		_refresh_hitbox_preview()

@export_group("Previsualización en editor")
@export_enum("E", "SE", "S", "SO", "O", "NO", "N", "NE") var preview_direction := "E":
	set(value):
		preview_direction = value
		_refresh_editor_preview()
		_refresh_hitbox_preview()
@export_enum("salto", "arrastre", "mordida", "zambullida") var preview_action := "arrastre":
	set(value):
		preview_action = value
		_refresh_editor_preview()
@export var preview_playing := false:
	set(value):
		preview_playing = value
		_refresh_editor_preview()
@export_range(0, 255, 1) var preview_frame := 0:
	set(value):
		preview_frame = value
		_refresh_editor_preview(true)
@export var show_hitbox_preview := true:
	set(value):
		show_hitbox_preview = value
		_refresh_hitbox_preview()
@export var show_hitbox_in_gameplay := false:
	set(value):
		show_hitbox_in_gameplay = value
		_refresh_hitbox_preview()

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _hitbox_preview: Node2D = $HitboxPreview
@onready var _alarm_audio: AudioStreamPlayer = $AlarmAudio
@onready var _jump_audio: AudioStreamPlayer = $JumpAudio
@onready var _slide_audio: AudioStreamPlayer = $SlideAudio
@onready var _ice_crack_audio: AudioStreamPlayer = $IceCrackAudio
@onready var _dive_audio: AudioStreamPlayer = $DiveAudio

var _direction_name := ""
var _direction := Vector2.ZERO
var _boundary: CollisionPolygon2D
var _players: Node2D
var _arena: Node2D
var _camera: Camera2D
var _phase := Phase.JUMPING
var _jump_start := Vector2.ZERO
var _jump_end := Vector2.ZERO
var _crossing_start := Vector2.ZERO
var _crossing_end := Vector2.ZERO
var _phase_elapsed := 0.0
var _phase_duration := 1.0
var _hit_slots: Dictionary = {}
var _attack_audio_active := false
var _music_duck_applied := false
var _attack_finished := false


func _ready() -> void:
	_sprite.scale = Vector2.ONE * sprite_scale
	_refresh_hitbox_preview()
	if Engine.is_editor_hint():
		_sprite.animation_finished.connect(_on_editor_preview_animation_finished)
		_refresh_hitbox_preview()
		_refresh_editor_preview(true)
		return
	_sprite.animation_finished.connect(_on_animation_finished)
	_alarm_audio.finished.connect(_on_alarm_audio_finished)


func _exit_tree() -> void:
	_attack_audio_active = false
	_restore_music_volume()


func begin(
	direction_name: String,
	start_position: Vector2,
	boundary: CollisionPolygon2D,
	players: Node2D,
	arena: Node2D,
	camera: Camera2D
) -> void:
	_direction_name = direction_name
	_direction = _direction_from_name(direction_name)
	_refresh_hitbox_preview()
	_boundary = boundary
	_players = players
	_arena = arena
	_camera = camera
	var distances := _get_boundary_distances(start_position, _direction)
	if distances.size() < 2:
		push_warning("No se encontraron ambos bordes del hielo para el ataque de la orca.")
		finished.emit()
		return
	var entry_distance := distances[0]
	var exit_distance := distances[distances.size() - 1]
	var scaled_entry_margin := ice_entry_margin * sprite_scale
	var scaled_exit_clearance := far_side_clearance * sprite_scale

	_jump_start = start_position
	_jump_end = start_position + _direction * (entry_distance + scaled_entry_margin)
	_crossing_start = _jump_end
	var boundary_exit := start_position + _direction * exit_distance
	var arena_origin := _arena.global_position
	var arena_size: Vector2 = _arena.get("world_size")
	var background_margin := float(_arena.get("background_margin"))
	var available_overtravel := _distance_to_safe_edge(
		boundary_exit,
		_direction,
		arena_origin - Vector2.ONE * background_margin + VISUAL_PADDING * sprite_scale,
		arena_origin + arena_size + Vector2.ONE * background_margin - VISUAL_PADDING * sprite_scale
	)
	var exit_margin := minf(scaled_exit_clearance, maxf(available_overtravel, 0.0))
	_crossing_end = boundary_exit + _direction * exit_margin
	global_position = _jump_start
	_phase = Phase.JUMPING
	_phase_elapsed = 0.0
	_phase_duration = maxf(_jump_start.distance_to(_jump_end) / maxf(jump_speed, 1.0), 0.05)
	_sprite.z_index = PLAYER_DEPTH_Z
	var jump_frames := _make_action_frames("salto", jump_frame_count, jump_start_frame)
	if jump_frames == null:
		_finish_attack()
		return
	var jump_duration := _get_animation_duration(jump_frames, "salto")
	jump_frames.set_animation_speed("salto", jump_duration / _phase_duration)
	_start_attack_audio()
	_jump_audio.play()
	_play_frames(jump_frames, "salto")


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	match _phase:
		Phase.JUMPING:
			_advance_along_line(_jump_start, _jump_end, delta)
		Phase.CROSSING:
			_advance_along_line(_crossing_start, _crossing_end, delta)


func _advance_along_line(start: Vector2, end: Vector2, delta: float) -> void:
	var previous_position := global_position
	_phase_elapsed = minf(_phase_elapsed + delta, _phase_duration)
	var progress := _phase_elapsed / _phase_duration
	global_position = start.lerp(end, progress)
	_check_crossed_players(previous_position, global_position)
	if is_instance_valid(_camera):
		_camera.call("set_event_focus", global_position)


func _get_boundary_distances(start_position: Vector2, direction: Vector2) -> Array[float]:
	var boundary_points: Array[Vector2] = []
	for point in _boundary.polygon:
		boundary_points.append(_boundary.to_global(point))
	var distances: Array[float] = []
	for index in range(boundary_points.size()):
		var start := boundary_points[index]
		var edge := boundary_points[(index + 1) % boundary_points.size()] - start
		var denominator := direction.cross(edge)
		if absf(denominator) < 0.0001:
			continue
		var offset := start - start_position
		var ray_distance := offset.cross(edge) / denominator
		var edge_progress := offset.cross(direction) / denominator
		if ray_distance >= 0.0 and edge_progress >= 0.0 and edge_progress <= 1.0:
			distances.append(ray_distance)
	distances.sort()
	return distances


func _distance_to_safe_edge(origin: Vector2, direction: Vector2, safe_min: Vector2, safe_max: Vector2) -> float:
	var available := INF
	if direction.x > 0.0001:
		available = minf(available, (safe_max.x - origin.x) / direction.x)
	elif direction.x < -0.0001:
		available = minf(available, (safe_min.x - origin.x) / direction.x)
	if direction.y > 0.0001:
		available = minf(available, (safe_max.y - origin.y) / direction.y)
	elif direction.y < -0.0001:
		available = minf(available, (safe_min.y - origin.y) / direction.y)
	return available


func _check_crossed_players(from: Vector2, to: Vector2) -> void:
	var scaled_half_length := hitbox_half_length * sprite_scale
	var scaled_half_width := hitbox_half_width * sprite_scale
	for character in _players.get_children():
		if character.get_child_count() == 0:
			continue
		var penguin := character.get_child(0) as Penguin
		if penguin == null or penguin.is_dead or penguin.is_eliminated:
			continue
		var slot := penguin.player_index
		if _hit_slots.has(slot):
			continue
		if _point_intersects_swept_hitbox(penguin.global_position, from, to, scaled_half_length, scaled_half_width):
			_hit_slots[slot] = true
			penguin.lose_life(true)


func _point_intersects_swept_hitbox(point: Vector2, from: Vector2, to: Vector2, half_length: float, half_width: float) -> bool:
	var axis := _direction.normalized()
	if axis.is_zero_approx():
		return false
	var side_axis := axis.orthogonal()
	var relative := point - from
	var along := relative.dot(axis)
	var across := relative.dot(side_axis)
	var segment_length := maxf((to - from).dot(axis), 0.0)
	if along >= 0.0 and along <= segment_length:
		return absf(across) <= half_width
	var cap_center := from if along < 0.0 else to
	var cap_offset := point - cap_center
	var normalized_along := cap_offset.dot(axis) / maxf(half_length, 0.001)
	var normalized_across := cap_offset.dot(side_axis) / maxf(half_width, 0.001)
	return normalized_along * normalized_along + normalized_across * normalized_across <= 1.0


func _begin_crossing() -> void:
	if _phase != Phase.JUMPING:
		return
	_phase = Phase.CROSSING
	_phase_elapsed = 0.0
	_phase_duration = maxf(_crossing_start.distance_to(_crossing_end) / maxf(crossing_speed, 1.0), 0.05)
	var slide_frames := _make_action_frames("arrastre")
	if slide_frames == null:
		_finish_attack()
		return
	var slide_duration := _get_animation_duration(slide_frames, "arrastre")
	slide_frames.set_animation_speed("arrastre", slide_duration / _phase_duration)
	_jump_audio.stop()
	_slide_audio.play()
	if use_ice_crack_layer:
		_ice_crack_audio.play()
	_play_frames(slide_frames, "arrastre")


func _begin_dive() -> void:
	if _phase == Phase.DIVING:
		return
	_phase = Phase.DIVING
	global_position = _crossing_end
	_slide_audio.stop()
	_ice_crack_audio.stop()
	_play_action("zambullida")


func _play_action(action: String) -> void:
	var sprite_frames := _make_action_frames(action)
	if sprite_frames == null:
		_finish_attack()
		return
	_play_frames(sprite_frames, action)
	if action == "zambullida":
		_dive_audio.play()


func _make_action_frames(action: String, frame_limit: int = -1, frame_start: int = 0) -> SpriteFrames:
	if attack_sprite_frames == null:
		push_warning("No se asignó el recurso SpriteFrames editable para el ataque de la orca.")
		return null
	var source_animation := "%s_%s" % [_direction_name, action]
	if not attack_sprite_frames.has_animation(source_animation):
		push_warning("Falta la animación editable %s en los SpriteFrames de la orca." % source_animation)
		return null
	var total_frames := attack_sprite_frames.get_frame_count(source_animation)
	if total_frames == 0:
		push_warning("La animación editable %s de la orca no tiene cuadros." % source_animation)
		return null
	var first_frame := clampi(frame_start, 0, total_frames - 1)
	var last_frame := total_frames
	if frame_limit > 0:
		last_frame = mini(first_frame + frame_limit, total_frames)
	var sprite_frames := SpriteFrames.new()
	sprite_frames.remove_animation("default")
	sprite_frames.add_animation(action)
	sprite_frames.set_animation_loop(action, attack_sprite_frames.get_animation_loop(source_animation))
	sprite_frames.set_animation_speed(action, attack_sprite_frames.get_animation_speed(source_animation))
	for index in range(first_frame, last_frame):
		sprite_frames.add_frame(
			action,
			attack_sprite_frames.get_frame_texture(source_animation, index),
			attack_sprite_frames.get_frame_duration(source_animation, index)
		)
	return sprite_frames


func _get_animation_duration(sprite_frames: SpriteFrames, animation: StringName) -> float:
	var duration := 0.0
	for index in range(sprite_frames.get_frame_count(animation)):
		duration += sprite_frames.get_frame_duration(animation, index)
	return maxf(duration, 0.001)


func _play_frames(sprite_frames: SpriteFrames, action: String) -> void:
	_sprite.sprite_frames = sprite_frames
	_sprite.animation = action
	_sprite.play()


func _refresh_editor_preview(force_frame: bool = false) -> void:
	if not Engine.is_editor_hint() or not is_instance_valid(_sprite) or attack_sprite_frames == null:
		return
	var animation_name := StringName("%s_%s" % [preview_direction, preview_action])
	if not attack_sprite_frames.has_animation(animation_name):
		return
	var animation_changed := _sprite.sprite_frames != attack_sprite_frames or _sprite.animation != animation_name
	_sprite.sprite_frames = attack_sprite_frames
	_sprite.scale = Vector2.ONE * sprite_scale
	if animation_changed:
		_sprite.animation = animation_name
	if preview_playing:
		if animation_changed or not _sprite.is_playing():
			_sprite.play(animation_name)
		if force_frame:
			_sprite.frame = clampi(preview_frame, 0, attack_sprite_frames.get_frame_count(animation_name) - 1)
	else:
		_sprite.stop()
		_sprite.animation = animation_name
		_sprite.frame = clampi(preview_frame, 0, attack_sprite_frames.get_frame_count(animation_name) - 1)


func _refresh_hitbox_preview() -> void:
	if not is_instance_valid(_hitbox_preview):
		return
	_hitbox_preview.visible = show_hitbox_preview if Engine.is_editor_hint() else show_hitbox_in_gameplay
	var hitbox_direction := _direction_from_name(preview_direction) if Engine.is_editor_hint() or _direction.is_zero_approx() else _direction
	_hitbox_preview.rotation = hitbox_direction.angle()
	_hitbox_preview.set("half_length", hitbox_half_length * sprite_scale)
	_hitbox_preview.set("half_width", hitbox_half_width * sprite_scale)


func _on_editor_preview_animation_finished() -> void:
	if Engine.is_editor_hint() and preview_playing:
		_sprite.play(StringName("%s_%s" % [preview_direction, preview_action]))


func _direction_from_name(direction_name: String) -> Vector2:
	match direction_name:
		"E": return Vector2.RIGHT
		"SE": return Vector2(1.0, 1.0).normalized()
		"S": return Vector2.DOWN
		"SO": return Vector2(-1.0, 1.0).normalized()
		"O": return Vector2.LEFT
		"NO": return Vector2(-1.0, -1.0).normalized()
		"N": return Vector2.UP
		"NE": return Vector2(1.0, -1.0).normalized()
	return Vector2.ZERO


func _on_animation_finished() -> void:
	match _phase:
		Phase.JUMPING:
			global_position = _jump_end
			_begin_crossing()
		Phase.CROSSING:
			global_position = _crossing_end
			_begin_dive()
		Phase.DIVING:
			_finish_attack()


func _start_attack_audio() -> void:
	_attack_audio_active = true
	if _alarm_audio.stream != null:
		_alarm_audio.play()
	if duck_music_during_attack:
		_music_duck_applied = true
		Music.set_orca_attack_ducked(true, music_duck_db, music_duck_fade_seconds)


func _on_alarm_audio_finished() -> void:
	if _attack_audio_active and loop_alarm and _alarm_audio.stream != null:
		_alarm_audio.play()


func _stop_attack_sounds() -> void:
	for player in [_alarm_audio, _jump_audio, _slide_audio, _ice_crack_audio, _dive_audio]:
		player.stop()


func _restore_music_volume() -> void:
	if not _music_duck_applied:
		return
	_music_duck_applied = false
	Music.set_orca_attack_ducked(false, 0.0, music_restore_fade_seconds)


func _finish_attack() -> void:
	if _attack_finished:
		return
	_attack_finished = true
	_attack_audio_active = false
	_stop_attack_sounds()
	_restore_music_volume()
	finished.emit()
