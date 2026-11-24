extends Node2D

const EMISSION_INTERVAL := 0.55
const RING_LIFETIME := 0.95
const RING_SEGMENTS := 48
const HALF_SEGMENTS := 24
const START_RADIUS := 20.0
# Keep the entire ripple comfortably inside the orca-to-ice gap.
const MAX_RADIUS := 64.0
const VERTICAL_SCALE := 0.54
const MIN_SURFACE_SCALE := 0.35

var _elapsed := 0.0
var _next_emission := EMISSION_INTERVAL
var _emitting := true
var _ring_birth_times: Array[float] = [0.0]
var draw_front_half := false
var surface_amount := 0.0
var ripple_scale := 1.0


func _process(delta: float) -> void:
	_elapsed += delta
	if _emitting and _elapsed >= _next_emission:
		_ring_birth_times.append(_elapsed)
		_next_emission += EMISSION_INTERVAL
	for index in range(_ring_birth_times.size() - 1, -1, -1):
		if _elapsed - _ring_birth_times[index] >= RING_LIFETIME:
			_ring_birth_times.remove_at(index)
	if not _emitting and _ring_birth_times.is_empty():
		queue_free()
		return
	queue_redraw()


func stop_emitting() -> void:
	_emitting = false


func set_surface_amount(amount: float) -> void:
	surface_amount = clampf(amount, 0.0, 1.0)
	queue_redraw()


func _draw() -> void:
	var surface_scale := lerpf(MIN_SURFACE_SCALE, 1.0, surface_amount)
	for birth_time in _ring_birth_times:
		var age := _elapsed - birth_time
		var progress := clampf(age / RING_LIFETIME, 0.0, 1.0)
		var eased_progress := 1.0 - pow(1.0 - progress, 2.0)
		var radius := lerpf(START_RADIUS, MAX_RADIUS, eased_progress) * surface_scale * ripple_scale
		var opacity := sin(progress * PI)
		var points := PackedVector2Array()
		var first_segment := 0 if draw_front_half else HALF_SEGMENTS
		var last_segment := HALF_SEGMENTS if draw_front_half else RING_SEGMENTS
		for point_index in range(first_segment, last_segment + 1):
			var angle := TAU * float(point_index) / RING_SEGMENTS
			var wobble := sin(angle * 4.0 + _elapsed * 3.0) * 2.4
			wobble += sin(angle * 7.0 - _elapsed * 2.2) * 1.2
			var wave_radius := radius + wobble * surface_scale * ripple_scale
			points.append(Vector2(cos(angle) * wave_radius, sin(angle) * wave_radius * VERTICAL_SCALE))
		draw_polyline(points, Color(0.58, 0.88, 1.0, opacity * 0.10), 4.0 * ripple_scale, true)
		draw_polyline(points, Color(0.86, 0.97, 1.0, opacity * 0.34), 1.5 * ripple_scale, true)
