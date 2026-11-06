@tool
extends WeaponBase
class_name RangedWeapon

signal ammo_changed(current_ammo: int, capacity: int)
signal reload_changed(is_reloading: bool, progress: float)

var ranged_data: RangedWeaponData
@export var shot_sound: AudioStream
@onready var shot_audio: AudioStreamPlayer = $ShotAudio
var current_ammo := 0
var burst_shots_left := 0
var burst_recovery_left := 0.0
var reload_time_left := 0.0
var magazine_enabled := false


func setup(p_device: int, p_weapon_data: WeaponData) -> void:
	super.setup(p_device, p_weapon_data)

	ranged_data = p_weapon_data as RangedWeaponData
	magazine_enabled = ranged_data.magazine_capacity > 0
	if magazine_enabled:
		current_ammo = ranged_data.magazine_capacity
		burst_shots_left = 0
		burst_recovery_left = 0.0
		reload_time_left = 0.0
		ammo_changed.emit(current_ammo, ranged_data.magazine_capacity)
		reload_changed.emit(false, 0.0)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		super._process(delta)
		return
	if ranged_data == null:
		return
	if magazine_enabled:
		_process_magazine(delta)
		return

	if ranged_data.automatic:
		if get_node("/root/MultiplayerInput").is_action_pressed(device, "attack"):
			try_attack()
	else:
		if get_node("/root/MultiplayerInput").is_action_just_pressed(device, "attack"):
			try_attack()


func _process_magazine(delta: float) -> void:
	if reload_time_left > 0.0:
		reload_time_left = maxf(reload_time_left - delta, 0.0)
		var progress := 1.0 - reload_time_left / ranged_data.reload_duration
		reload_changed.emit(true, progress)
		if reload_time_left == 0.0:
			current_ammo = ranged_data.magazine_capacity
			ammo_changed.emit(current_ammo, ranged_data.magazine_capacity)
			reload_changed.emit(false, 1.0)
		return
	if burst_recovery_left > 0.0:
		burst_recovery_left = maxf(burst_recovery_left - delta, 0.0)
		if burst_recovery_left > 0.0:
			return
	if burst_shots_left > 0:
		if can_attack:
			attack()
		return
	if ranged_data.automatic:
		if get_node("/root/MultiplayerInput").is_action_pressed(device, "attack"):
			try_attack()
	else:
		if get_node("/root/MultiplayerInput").is_action_just_pressed(device, "attack"):
			try_attack()


func try_attack() -> void:
	if not can_attack or ranged_data == null or ranged_data.projectile_scene == null:
		return
	if magazine_enabled:
		if reload_time_left > 0.0 or burst_recovery_left > 0.0:
			return
		if current_ammo <= 0:
			begin_reload()
			return
		if burst_shots_left <= 0:
			burst_shots_left = mini(ranged_data.burst_size, current_ammo)

	attack()


func attack() -> void:
	if ranged_data == null or ranged_data.projectile_scene == null:
		return
	if magazine_enabled:
		if reload_time_left > 0.0 or current_ammo <= 0:
			return
		if burst_shots_left <= 0:
			burst_shots_left = mini(ranged_data.burst_size, current_ammo)
	var instance := ranged_data.projectile_scene.instantiate()
	if not instance is Projectile:
		instance.free()
		push_error("Ranged weapons require a Projectile scene")
		return
	var projectile := instance as Projectile
	var spread := get_effective_spread()
	var shot_direction := aim_direction.rotated(randf_range(-spread, spread))
	projectile.initialize(
		get_tree().current_scene,
		get_muzzle_global_position(),
		shot_direction,
		wielder,
		ranged_data.projectile_speed,
		ranged_data.damage
	)
	if shot_sound != null:
		shot_audio.stream = shot_sound
		shot_audio.play()
	start_cooldown()
	if magazine_enabled:
		current_ammo -= 1
		burst_shots_left -= 1
		ammo_changed.emit(current_ammo, ranged_data.magazine_capacity)
		if burst_shots_left == 0:
			if current_ammo == 0:
				begin_reload()
			else:
				burst_recovery_left = ranged_data.burst_pause


func begin_reload() -> void:
	if not magazine_enabled or reload_time_left > 0.0:
		return
	burst_shots_left = 0
	burst_recovery_left = 0.0
	reload_time_left = maxf(ranged_data.reload_duration, 0.1)
	reload_changed.emit(true, 0.0)

func get_muzzle_global_position() -> Vector2:
	var direction_name: String = POSE_DIRECTIONS[posmod(roundi(Vector2(direction_8).angle() / (PI / 4.0)), 8)]
	for pose in get_directional_poses():
		if pose == null or pose.get("direction") != direction_name or pose.get("use_muzzle_offset") != true:
			continue
		var point: Vector2 = pose.muzzle_offset
		# Account for sprite drawing settings, then follow the live body transform,
		# including socket movement from dash animations and character scaling.
		if not body.centered:
			var texture := body.sprite_frames.get_frame_texture(body.animation, body.frame)
			point += texture.get_size() * 0.5
		point += body.offset
		if body.flip_h:
			point.x = -point.x
		if body.flip_v:
			point.y = -point.y
		return body.to_global(point)
	return global_position + aim_direction * ranged_data.muzzle_distance

func get_attack_cooldown() -> float:
	var multiplier: float = wielder.ranged_attack_speed if wielder is Penguin else 1.0
	return super.get_attack_cooldown() / maxf(multiplier, 0.1)

func get_effective_spread() -> float:
	var handling: float = wielder.ranged_handling if wielder is Penguin else 1.0
	return maxf(ranged_data.spread, 0.0) / maxf(handling, 0.1)
