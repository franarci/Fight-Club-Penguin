@tool
extends WeaponBase
class_name MeleeWeapon


@onready var hitbox: Area2D = $Hitbox

var melee_data: MeleeWeaponData
var swing_time_left := 0.0
var swing_direction := Vector2.RIGHT
var hit_targets: Dictionary = {}
var attack_shape := CircleShape2D.new()
var swing_elapsed := 0.0
var swing_windup := 0.0
var swing_active_duration := 0.0
var swing_recovery := 0.0
var resting_body_position := Vector2.ZERO
var resting_body_rotation := 0.0
var swing_grip := Vector2.ZERO
var pending_aim := Vector2.RIGHT
var resting_animation: StringName
var resting_flip_h := false
var resting_flip_v := false

@export_category("Swing Preview")
## Assign the same MeleeWeaponData as the penguin's Starting Weapon Data.
@export var preview_weapon_data: MeleeWeaponData
## Scrub the swing in the editor: 0 = rest, 1 = finished. Uses Preview Direction.
@export_range(0.0, 1.0, 0.01) var preview_swing_progress: float = 0.0


func setup(p_device: int, p_weapon_data: WeaponData) -> void:
	super.setup(p_device, p_weapon_data)

	melee_data = p_weapon_data as MeleeWeaponData

	hitbox.monitoring = false
	hitbox.collision_layer = 0
	hitbox.top_level = true
	if melee_data != null:
		attack_shape.radius = melee_data.hit_radius
		var collision := hitbox.get_node("CollisionShape2D") as CollisionShape2D
		collision.position = Vector2.ZERO
		collision.shape = attack_shape
		update_hitbox(aim_direction)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if not editor_preview_enabled:
			return
		if is_instance_valid(body):
			body.rotation = 0.0
		super._process(_delta)
		if is_instance_valid(body) and preview_weapon_data != null:
			capture_resting_pose()
			configure_swing_timing(preview_weapon_data)
			apply_swing_visual(preview_swing_progress * total_swing_duration(), preview_weapon_data)
		return
	if get_node("/root/MultiplayerInput").is_action_just_pressed(device, "attack"):
		try_attack()

func try_attack() -> void:
	if not can_attack or melee_data == null:
		return

	attack()


func attack() -> void:
	if not can_attack or melee_data == null or not is_instance_valid(wielder):
		return
	can_attack = false
	swing_direction = aim_direction
	pending_aim = aim_direction
	capture_resting_pose()
	configure_swing_timing(melee_data)
	swing_elapsed = 0.0
	swing_time_left = total_swing_duration()
	hit_targets.clear()
	attack_shape.radius = melee_data.hit_radius
	update_hitbox(swing_direction)
	apply_swing_visual(0.0, melee_data)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or swing_time_left <= 0.0:
		return
	if not is_instance_valid(wielder) or not wielder.is_visible_in_tree():
		cancel_attack()
		return
	var previous_elapsed := swing_elapsed
	swing_elapsed = minf(swing_elapsed + delta, total_swing_duration())
	swing_time_left = maxf(total_swing_duration() - swing_elapsed, 0.0)
	apply_swing_visual(swing_elapsed, melee_data)
	# Interval intersection also catches an impact window crossed by a long frame.
	if swing_elapsed >= swing_windup and previous_elapsed < swing_windup + swing_active_duration:
		update_hitbox(swing_direction)
		apply_swing_hits()
	if swing_time_left == 0.0:
		restore_resting_pose()
		super.set_aim_direction(pending_aim)
		start_cooldown()


func apply_swing_hits() -> void:
	# Include targets already overlapping when the damaging window opens.
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = attack_shape
	query.transform = hitbox.global_transform
	query.collision_mask = hitbox.collision_mask
	if wielder is CollisionObject2D:
		query.exclude = [wielder.get_rid()]
	for result in get_world_2d().direct_space_state.intersect_shape(query, 64):
		var target = result.collider
		if target == wielder or not target.has_method("receive_damage"):
			continue
		var target_id: int = target.get_instance_id()
		if hit_targets.has(target_id):
			continue
		hit_targets[target_id] = true
		var accepted = target.receive_damage(get_effective_damage(), wielder, swing_direction)
		if accepted == true and target is Penguin and melee_data.knockback > 0.0:
			target.receive_push(swing_direction, melee_data.knockback)


func update_hitbox(direction: Vector2) -> void:
	# World-space geometry: the hammer's 0.1 visual scale must not shrink reach.
	var origin := wielder.global_position if is_instance_valid(wielder) else global_position
	if is_instance_valid(wielder):
		var collision := wielder.get_node_or_null("Collision") as CollisionShape2D
		if collision != null:
			origin = collision.global_position
	hitbox.global_transform = Transform2D(0.0, origin + direction * melee_data.attack_range)


func cancel_attack() -> void:
	if swing_time_left > 0.0:
		restore_resting_pose()
	swing_time_left = 0.0
	hit_targets.clear()

func get_effective_damage() -> float:
	var power: float = wielder.melee_power if wielder is Penguin else 1.0
	return melee_data.damage * maxf(power, 0.0)


func set_aim_direction(direction: Vector2) -> void:
	if swing_time_left > 0.0:
		if direction != Vector2.ZERO:
			pending_aim = direction.normalized()
		return
	super.set_aim_direction(direction)
	if melee_data != null and swing_time_left <= 0.0:
		update_hitbox(aim_direction)


func configure_swing_timing(data: MeleeWeaponData) -> void:
	swing_windup = maxf(data.windup_duration, 0.0)
	swing_active_duration = maxf(data.attack_duration, 0.001)
	swing_recovery = maxf(data.recovery_duration, 0.0)

func total_swing_duration() -> float:
	return swing_windup + swing_active_duration + swing_recovery

func capture_resting_pose() -> void:
	resting_animation = body.animation
	resting_flip_h = body.flip_h
	resting_flip_v = body.flip_v
	resting_body_position = body.position
	resting_body_rotation = body.rotation
	swing_grip = Vector2.ZERO
	var direction_name: String = POSE_DIRECTIONS[posmod(roundi(Vector2(direction_8).angle() / (PI / 4.0)), 8)]
	for pose in get_directional_poses():
		if pose != null and pose.get("direction") == direction_name:
			swing_grip = pose.grip_offset
			break
	if body.flip_h:
		swing_grip.x = -swing_grip.x
	if body.flip_v:
		swing_grip.y = -swing_grip.y
	swing_grip *= body.scale

func apply_swing_visual(elapsed: float, data: MeleeWeaponData) -> void:
	var authored_animation: StringName = &""
	if direction_8.x == 0:
		authored_animation = &"attack_down" if direction_8.y > 0 else &"attack_up"
	if body.sprite_frames.has_animation(authored_animation) and body.sprite_frames.get_frame_count(authored_animation) > 0:
		apply_authored_swing(authored_animation, elapsed)
		return
	var angle: float
	if elapsed < swing_windup:
		angle = lerpf(0.0, data.windup_angle, smoothstep(0.0, swing_windup, elapsed))
	elif elapsed < swing_windup + swing_active_duration:
		var strike_duration := swing_active_duration * clampf(data.strike_fraction, 0.1, 1.0)
		angle = lerpf(data.windup_angle, data.impact_angle, smoothstep(0.0, strike_duration, elapsed - swing_windup))
	else:
		var progress := clampf((elapsed - swing_windup - swing_active_duration) / maxf(swing_recovery, 0.001), 0.0, 1.0)
		if data.recoil_angle > 0.0:
			var recoil := -signf(data.impact_angle) * data.recoil_angle
			if progress < 0.7:
				angle = lerpf(data.impact_angle, recoil, smoothstep(0.0, 0.7, progress))
			else:
				angle = lerpf(recoil, 0.0, smoothstep(0.7, 1.0, progress))
		else:
			angle = lerpf(data.impact_angle, 0.0, smoothstep(0.0, 1.0, progress))
	if elapsed >= total_swing_duration():
		angle = 0.0
	if direction_8.x < 0:
		angle = -angle
	body.rotation = resting_body_rotation + deg_to_rad(angle)
	var hand := resting_body_position + swing_grip.rotated(resting_body_rotation)
	body.position = hand - swing_grip.rotated(body.rotation)

func restore_resting_pose() -> void:
	body.position = resting_body_position
	body.rotation = resting_body_rotation
	body.flip_h = resting_flip_h
	body.flip_v = resting_flip_v
	if body.animation != resting_animation:
		body.play(resting_animation)

func apply_authored_swing(animation_name: StringName, elapsed: float) -> void:
	if elapsed >= total_swing_duration():
		restore_resting_pose()
		return
	# Authored vertical artwork supplies the movement; don't rotate or mirror it.
	body.position = resting_body_position
	body.rotation = resting_body_rotation
	body.flip_h = false
	body.flip_v = false
	body.animation = animation_name
	body.pause()
	var data := preview_weapon_data if Engine.is_editor_hint() else melee_data
	var strike_duration := swing_active_duration * clampf(data.strike_fraction, 0.1, 1.0)
	if animation_name == &"attack_down" and data.down_attack_frame_offsets.is_empty():
		var offset_weight := smoothstep(0.0, strike_duration, elapsed - swing_windup)
		if elapsed >= swing_windup + swing_active_duration:
			offset_weight = 1.0 - smoothstep(0.0, maxf(swing_recovery, 0.001), elapsed - swing_windup - swing_active_duration)
		body.position += data.down_attack_offset * offset_weight
	var count := body.sprite_frames.get_frame_count(animation_name)
	var frame_index := 0
	var progress := 0.0
	if elapsed >= swing_windup and count > 1:
		# Frame 0 is the wind-up. Remaining frames span the existing damage window.
		var duration := 0.0
		for i in range(1, count):
			duration += body.sprite_frames.get_frame_duration(animation_name, i)
		var cursor := clampf((elapsed - swing_windup) / strike_duration, 0.0, 1.0) * duration
		frame_index = count - 1
		progress = 1.0
		for i in range(1, count):
			var frame_duration := body.sprite_frames.get_frame_duration(animation_name, i)
			if cursor < frame_duration:
				frame_index = i
				progress = cursor / frame_duration
				break
			cursor -= frame_duration
	body.set_frame_and_progress(frame_index, progress)
	if animation_name == &"attack_down" and not data.down_attack_frame_offsets.is_empty():
		var offset_index := mini(frame_index, data.down_attack_frame_offsets.size() - 1)
		body.position = resting_body_position + data.down_attack_frame_offsets[offset_index]
