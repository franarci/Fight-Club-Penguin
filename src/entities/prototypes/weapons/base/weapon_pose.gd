@tool
extends Resource

@export_enum("right", "down_right", "down", "down_left", "left", "up_left", "up", "up_right") var direction: String = "right"
@export var animation: StringName = &"idle_right"
@export var flip_h := false
@export var flip_v := false
## Fallback hand location for standalone preview or characters without Hand Positions.
## Configured characters use PenguinBase > Weapon Attachment > Hand Positions instead.
@export var hand_position := Vector2.ZERO
## Grip location measured from the center of the unflipped source image.
@export var grip_offset := Vector2.ZERO
## Relative to the weapon's parent. Keep the foreground arm above this layer.
@export var layer: int = 1

@export_group("Projectile Muzzle")
## Use this pose's sprite-relative muzzle instead of the weapon data's distance.
@export var use_muzzle_offset := false
## Barrel tip in source-image pixels relative to its center, before flips and scale.
@export var muzzle_offset := Vector2.ZERO
