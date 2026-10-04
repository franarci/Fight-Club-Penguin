@tool
extends Node2D
class_name WeaponBase

@onready var body: AnimatedSprite2D = $Body
@onready var attack_cooldown: Timer = $AttackCooldown

@export_category("Animation")
@export var p_spriteframes: SpriteFrames

var weapon_data: WeaponData
var device: int

var aim_direction := Vector2.RIGHT
var direction_8 := Vector2i.RIGHT

var can_attack := true

#func _ready() -> void:
	#body.sprite_frames = p_spriteframes
	
func setup(p_device: int, p_weapon_data: WeaponData) -> void:
	device = p_device
	weapon_data = p_weapon_data

	body.sprite_frames = weapon_data.sprite_frames
	


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

func update_weapon_visual() -> void:
	body.flip_h = false
	body.flip_v = false

	# Horizontal
	if direction_8.y == 0:
		body.play("idle_right")

		if direction_8.x < 0:
			body.flip_h = true

	# Vertical
	elif direction_8.x == 0:
		body.play("idle_up")

		if direction_8.y > 0:
			body.flip_v = true

	# Diagonal
	else:
		body.play("idle_up_left")

		if direction_8.x > 0:
			body.flip_h = true

		if direction_8.y > 0:
			body.flip_v = true
func attack() -> void:
	push_error("WeaponBase.attack() must be overridden")

func start_cooldown() -> void:
	can_attack = false

	attack_cooldown.wait_time = weapon_data.attack_cooldown
	attack_cooldown.start()


func _on_attack_cooldown_timeout() -> void:
	can_attack = true
