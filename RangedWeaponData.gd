extends WeaponData
class_name RangedWeaponData


@export_category("Ranged")
@export var projectile_scene: PackedScene
@export var projectile_speed: float = 500.0
@export var automatic: bool = false
@export var muzzle_distance: float = 25.0
@export var spread: float = 0.0
