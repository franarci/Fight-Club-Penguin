extends Resource
class_name CharacterData

const SPEED_DISPLAY_MAX := 200.0
const DAMAGE_DISPLAY_MAX := 50.0
const MASS_DISPLAY_MAX := 2.0

var cached_profile: Dictionary = {}

@export var key: String
@export var Img: Texture2D
@export var selectable: bool = true

@export_category("Selection profile")
@export var character_scene: PackedScene:
	set(value):
		character_scene = value
		cached_profile.clear()
@export_range(0, 100, 1) var selection_speed: float = 50.0
@export_range(0, 100, 1) var selection_strength: float = 50.0
@export_range(0, 100, 1) var selection_resistance: float = 50.0


func get_selection_profile() -> Dictionary:
	if not cached_profile.is_empty():
		return cached_profile.duplicate()
	var profile := {"speed": selection_speed, "strength": selection_strength, "resistance": selection_resistance}
	if character_scene == null:
		return profile
	var character := character_scene.instantiate()
	var penguin := character.get_child(0)
	var weapon: WeaponData = penguin.get("starting_weapon_data")
	if weapon == null:
		var equipped := penguin.get_node_or_null("Weapon/EquippedWeapon")
		if equipped != null:
			weapon = equipped.get("default_weapon_data")
	var damage: float = weapon.damage if weapon != null else 0.0
	if weapon is MeleeWeaponData:
		damage *= float(penguin.get("melee_power"))
	profile["speed"] = clampf(float(penguin.get("base_speed")) / SPEED_DISPLAY_MAX * 100.0, 0.0, 100.0)
	profile["strength"] = clampf(damage / DAMAGE_DISPLAY_MAX * 100.0, 0.0, 100.0)
	profile["resistance"] = clampf(float(penguin.get("mass")) / MASS_DISPLAY_MAX * 100.0, 0.0, 100.0)
	character.free()
	cached_profile = profile.duplicate()
	return profile
