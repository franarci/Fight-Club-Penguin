@tool
extends MeleeWeapon
class_name HarpoonWeapon

@export_category("Harpoon")
@export_range(1.0, 32.0, 1.0) var projectile_radius := 6.0
@export_range(32.0, 512.0, 8.0) var projectile_range := 176.0
@export_range(32.0, 1600.0, 16.0) var projectile_speed := 640.0
@export_range(32.0, 1600.0, 16.0) var return_speed := 800.0
@export_range(0.0, 1000.0, 10.0) var pull_speed := 210.0
@export_range(0.0, 32.0, 1.0) var stab_windup_distance := 6.0
@export var harpoon_projectile_scene: PackedScene

var harpoon_projectile: Node2D
var stab_elapsed := 0.0
var stab_windup := 0.0
var stab_active_duration := 0.0
var stab_total_duration := 0.0
var stab_reach := 0.0
var stab_active := false
var resting_body_scale := Vector2.ONE
var attack_body_position := Vector2.ZERO

const ATTACK_SIZE_FACTORS := {
	&"attack_right": 1.45,
	&"attack_down_right": 1.42,
	&"attack_down": 1.41,
	&"attack_down_left": 1.44,
	&"attack_left": 1.45,
	&"attack_up_left": 1.44,
	&"attack_up": 1.60,
	&"attack_up_right": 1.06,
}

const ATTACK_GRIP_OFFSETS := {
	&"attack_right": Vector2(-46, 1),
	&"attack_down_right": Vector2(-27, -22),
	&"attack_down": Vector2(4, -29),
	&"attack_down_left": Vector2(30, -11),
	&"attack_left": Vector2(49, 2),
	&"attack_up_left": Vector2(32, 15),
	&"attack_up": Vector2(6, 63),
	&"attack_up_right": Vector2(-14, 23),
}


func attack() -> void:
	if not can_attack or melee_data == null or not is_instance_valid(wielder):
		return
	can_attack = false
	if swing_sound != null:
		swing_audio.stream = swing_sound
		swing_audio.play()
	swing_direction = aim_direction.normalized()
	pending_aim = aim_direction
	resting_body_scale = body.scale
	capture_resting_pose()
	stab_windup = maxf(melee_data.windup_duration, 0.0)
	stab_active_duration = maxf(melee_data.attack_duration, 0.001)
	stab_total_duration = stab_windup + stab_active_duration + maxf(melee_data.recovery_duration, 0.0)
	stab_reach = maxf(melee_data.attack_range, 0.0)
	stab_elapsed = 0.0
	swing_time_left = stab_total_duration
	stab_active = false
	hit_targets.clear()
	attack_shape.radius = melee_data.hit_radius
	update_hitbox(swing_direction)
	var animation_name := _directional_animation_name("attack", swing_direction)
	if body.sprite_frames.has_animation(animation_name):
		var size_factor: float = ATTACK_SIZE_FACTORS.get(animation_name, 1.0)
		body.scale = resting_body_scale * size_factor
		var attack_grip: Vector2 = ATTACK_GRIP_OFFSETS.get(animation_name, get_current_grip_offset())
		if resting_flip_h:
			attack_grip.x = -attack_grip.x
		if resting_flip_v:
			attack_grip.y = -attack_grip.y
		var hand_position := resting_body_position + swing_grip.rotated(resting_body_rotation)
		attack_body_position = hand_position - (attack_grip * body.scale).rotated(resting_body_rotation)
		body.position = attack_body_position
		body.play(animation_name)


func finish_charge() -> void:
	if not is_charging:
		return
	var full_charge := charge_ready
	is_charging = false
	charge_ready = false
	charge_audio.stop()
	if full_charge:
		charge_progress_changed.emit(1.0, true)
		launch_harpoon()
		_hide_charge_meter_after_flash()
	else:
		charge_progress_changed.emit(0.0, false)
		attack()


func launch_harpoon() -> void:
	if not can_attack or not is_instance_valid(wielder) or harpoon_projectile_scene == null:
		return
	can_attack = false
	play_charged_impact_sound()
	swing_direction = aim_direction.normalized()
	var origin := body.global_position
	var rope_anchor_offset := get_current_grip_offset()
	body.hide()
	harpoon_projectile = harpoon_projectile_scene.instantiate() as Node2D
	add_child(harpoon_projectile)
	harpoon_projectile.call(
		"launch",
		self,
		wielder,
		origin,
		swing_direction,
		melee_data.sprite_frames,
		projectile_radius,
		projectile_range,
		projectile_speed,
		return_speed,
		pull_speed,
		get_effective_damage(),
		hitbox.collision_mask,
		rope_anchor_offset
	)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or swing_time_left <= 0.0:
		return
	if not is_instance_valid(wielder) or not wielder.is_visible_in_tree():
		cancel_attack()
		return
	var previous_elapsed := stab_elapsed
	stab_elapsed = minf(stab_elapsed + delta, stab_total_duration)
	swing_time_left = maxf(stab_total_duration - stab_elapsed, 0.0)
	_update_stab_visual(stab_elapsed)
	update_hitbox(swing_direction)
	var impact_time := stab_windup + stab_active_duration * 0.75
	if stab_elapsed >= impact_time and previous_elapsed < impact_time:
		stab_active = true
		apply_swing_hits()
	if stab_elapsed >= stab_windup + stab_active_duration:
		stab_active = false
	if swing_time_left == 0.0:
		restore_resting_pose()
		body.scale = resting_body_scale
		super.set_aim_direction(pending_aim)
		start_cooldown()


func _directional_animation_name(prefix: String, direction: Vector2) -> StringName:
	var step := PI / 4.0
	var index := posmod(roundi(direction.angle() / step), 8)
	var directions := ["right", "down_right", "down", "down_left", "left", "up_left", "up", "up_right"]
	return StringName(prefix + "_" + directions[index])


func _update_stab_visual(elapsed: float) -> void:
	var displacement := 0.0
	if elapsed < stab_windup:
		if stab_windup > 0.0:
			displacement = -stab_windup_distance * smoothstep(0.0, stab_windup, elapsed)
	elif elapsed < stab_windup + stab_active_duration:
		var strike_progress := clampf((elapsed - stab_windup) / stab_active_duration, 0.0, 1.0)
		displacement = lerpf(
			-stab_windup_distance,
			stab_reach,
			smoothstep(0.0, 1.0, strike_progress)
		)
	elif stab_total_duration > stab_windup + stab_active_duration:
		var recovery_progress := clampf(
			(elapsed - stab_windup - stab_active_duration) / (stab_total_duration - stab_windup - stab_active_duration),
			0.0,
			1.0
		)
		displacement = lerpf(stab_reach, 0.0, smoothstep(0.0, 1.0, recovery_progress))
	var local_offset := to_local(global_position + swing_direction * displacement)
	body.position = attack_body_position + local_offset


func get_hand_global_position() -> Vector2:
	return body.to_global(get_current_grip_offset() * body.scale)


func get_current_grip_offset() -> Vector2:
	var direction_index := posmod(roundi(Vector2(direction_8).angle() / (PI / 4.0)), 8)
	var direction_name: String = POSE_DIRECTIONS[direction_index]
	var grip_offset := Vector2.ZERO
	for pose in get_directional_poses():
		if pose != null and pose.get("direction") == direction_name:
			grip_offset = pose.grip_offset
			break
	if body.flip_h:
		grip_offset.x = -grip_offset.x
	if body.flip_v:
		grip_offset.y = -grip_offset.y
	return grip_offset


func on_harpoon_returned(projectile: Node) -> void:
	if projectile != harpoon_projectile:
		return
	harpoon_projectile = null
	if is_instance_valid(body):
		body.show()
	if is_instance_valid(wielder) and not wielder.is_dead:
		start_cooldown()


func cancel_attack() -> void:
	var was_stabbing := swing_time_left > 0.0
	super.cancel_attack()
	stab_active = false
	stab_elapsed = 0.0
	if is_instance_valid(harpoon_projectile):
		harpoon_projectile.queue_free()
	harpoon_projectile = null
	if is_instance_valid(body):
		body.show()
		if was_stabbing:
			body.scale = resting_body_scale
	swing_time_left = 0.0
