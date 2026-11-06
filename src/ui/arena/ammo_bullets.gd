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


func configure(p_capacity: int, p_current_ammo: int, p_align_right: bool) -> void:
	capacity = maxi(p_capacity, 0)
	current_ammo = clampi(p_current_ammo, 0, capacity)
	align_right = p_align_right
	update_minimum_size()
	queue_redraw()


func set_current_ammo(value: int) -> void:
	current_ammo = value


func _get_minimum_size() -> Vector2:
	var count := maxi(capacity, 0)
	var width := count * bullet_size.x + maxi(count - 1, 0) * bullet_gap
	return Vector2(width, bullet_size.y)


func _draw() -> void:
	if filled_bullet == null or empty_bullet == null or bullet_region.size.x <= 0.0 or bullet_region.size.y <= 0.0:
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
