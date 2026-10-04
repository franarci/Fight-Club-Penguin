extends Resource
class_name WeaponData


@export_category("General")
@export var weapon_name: String
@export var damage: float = 10.0
@export var attack_cooldown: float = 0.5

@export_category("Visual")
@export var sprite_frames: SpriteFrames
