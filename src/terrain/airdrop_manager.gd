extends Node2D

const DEFAULT_AIRPLANE_FRAMES: SpriteFrames = preload("res://assets/field_objects/sombra_avion/animaciones.tres")
const DEFAULT_BOX_SHADOW_FRAMES: SpriteFrames = preload("res://assets/field_objects/sombra_caja/animaciones.tres")
const DEFAULT_BOX_SCENE: PackedScene = preload("res://assets/field_objects/caja_flor/caja_pescado.tscn")

const PLANE_DIRECTIONS := [
	{"name": "E", "vector": Vector2.RIGHT},
	{"name": "SE", "vector": Vector2(0.70710678, 0.70710678)},
	{"name": "S", "vector": Vector2.DOWN},
	{"name": "SO", "vector": Vector2(-0.70710678, 0.70710678)},
	{"name": "O", "vector": Vector2.LEFT},
	{"name": "NO", "vector": Vector2(-0.70710678, -0.70710678)},
	{"name": "N", "vector": Vector2.UP},
	{"name": "NE", "vector": Vector2(0.70710678, -0.70710678)},
]

@export_group("Recursos")
@export var airplane_frames: SpriteFrames = DEFAULT_AIRPLANE_FRAMES
@export var box_shadow_frames: SpriteFrames = DEFAULT_BOX_SHADOW_FRAMES
@export var box_scene: PackedScene = DEFAULT_BOX_SCENE

@export_group("Frecuencia")
@export_range(1.0, 60.0, 1.0) var first_drop_delay_min := 5.0
@export_range(1.0, 90.0, 1.0) var first_drop_delay_max := 8.0
@export_range(10.0, 180.0, 1.0) var interval_min := 30.0
@export_range(10.0, 240.0, 1.0) var interval_max := 44.0

@export_group("Avion")
@export var airplane_shadow_scale := Vector2(0.7, 0.7)
@export_range(0.0, 1.0, 0.05) var airplane_shadow_opacity := 0.85
@export_range(1.0, 500.0, 5.0) var airplane_edge_fade_distance := 110.0
@export_range(1.0, 20.0, 0.25) var airplane_pass_duration := 5.5
@export_range(0.1, 0.9, 0.05) var package_release_fraction := 0.5
@export_range(0.0, 1000.0, 10.0) var airplane_route_margin := 140.0

@export_group("Caja en caida")
@export var package_scale := Vector2(1.2, 1.2)
## In the supplied scene the package pivot is 120 pixels below the top of its sprites.
@export_range(0.0, 240.0, 1.0) var package_pivot_to_top := 120.0
@export_range(0.0, 200.0, 1.0) var screen_edge_gap := 8.0
@export_range(0.0, 600.0, 10.0) var minimum_fall_distance := 180.0
@export_range(0.2, 10.0, 0.1) var package_fall_duration := 2.8
@export_range(0.0, 1.0, 0.05) var box_shadow_start_scale := 0.15
@export_range(0.5, 2.5, 0.05) var box_shadow_final_scale := 1.1
@export_range(0.0, 2.0, 0.05) var box_shadow_contact_duration := 0.9
@export_range(0.0, 100.0, 1.0) var crush_radius := 38.0
@export_range(0, 4092, 1) var falling_package_z_index := 4092

@export_group("Caja abierta")
@export_range(-7, 4092, 1) var landed_package_z_index := -4
@export_range(0.0, 1.0, 0.05) var impact_cover_duration := 0.45
@export_range(0.0, 10.0, 0.1) var open_box_linger := 1.8
@export_range(0.1, 5.0, 0.1) var open_box_fade_duration := 1.2
@export_range(0.0, 2.0, 0.05) var box_open_sound_delay := 0.18

var _events_running := false
var _event_generation := 0
var _spawn_timer: Timer
@onready var _airplane_audio: AudioStreamPlayer = $AirplaneAudio
@onready var _box_land_audio: AudioStreamPlayer = $BoxLandAudio
@onready var _box_open_audio: AudioStreamPlayer = $BoxOpenAudio
var _active_plane_shadow: AnimatedSprite2D
var _plane_start_position := Vector2.ZERO
var _plane_end_position := Vector2.ZERO
var _plane_elapsed := 0.0
var _plane_duration := 0.0
var _plane_ice_polygon := PackedVector2Array()


func _ready() -> void:
	_spawn_timer = Timer.new()
	_spawn_timer.one_shot = true
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(_spawn_timer)


func _process(delta: float) -> void:
	if not is_instance_valid(_active_plane_shadow):
		_active_plane_shadow = null
		return
	_plane_elapsed = minf(_plane_elapsed + delta, _plane_duration)
	var progress := clampf(_plane_elapsed / maxf(_plane_duration, 0.001), 0.0, 1.0)
	_active_plane_shadow.global_position = _plane_start_position.lerp(_plane_end_position, progress)
	var tint := _active_plane_shadow.modulate
	tint.a = airplane_shadow_opacity * _get_ice_edge_fade(_active_plane_shadow.global_position)
	_active_plane_shadow.modulate = tint


func start_events() -> void:
	if _events_running:
		return
	_events_running = true
	_event_generation += 1
	_schedule_next_drop(true)


func stop_events() -> void:
	_events_running = false
	_event_generation += 1
	_spawn_timer.stop()
	_airplane_audio.stop()
	_box_land_audio.stop()
	_box_open_audio.stop()
	_active_plane_shadow = null
	_plane_ice_polygon.clear()
	for child in get_children():
		if child != _spawn_timer and child != _airplane_audio and child != _box_land_audio and child != _box_open_audio:
			child.queue_free()


func _schedule_next_drop(first_drop: bool = false) -> void:
	if not _events_running:
		return
	var lower := minf(first_drop_delay_min, first_drop_delay_max) if first_drop else minf(interval_min, interval_max)
	var upper := maxf(first_drop_delay_min, first_drop_delay_max) if first_drop else maxf(interval_min, interval_max)
	_spawn_timer.start(randf_range(lower, upper))


func _on_spawn_timer_timeout() -> void:
	if not _events_running:
		return
	var target_value: Variant = _random_ice_position()
	if not target_value is Vector2:
		_schedule_next_drop()
		return
	var target: Vector2 = target_value
	_schedule_next_drop()
	await _run_airdrop(target, _event_generation)


func _random_ice_position() -> Variant:
	var ground := get_parent().get_node_or_null("Arena/IceArea/Ground") as CollisionPolygon2D
	if ground == null or ground.polygon.size() < 3:
		return null

	var global_polygon := PackedVector2Array()
	for point in ground.polygon:
		global_polygon.append(ground.to_global(point))
	var bounds := Rect2(global_polygon[0], Vector2.ZERO)
	for point in global_polygon:
		bounds = bounds.expand(point)

	var safe_package_scale_y := maxf(package_scale.y, 0.1)
	var minimum_target_y := _get_screen_top_y() - screen_edge_gap + package_pivot_to_top * safe_package_scale_y + minimum_fall_distance
	for attempt in range(512):
		var candidate := Vector2(
			randf_range(bounds.position.x, bounds.end.x),
			randf_range(bounds.position.y, bounds.end.y)
		)
		if candidate.y >= minimum_target_y and Geometry2D.is_point_in_polygon(candidate, global_polygon):
			return candidate
	var fallback := global_polygon[0]
	for point in global_polygon:
		if point.y > fallback.y:
			fallback = point
	return fallback


func _run_airdrop(target: Vector2, generation: int) -> void:
	if not _events_running or generation != _event_generation or airplane_frames == null:
		return
	var flight_direction: Dictionary = PLANE_DIRECTIONS[randi_range(0, PLANE_DIRECTIONS.size() - 1)]
	var direction: Vector2 = flight_direction["vector"]
	var animation_name := StringName(flight_direction["name"])
	var bounds := _get_ice_bounds()
	if bounds.size == Vector2.ZERO:
		return
	_plane_ice_polygon = _get_ice_polygon()
	if _plane_ice_polygon.size() < 3:
		return
	var projected_span := absf(direction.x) * bounds.size.x + absf(direction.y) * bounds.size.y
	var route_distance := projected_span * 0.5 + airplane_route_margin
	_plane_start_position = target - direction * route_distance
	_plane_end_position = target + direction * route_distance
	_plane_elapsed = 0.0
	_plane_duration = maxf(airplane_pass_duration, 0.1)

	var plane_shadow := AnimatedSprite2D.new()
	plane_shadow.sprite_frames = airplane_frames
	plane_shadow.animation = animation_name
	plane_shadow.scale = airplane_shadow_scale
	plane_shadow.z_index = 0
	add_child(plane_shadow)
	_active_plane_shadow = plane_shadow
	plane_shadow.global_position = _plane_start_position
	plane_shadow.play(animation_name)
	if _airplane_audio.stream != null:
		_airplane_audio.play()

	var drop_timer := get_tree().create_timer(_plane_duration * clampf(package_release_fraction, 0.1, 0.9), false)
	drop_timer.timeout.connect(_start_package_drop.bind(target, generation), CONNECT_ONE_SHOT)
	await get_tree().create_timer(_plane_duration, false).timeout
	if is_instance_valid(plane_shadow):
		plane_shadow.queue_free()
	if _active_plane_shadow == plane_shadow:
		_active_plane_shadow = null


func _start_package_drop(target: Vector2, generation: int) -> void:
	if not _events_running or generation != _event_generation or box_scene == null or box_shadow_frames == null:
		return

	var safe_scale := Vector2(maxf(package_scale.x, 0.1), maxf(package_scale.y, 0.1))
	var box_shadow := AnimatedSprite2D.new()
	box_shadow.sprite_frames = box_shadow_frames
	box_shadow.animation = &"descenso"
	box_shadow.z_index = landed_package_z_index - 1
	box_shadow.scale = safe_scale * box_shadow_start_scale
	box_shadow.global_position = target
	add_child(box_shadow)
	box_shadow.play(&"descenso")

	var package := box_scene.instantiate() as Node2D
	package.scale = safe_scale
	package.z_index = falling_package_z_index
	add_child(package)
	var screen_top_y := _get_screen_top_y()
	var start_y := screen_top_y - screen_edge_gap + package_pivot_to_top * safe_scale.y
	package.global_position = Vector2(target.x, start_y)
	var attached_shadow := package.get_node_or_null("PlanoTrasero/Sombra") as Sprite2D
	if attached_shadow != null:
		attached_shadow.hide()

	var duration := maxf(package_fall_duration, 0.1)
	var shadow_tween := box_shadow.create_tween()
	shadow_tween.tween_property(box_shadow, "scale", safe_scale * box_shadow_final_scale, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	var fall_tween := package.create_tween()
	fall_tween.tween_property(package, "global_position", target, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	fall_tween.finished.connect(_on_package_landed.bind(package, box_shadow, target, generation), CONNECT_ONE_SHOT)


func _on_package_landed(package: Node2D, box_shadow: AnimatedSprite2D, target: Vector2, generation: int) -> void:
	if not _events_running or generation != _event_generation or not is_instance_valid(package):
		return
	package.global_position = target
	package.z_index = falling_package_z_index
	var attached_shadow := package.get_node_or_null("PlanoTrasero/Sombra") as Sprite2D
	if attached_shadow != null:
		attached_shadow.show()
	_crush_penguins_at(target)
	if _box_land_audio.stream != null:
		_box_land_audio.play()
	if is_instance_valid(box_shadow):
		box_shadow.play(&"contacto")
		var shadow_lifetime := get_tree().create_timer(box_shadow_contact_duration, false)
		shadow_lifetime.timeout.connect(_remove_box_shadow.bind(box_shadow), CONNECT_ONE_SHOT)

	var animation_player := package.get_node_or_null("AnimationPlayer") as AnimationPlayer
	if animation_player != null:
		animation_player.play(&"abrir")
	var impact_cover_timer := get_tree().create_timer(impact_cover_duration, false)
	impact_cover_timer.timeout.connect(_sort_landed_package.bind(package, generation), CONNECT_ONE_SHOT)
	var sound_delay := get_tree().create_timer(box_open_sound_delay, false)
	sound_delay.timeout.connect(_play_box_open_sound.bind(package, generation), CONNECT_ONE_SHOT)
	var fade_delay := get_tree().create_timer(open_box_linger, false)
	fade_delay.timeout.connect(_fade_open_package.bind(package, generation), CONNECT_ONE_SHOT)


func _play_box_open_sound(package: Node2D, generation: int) -> void:
	if _events_running and generation == _event_generation and is_instance_valid(package) and _box_open_audio.stream != null:
		_box_open_audio.play()


func _fade_open_package(package: Node2D, generation: int) -> void:
	if not _events_running or generation != _event_generation or not is_instance_valid(package):
		return
	var rear_layer := package.get_node_or_null("PlanoTrasero") as CanvasItem
	var front_layer := package.get_node_or_null("PlanoDelantero") as CanvasItem
	if rear_layer == null or front_layer == null:
		return
	var fade := package.create_tween()
	fade.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	fade.tween_property(rear_layer, "modulate:a", 0.0, open_box_fade_duration)
	fade.parallel().tween_property(front_layer, "modulate:a", 0.0, open_box_fade_duration)


func _sort_landed_package(package: Node2D, generation: int) -> void:
	if _events_running and generation == _event_generation and is_instance_valid(package):
		package.z_index = landed_package_z_index


func _remove_box_shadow(box_shadow: AnimatedSprite2D) -> void:
	if is_instance_valid(box_shadow):
		box_shadow.queue_free()


func _crush_penguins_at(target: Vector2) -> void:
	var player_container := get_parent().get_node_or_null("Players")
	if player_container == null:
		return
	for character in player_container.get_children():
		for child in character.get_children():
			if not child is Penguin:
				continue
			var penguin := child as Penguin
			if penguin.is_dead or penguin.is_eliminated or not is_instance_valid(penguin.feet_marker):
				continue
			if penguin.feet_marker.global_position.distance_to(target) <= crush_radius:
				penguin.lose_life(false, true)


func _get_screen_top_y() -> float:
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return _get_ice_bounds().position.y - 300.0
	var half_view_height := get_viewport_rect().size.y / maxf(camera.zoom.y * 2.0, 0.001)
	return camera.get_screen_center_position().y - half_view_height


func _get_ice_edge_fade(point: Vector2) -> float:
	if _plane_ice_polygon.size() < 3 or not Geometry2D.is_point_in_polygon(point, _plane_ice_polygon):
		return 0.0
	var nearest_edge_distance := INF
	for index in range(_plane_ice_polygon.size()):
		var start := _plane_ice_polygon[index]
		var end := _plane_ice_polygon[(index + 1) % _plane_ice_polygon.size()]
		var segment := end - start
		var length_squared := segment.length_squared()
		var fraction := 0.0
		if length_squared > 0.0:
			fraction = clampf((point - start).dot(segment) / length_squared, 0.0, 1.0)
		var closest_point := start + segment * fraction
		nearest_edge_distance = minf(nearest_edge_distance, point.distance_to(closest_point))
	var progress := clampf(nearest_edge_distance / maxf(airplane_edge_fade_distance, 0.001), 0.0, 1.0)
	return progress * progress * (3.0 - 2.0 * progress)


func _get_ice_polygon() -> PackedVector2Array:
	var ground := get_parent().get_node_or_null("Arena/IceArea/Ground") as CollisionPolygon2D
	if ground == null:
		return PackedVector2Array()
	var polygon := PackedVector2Array()
	for point in ground.polygon:
		polygon.append(ground.to_global(point))
	return polygon


func _get_ice_bounds() -> Rect2:
	var ground := get_parent().get_node_or_null("Arena/IceArea/Ground") as CollisionPolygon2D
	if ground == null or ground.polygon.is_empty():
		return Rect2()
	var first := ground.to_global(ground.polygon[0])
	var bounds := Rect2(first, Vector2.ZERO)
	for index in range(1, ground.polygon.size()):
		bounds = bounds.expand(ground.to_global(ground.polygon[index]))
	return bounds
