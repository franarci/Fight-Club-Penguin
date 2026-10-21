@tool
extends WeaponBase
class_name RangedWeapon


var ranged_data: RangedWeaponData


func setup(p_device: int, p_weapon_data: WeaponData) -> void:
	super.setup(p_device, p_weapon_data)

	ranged_data = p_weapon_data as RangedWeaponData


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		super._process(_delta)
		return
	if ranged_data == null:
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

	attack()


func attack() -> void:
	if ranged_data == null or ranged_data.projectile_scene == null:
		return
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
		global_position + aim_direction * ranged_data.muzzle_distance,
		shot_direction,
		wielder,
		ranged_data.projectile_speed,
		ranged_data.damage
	)
	start_cooldown()

func get_attack_cooldown() -> float:
	var multiplier: float = wielder.ranged_attack_speed if wielder is Penguin else 1.0
	return super.get_attack_cooldown() / maxf(multiplier, 0.1)

func get_effective_spread() -> float:
	var handling: float = wielder.ranged_handling if wielder is Penguin else 1.0
	return maxf(ranged_data.spread, 0.0) / maxf(handling, 0.1)
