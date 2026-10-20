extends WeaponData
class_name MeleeWeaponData


@export_category("Melee")
@export var attack_duration: float = 0.25
@export var attack_range: float = 30.0
## Radius in world pixels, independent of the weapon sprite's scale.
@export_range(1.0, 200.0) var hit_radius: float = 22.0
## Initial push speed in world pixels/second; zero disables knockback.
@export_range(0.0, 1500.0) var knockback: float = 150.0

@export_category("Swing Animation")
## Preparation before the damaging swing, in seconds.
@export_range(0.0, 1.0, 0.01) var windup_duration: float = 0.1
## Return to the resting pose after the damaging swing, in seconds.
@export_range(0.0, 1.0, 0.01) var recovery_duration: float = 0.15
## Rotation from the resting artwork at the end of wind-up. Mirrored on the left.
@export_range(-180.0, 180.0, 1.0) var windup_angle: float = -30.0
## Rotation reached during the damaging swing. Mirrored on the left.
@export_range(-180.0, 180.0, 1.0) var impact_angle: float = 65.0
## Portion of the damage window used to reach the impact pose; smaller means a sharper strike.
@export_range(0.1, 1.0, 0.05) var strike_fraction: float = 1.0
## Small reverse rotation during recovery, in degrees. Does not rotate authored vertical attacks.
@export_range(0.0, 30.0, 1.0) var recoil_angle: float = 0.0
