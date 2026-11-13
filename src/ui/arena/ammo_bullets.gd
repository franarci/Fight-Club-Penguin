@tool
extends Control
class_name AmmoBullets

@export_range(0, 100, 1) var capacity := 12:
	set(value):
		capacity = maxi(value, 0)
		update_minimum_size()
		queue_redraw()
@export_range(0, 100, 1) var current_ammo := 12:
	set(value):
		current_ammo = clampi(value, 0, capacity)
		queue_redraw()
@export var filled_bullet: Texture2D = preload("res://assets/ui/bullet.png"):
	set(value):
		filled_bullet = value
		queue_redraw()
@export var empty_bullet: Texture2D = preload("res://assets/ui/empty-bullet.png"):
	set(value):
		empty_bullet = value
		queue_redraw()
@export var bullet_region := Rect2(542.0, 0.0, 216.0, 1126.0):
	set(value):
		bullet_region = value
		queue_redraw()
@export var bullet_size := Vector2(8.0, 30.0):
	set(value):
		bullet_size = value.max(Vector2.ONE)
		update_minimum_size()
		queue_redraw()
@export_range(0.0, 20.0, 0.5) var bullet_gap := 2.0:
	set(value):
		bullet_gap = maxf(value, 0.0)
		update_minimum_size()
		queue_redraw()
@export var align_right := false:
	set(value):
		align_right = value
		queue_redraw()
@export var single_bullet_mode := false:
	set(value):
		single_bullet_mode = value
		update_minimum_size()
		queue_redraw()

var recharge_progress := 1.0


func configure(p_capacity: int, p_current_ammo: int, p_align_right: bool) -> void:
	capacity = maxi(p_capacity, 0)
	current_ammo = clampi(p_current_ammo, 0, capacity)
	if single_bullet_mode:
		recharge_progress = 1.0 if current_ammo > 0 else 0.0
	align_right = p_align_right
	update_minimum_size()
	queue_redraw()


func set_current_ammo(value: int) -> void:
	current_ammo = value
	if single_bullet_mode:
		recharge_progress = 1.0 if current_ammo > 0 else 0.0
		queue_redraw()


func set_recharge_progress(value: float) -> void:
	recharge_progress = clampf(value, 0.0, 1.0)
	queue_redraw()


func _get_minimum_size() -> Vector2:
	if single_bullet_mode:
		return Vector2(112.0, 24.0)
	var count := maxi(capacity, 0)
	var width := count * bullet_size.x + maxi(count - 1, 0) * bullet_gap
	return Vector2(width, bullet_size.y)


func _draw() -> void:
	if filled_bullet == null or empty_bullet == null or bullet_region.size.x <= 0.0 or bullet_region.size.y <= 0.0:
		return
	if single_bullet_mode:
		_draw_single_bullet()
		return
	var count := maxi(capacity, 0)
	var slot_width := bullet_size.x + bullet_gap
	var total_width := count * bullet_size.x + maxi(count - 1, 0) * bullet_gap
	var start_x := size.x - total_width if align_right else 0.0
	var start_y := (size.y - bullet_size.y) * 0.5
	var sprite_width := minf(bullet_size.x, bullet_size.y * bullet_region.size.x / bullet_region.size.y)
	for index in count:
		var texture := filled_bullet if index < current_ammo else empty_bullet
		var x := start_x + index * slot_width + (bullet_size.x - sprite_width) * 0.5
		var destination := Rect2(Vector2(x, start_y), Vector2(sprite_width, bullet_size.y))
		draw_texture_rect_region(texture, destination, bullet_region, Color.WHITE, false, true)


func _draw_single_bullet() -> void:
	# The shared UI sprite is vertical. Rotate it around its center to create one
	# large horizontal round, then reveal the gold fill from left to right.
	var aspect := bullet_region.size.y / bullet_region.size.x
	var draw_width := minf(size.x - 8.0, (size.y - 2.0) * aspect)
	if draw_width <= 0.0:
		return
	var draw_height := draw_width / aspect
	var center := size * 0.5
	draw_set_transform(center, -PI * 0.5)
	var full_rect := Rect2(Vector2(-draw_height * 0.5, -draw_width * 0.5), Vector2(draw_height, draw_width))
	# A muted version of the round remains visible while it is recharging.
	draw_texture_rect_region(filled_bullet, full_rect, bullet_region, Color(0.35, 0.41, 0.5, 0.95), false, true)
	var progress := 1.0 if current_ammo > 0 else recharge_progress
	if progress > 0.0:
		var source := Rect2(bullet_region.position, Vector2(bullet_region.size.x, bullet_region.size.y * progress))
		var fill_rect := Rect2(full_rect.position, Vector2(draw_height, draw_width * progress))
		draw_texture_rect_region(filled_bullet, fill_rect, source, Color.WHITE, false, true)
	draw_set_transform(Vector2.ZERO, 0.0)
