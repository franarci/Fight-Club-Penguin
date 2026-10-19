@tool
extends Node2D
class_name WeaponBase

@onready var body: AnimatedSprite2D = $Body
@onready var attack_cooldown: Timer = $AttackCooldown

@export_category("Animation")
@export var p_spriteframes: SpriteFrames
@export var upward_visual_offset := Vector2(0, -6)
@export var upward_diagonal_visual_offset := Vector2.ZERO

@export_category("Directional Poses")
@export var visual_profile: Resource
## Optional weapon-specific poses. Unconfigured directions retain the legacy behavior.
@export var directional_poses: Array[Resource] = []
@export_enum("right", "down_right", "down", "down_left", "left", "up_left", "up", "up_right") var preview_direction: int = 0

const POSE_DIRECTIONS = ["right", "down_right", "down", "down_left", "left", "up_left", "up", "up_right"]

func _process(_delta: float) -> void:
	if Engine.is_editor_hint() and is_instance_valid(body) and not get_directional_poses().is_empty():
		direction_8 = snap_to_8_directions(Vector2.RIGHT.rotated(preview_direction * PI / 4.0))
		update_weapon_visual()

@onready var authored_body_position: Vector2 = $Body.position

var weapon_data: WeaponData
var device: int
var wielder: Node2D

var aim_direction := Vector2.RIGHT
var direction_8 := Vector2i.RIGHT

var can_attack := true

#func _ready() -> void:
	#body.sprite_frames = p_spriteframes
	
func setup(p_device: int, p_weapon_data: WeaponData) -> void:
	device = p_device
	weapon_data = p_weapon_data
	if weapon_data.visual_profile != null:
		visual_profile = weapon_data.visual_profile

	if weapon_data.sprite_frames != null:
		body.sprite_frames = weapon_data.sprite_frames
	update_weapon_visual()
	


func set_aim_direction(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return

	aim_direction = direction.normalized()
	direction_8 = snap_to_8_directions(aim_direction)

	update_weapon_visual()

func snap_to_8_directions(direction: Vector2) -> Vector2i:
	var step := PI / 4.0

	var snapped_angle: float  = roundf(
		direction.angle() / step
	) * step

	return Vector2i(
		int(round(cos(snapped_angle))),
		int(round(sin(snapped_angle)))
	)

func get_directional_poses() -> Array:
	if visual_profile != null and visual_profile.get("poses") is Array:
		return visual_profile.get("poses")
	return directional_poses

func update_weapon_visual() -> void:
	var direction_name: String = POSE_DIRECTIONS[posmod(roundi(Vector2(direction_8).angle() / (PI / 4.0)), 8)]
	for pose in get_directional_poses():
		if pose == null or pose.get("direction") != direction_name:
			continue
		body.flip_h = pose.flip_h
		body.flip_v = pose.flip_v
		var grip: Vector2 = pose.grip_offset
		if pose.flip_h:
			grip.x = -grip.x
		if pose.flip_v:
			grip.y = -grip.y
		body.position = pose.hand_position - grip * body.scale
		z_index = pose.layer
		body.play(pose.animation)
		return
	z_index = -1 if direction_8.y < 0 else 1
	var visual_offset := Vector2.ZERO
	if direction_8.y < 0:
		visual_offset = upward_visual_offset if direction_8.x == 0 else upward_diagonal_visual_offset
	body.position = authored_body_position + visual_offset
	body.flip_h = false
	body.flip_v = false

	# Horizontal
	if direction_8.y == 0:
		body.play("idle_right")

		if direction_8.x < 0:
			body.flip_h = true
			z_index = -2

	# Vertical
	elif direction_8.x == 0:
		if direction_8.y > 0:
			if body.sprite_frames.has_animation("idle_down") and body.sprite_frames.get_frame_count("idle_down") > 0:
				body.play("idle_down")
			else:
				body.play("idle_up")
				body.flip_v = true
		else:
			body.play("idle_up")
		if direction_8.y > 0:
			z_index = -2

	# Upper diagonals use left-facing artwork; lower diagonals use right-facing artwork.
	elif direction_8.y < 0:
		body.play("idle_up_left")
		body.flip_h = direction_8.x > 0
		if direction_8.x > 0:
			z_index=1
	else:
		body.play("idle_down_right")
		body.flip_h = direction_8.x < 0
		if direction_8.x < 0:
			z_index=-1

func attack() -> void:
	push_error("WeaponBase.attack() must be overridden")

func start_cooldown() -> void:
	can_attack = false

	attack_cooldown.wait_time = weapon_data.attack_cooldown
	attack_cooldown.start()

func _on_attack_cooldown_timeout() -> void:
	can_attack = true
