@tool
extends WeaponBase
class_name MeleeWeapon

signal charge_progress_changed(progress: float, visible: bool)

@onready var hitbox: Area2D = $Hitbox
@onready var hit_audio: AudioStreamPlayer = $HitAudio
@onready var swing_audio: AudioStreamPlayer = $SwingAudio
@onready var charge_audio: AudioStreamPlayer = $ChargeAudio
@onready var charged_audio: AudioStreamPlayer = $ChargedAudio

@export var impact_sound: AudioStream
@export var swing_sound: AudioStream
@export var charge_loop_sound: AudioStream
@export var charged_sound: AudioStream
@export var charged_wave_scene: PackedScene
@export_range(0.25, 4.0, 0.05) var charge_duration := 1.4
@export_range(32.0, 512.0, 8.0) var charge_area_radius := 176.0
@export_range(0.0, 200.0, 1.0) var charge_damage := 60.0
@export_range(0.0, 1200.0, 10.0) var charge_knockback := 700.0
@export_range(0.0, 30.0, 0.5) var charge_camera_shake := 16.0

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
var is_charging := false
var charge_elapsed := 0.0
var charge_ready := false
var charged_swing_pending := false

const MAX_CHARGED_ATTACK_DAMAGE := 70.0

@export_category("Swing Preview")
## Assign the same MeleeWeaponData as the penguin's Starting Weapon Data.
@export var preview_weapon_data: MeleeWeaponData
## Scrub the swing in the editor: 0 = rest, 1 = finished. Uses Preview Direction.
@export_range(0.0, 1.0, 0.01) var preview_swing_progress: float = 0.0


func _ready() -> void:
	if not charge_audio.finished.is_connected(_on_charge_audio_finished):
		charge_audio.finished.connect(_on_charge_audio_finished)


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
	var multiplayer_input = get_node("/root/MultiplayerInput")
	if is_charging:
		if multiplayer_input.is_action_pressed(device, "attack"):
			update_charge(_delta)
		elif multiplayer_input.is_action_just_released(device, "attack"):
			finish_charge()
	elif can_attack and multiplayer_input.is_action_just_pressed(device, "attack"):
		begin_charge()


func begin_charge() -> void:
	if not can_attack or melee_data == null or not is_instance_valid(wielder):
		return
	is_charging = true
	charge_elapsed = 0.0
	charge_ready = false
	charge_progress_changed.emit(0.0, true)
	if charge_loop_sound != null:
		charge_audio.stream = charge_loop_sound
		charge_audio.pitch_scale = 0.8
		charge_audio.play()


func _on_charge_audio_finished() -> void:
	if is_charging and charge_loop_sound != null:
		charge_audio.play()


func update_charge(delta: float) -> void:
	charge_elapsed = minf(charge_elapsed + delta, maxf(charge_duration, 0.01))
	var progress := charge_progress()
	charge_progress_changed.emit(progress, true)
	if charge_audio.playing:
		charge_audio.pitch_scale = lerpf(0.8, 1.55, progress)
	if progress >= 1.0 and not charge_ready:
		charge_ready = true
		charge_audio.stop()
		if charged_sound != null:
			charged_audio.stream = charged_sound
		if charged_audio.stream != null:
			charged_audio.play()


func charge_progress() -> float:
	return clampf(charge_elapsed / maxf(charge_duration, 0.01), 0.0, 1.0)


func finish_charge() -> void:
	if not is_charging:
		return
	var full_charge := charge_ready
	is_charging = false
	charge_ready = false
	charge_audio.stop()
	if full_charge:
		charge_progress_changed.emit(1.0, true)
		charged_swing_pending = true
		attack()
		_hide_charge_meter_after_flash()
	else:
		charge_progress_changed.emit(0.0, false)
		attack()


func _hide_charge_meter_after_flash() -> void:
	await get_tree().create_timer(0.18).timeout
	charge_progress_changed.emit(0.0, false)

func try_attack() -> void:
	if not can_attack or melee_data == null:
		return

	attack()


func attack() -> void:
	if not can_attack or melee_data == null or not is_instance_valid(wielder):
		return
	can_attack = false
	if swing_sound != null:
		swing_audio.stream = swing_sound
		swing_audio.play()
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
		if charged_swing_pending:
			charged_swing_pending = false
			perform_charged_attack()
		else:
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
		if accepted == true and target is Penguin:
			if impact_sound != null:
				hit_audio.stream = impact_sound
				hit_audio.play()
			if melee_data.knockback > 0.0:
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
	cancel_charge()
	charged_swing_pending = false
	if swing_time_left > 0.0:
		restore_resting_pose()
	swing_time_left = 0.0
	hit_targets.clear()


func cancel_charge() -> void:
	if not is_charging:
		return
	is_charging = false
	charge_ready = false
	charge_audio.stop()
	charge_progress_changed.emit(0.0, false)


func perform_charged_attack() -> void:
	if melee_data == null or not is_instance_valid(wielder):
		return
	var impact_point := hitbox.global_position
	if charged_wave_scene != null and is_instance_valid(wielder.get_parent()):
		var wave := charged_wave_scene.instantiate() as Node2D
		wielder.get_parent().add_child(wave)
		wave.global_position = impact_point
	var query := PhysicsShapeQueryParameters2D.new()
	var area_shape := CircleShape2D.new()
	area_shape.radius = charge_area_radius
	query.shape = area_shape
	query.transform = Transform2D(0.0, impact_point)
	query.collision_mask = hitbox.collision_mask
	query.exclude = [wielder.get_rid()]
	var hit_targets_once: Dictionary = {}
	for result in get_world_2d().direct_space_state.intersect_shape(query, 64):
		var target = result.collider
		if target == wielder or not target is Penguin:
			continue
		var target_id: int = target.get_instance_id()
		if hit_targets_once.has(target_id):
			continue
		hit_targets_once[target_id] = true
		var away_direction: Vector2 = target.global_position - impact_point
		if away_direction.is_zero_approx():
			away_direction = aim_direction
		var effective_charge_damage: float = minf(
			charge_damage * maxf(wielder.melee_power, 0.0),
			MAX_CHARGED_ATTACK_DAMAGE
		)
		var accepted = target.receive_damage(effective_charge_damage, wielder, away_direction.normalized())
		if accepted == true:
			if charge_knockback > 0.0:
				target.receive_push(away_direction.normalized(), charge_knockback)
	if charge_camera_shake > 0.0:
		var camera := get_viewport().get_camera_2d()
		if camera != null and camera.has_method("request_shake"):
			camera.request_shake(charge_camera_shake, 0.32)

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
