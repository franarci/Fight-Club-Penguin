extends Node2D
class_name HarpoonProjectile

@onready var body: AnimatedSprite2D = $Body
@onready var rope_outline: Line2D = $RopeOutline
@onready var rope: Line2D = $Rope

var harpoon_weapon: Node2D
var wielder: Penguin
var flight_direction := Vector2.RIGHT
var max_range := 176.0
var traveled := 0.0
var flight_speed := 640.0
var return_speed := 800.0
var pull_strength := 210.0
var damage := 40.0
var collision_mask := 1
var returning := false
var rope_anchor_offset := Vector2.ZERO
var hit_shape := CircleShape2D.new()


func _ready() -> void:
	for line in [rope_outline, rope]:
		line.set_as_top_level(true)
		line.global_transform = Transform2D.IDENTITY


func launch(
	p_weapon: Node2D,
	p_wielder: Penguin,
	start_position: Vector2,
	p_direction: Vector2,
	frames: SpriteFrames,
	p_radius: float,
	p_range: float,
	p_speed: float,
	p_return_speed: float,
	p_pull_strength: float,
	p_damage: float,
	p_collision_mask: int,
	p_rope_anchor_offset: Vector2
) -> void:
	harpoon_weapon = p_weapon
	wielder = p_wielder
	flight_direction = p_direction.normalized()
	max_range = p_range
	flight_speed = p_speed
	return_speed = p_return_speed
	pull_strength = p_pull_strength
	damage = p_damage
	collision_mask = p_collision_mask
	rope_anchor_offset = p_rope_anchor_offset
	hit_shape.radius = p_radius
	set_as_top_level(true)
	global_position = start_position
	global_scale = p_weapon.global_scale
	body.sprite_frames = frames
	body.play(_idle_animation_name(flight_direction))
	show()
	_update_rope()


func _physics_process(delta: float) -> void:
	if not is_instance_valid(wielder) or not is_instance_valid(harpoon_weapon) or wielder.is_dead:
		queue_free()
		return
	if returning:
		return_to_hand(delta)
		_update_rope()
		return
	var step := minf(flight_speed * delta, maxf(max_range - traveled, 0.0))
	var next_position := global_position + flight_direction * step
	var target := find_target(next_position)
	global_position = next_position
	traveled += step
	_update_rope()
	if target != null:
		hook_target(target)
		returning = true
	elif traveled >= max_range:
		returning = true


func find_target(candidate_position: Vector2) -> Penguin:
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = hit_shape
	query.transform = Transform2D(0.0, candidate_position)
	query.collision_mask = collision_mask
	query.exclude = [wielder.get_rid()]
	for result in get_world_2d().direct_space_state.intersect_shape(query, 32):
		var target = result.collider
		if target is Penguin and target != wielder:
			return target
	return null


func hook_target(target: Penguin) -> void:
	var accepted := target.receive_damage(damage, wielder, flight_direction)
	if accepted and pull_strength > 0.0:
		var pull_direction := wielder.global_position - target.global_position
		if not pull_direction.is_zero_approx():
			target.receive_push(pull_direction.normalized(), pull_strength)


func return_to_hand(delta: float) -> void:
	var hand_position: Vector2 = harpoon_weapon.call("get_hand_global_position")
	var anchor_offset_world := body.to_global(rope_anchor_offset) - global_position
	var target_position := hand_position - anchor_offset_world
	var step := return_speed * delta
	global_position = global_position.move_toward(target_position, step)
	if global_position.distance_squared_to(target_position) <= maxf(step, 4.0) * maxf(step, 4.0):
		harpoon_weapon.call("on_harpoon_returned", self)
		queue_free()


func _update_rope() -> void:
	if not is_instance_valid(harpoon_weapon):
		return
	var hand_position: Vector2 = harpoon_weapon.call("get_hand_global_position")
	var anchor_position := body.to_global(rope_anchor_offset)
	for line in [rope_outline, rope]:
		if line.get_point_count() != 2:
			line.clear_points()
			line.add_point(Vector2.ZERO)
			line.add_point(Vector2.ZERO)
		line.set_point_position(0, hand_position)
		line.set_point_position(1, anchor_position)


func _idle_animation_name(direction: Vector2) -> StringName:
	var directions := ["right", "down_right", "down", "down_left", "left", "up_left", "up", "up_right"]
	var index := posmod(roundi(direction.angle() / (PI / 4.0)), 8)
	return StringName("idle_" + directions[index])
