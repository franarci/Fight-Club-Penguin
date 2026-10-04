extends WeaponBase
class_name MeleeWeapon


@onready var hitbox: Area2D = $Hitbox

var melee_data: MeleeWeaponData


func setup(p_device: int, p_weapon_data: WeaponData) -> void:
	super.setup(p_device, p_weapon_data)

	melee_data = p_weapon_data as MeleeWeaponData

	hitbox.monitoring = false


func _process(_delta: float) -> void:
	if MultiplayerInput.is_action_just_pressed(device, "attack"):
		try_attack()


func try_attack() -> void:
	if not can_attack:
		return

	attack()


func attack() -> void:
	can_attack = false

	#play_attack_animation()

	hitbox.monitoring = true

	await get_tree().create_timer(
		melee_data.attack_duration
	).timeout

	hitbox.monitoring = false

	start_cooldown()
