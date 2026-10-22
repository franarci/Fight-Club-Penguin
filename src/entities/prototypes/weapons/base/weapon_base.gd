@tool
extends Node2D
class_name WeaponBase

@onready var body: AnimatedSprite2D = $Body
@onready var attack_cooldown: Timer = $AttackCooldown

@export_category("Animation")
## Default combat settings carried by this weapon scene. Character overrides are optional.
@export var default_weapon_data: WeaponData
@export var p_spriteframes: SpriteFrames
@export var upward_visual_offset := Vector2(0, -6)
@export var upward_diagonal_visual_offset := Vector2.ZERO

@export_category("Directional Poses")
## Enable only while previewing poses. Leave off to edit SpriteFrames and Body freely.
@export var editor_preview_enabled: bool = false:
	set(value):
		var was_enabled := editor_preview_enabled
		editor_preview_enabled = value
		if Engine.is_editor_hint() and was_enabled and not value and is_node_ready():
			body.pause()
@export var visual_profile: Resource
## Optional weapon-specific poses. Unconfigured directions retain the legacy behavior.
@export var directional_poses: Array[Resource] = []
@export_enum("right", "down_right", "down", "down_left", "left", "up_left", "up", "up_right") var preview_direction: int = 0

const POSE_DIRECTIONS = ["right", "down_right", "down", "down_left", "left", "up_left", "up", "up_right"]

func _process(_delta: float) -> void:
	if Engine.is_editor_hint() and editor_preview_enabled and is_instance_valid(body) and not get_directional_poses().is_empty():
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

func get_character_pose_layer(direction_name: String, fallback: int) -> int:
	var character := wielder
	if Engine.is_editor_hint() and get_parent() != null:
		character = get_parent().get_parent()
	if is_instance_valid(character):
		var hands: Variant = character.get("hand_positions")
		if hands != null:
			var behind: Variant = hands.get("behind_body_directions")
			if behind is Array and direction_name in behind:
				return -1
	return fallback

func restore_directional_layer() -> void:
	var direction_name: String = POSE_DIRECTIONS[posmod(roundi(Vector2(direction_8).angle() / (PI / 4.0)), 8)]
	for pose in get_directional_poses():
		if pose != null and pose.get("direction") == direction_name:
			z_index = get_character_pose_layer(direction_name, pose.layer)
			return
	# Match the legacy layers for weapons without an explicit visual profile.
	if direction_8 == Vector2i.LEFT or direction_8 == Vector2i.DOWN:
		z_index = -2
	else:
		z_index = -1 if direction_8.x < 0 or direction_8 == Vector2i.UP else 1

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
		var hand: Vector2 = pose.hand_position
		var character := wielder
		if Engine.is_editor_hint():
			# Editor instances have no runtime wielder assignment.
			character = get_parent().get_parent() if get_parent() != null else null
		if is_instance_valid(character) and character.has_method("get_weapon_hand_position"):
			var attachment: Variant = character.get_weapon_hand_position(direction_name)
			if attachment is Vector2:
				# Convert through the socket so dash offsets and weapon scale both work.
				hand = to_local(get_parent().to_global(attachment))
		body.position = hand - grip * body.scale
		z_index = get_character_pose_layer(direction_name, pose.layer)
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

	attack_cooldown.wait_time = maxf(get_attack_cooldown(), 0.001)
	attack_cooldown.start()

func get_attack_cooldown() -> float:
	return weapon_data.attack_cooldown

func _on_attack_cooldown_timeout() -> void:
	can_attack = true
