extends WeaponBase
class_name RangedWeapon


var ranged_data: RangedWeaponData


func setup(p_device: int, p_weapon_data: WeaponData) -> void:
	super.setup(p_device, p_weapon_data)

	ranged_data = p_weapon_data as RangedWeaponData


func _process(_delta: float) -> void:
	if ranged_data == null:
		return

	if ranged_data.automatic:
		if MultiplayerInput.is_action_pressed(device, "attack"):
			try_attack()
	else:
		if MultiplayerInput.is_action_just_pressed(device, "attack"):
			try_attack()


func try_attack() -> void:
	if not can_attack:
		return

	attack()


func attack() -> void:
	var projectile = ranged_data.projectile_scene.instantiate()

	get_tree().current_scene.add_child(projectile)

	projectile.global_position = (
		global_position
		+ aim_direction * ranged_data.muzzle_distance
	)

	projectile.setup(
		aim_direction,
		ranged_data.projectile_speed,
		ranged_data.damage
	)

	start_cooldown()
