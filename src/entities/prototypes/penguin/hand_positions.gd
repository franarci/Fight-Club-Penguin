@tool
extends Resource
## Hand locations in the Weapon socket's local coordinates, independent of weapon art.
@export var right := Vector2.ZERO
@export var down_right := Vector2.ZERO
@export var down := Vector2.ZERO
@export var down_left := Vector2.ZERO
@export var left := Vector2.ZERO
@export var up_left := Vector2.ZERO
@export var up := Vector2.ZERO
@export var up_right := Vector2.ZERO

@export_group("Hand Occlusion")
## Draw the held weapon behind the body in these directions. Other directions use the weapon pose layer.
@export var behind_body_directions: Array[String] = []
