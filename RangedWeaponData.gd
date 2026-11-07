extends WeaponData
class_name RangedWeaponData


@export_category("Ranged")
@export var projectile_scene: PackedScene
@export var projectile_speed: float = 500.0
@export var automatic: bool = false
@export var muzzle_distance: float = 25.0
@export var spread: float = 0.0
@export_range(1, 20, 1) var burst_size: int = 1
@export_range(0.0, 2.0, 0.01) var burst_pause: float = 0.0
@export_range(0, 100, 1) var magazine_capacity: int = 0
@export_range(0.1, 10.0, 0.05) var reload_duration: float = 1.2
