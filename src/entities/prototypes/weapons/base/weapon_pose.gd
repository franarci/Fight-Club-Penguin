@tool
extends Resource

@export_enum("right", "down_right", "down", "down_left", "left", "up_left", "up", "up_right") var direction: String = "right"
@export var animation: StringName = &"idle_right"
@export var flip_h := false
@export var flip_v := false
## Grip location in weapon-local coordinates, before the weapon node's scale.
@export var hand_position := Vector2.ZERO
## Grip location measured from the center of the unflipped source image.
@export var grip_offset := Vector2.ZERO
## Relative to the weapon's parent. Keep the foreground arm above this layer.
@export var layer: int = 1
