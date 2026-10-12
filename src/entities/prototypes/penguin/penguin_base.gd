@tool
extends CharacterBody2D
class_name Penguin

signal health_changed(current: float, maximum: float)
signal eliminated(slot: int)

@export_category("Health")
@export_range(1.0, 10000.0) var max_health: float = 100.0
@export_range(0.01, 10.0) var respawn_delay: float = 0.8
@export_range(0.0, 10.0) var respawn_protection: float = 1.0

@onready var respawn_timer: Timer = $RespawnTimer
@onready var original_collision_layer: int = collision_layer
@onready var original_collision_mask: int = collision_mask

var current_health: float
var is_dead := false
var is_eliminated := false
var protection_left := 0.0


@onready var body: AnimatedSprite2D = $Body
@onready var movement_state_machine: Node = $MovementStateMachine
@onready var player_indicator: Node2D = $PlayerIndicator
@onready var player_label: Label = $PlayerIndicator/Label
@onready var player_arrow: Polygon2D = $PlayerIndicator/Arrow
@onready var weapon_socket: Node2D = $Weapon

var current_weapon: WeaponBase

@export_category("Weapon")
@export var starting_weapon_data: WeaponData

var player_index: int
var device: int

@export_category("Movement")
@export var base_speed: float = 180.0

# Físicas de hielo
@export var ice_acceleration: float = 400.0
@export var ice_friction: float = 100.0


@export_category("Dash")
@export var dash_speed: float = 500.0
@export var dash_duration: float = 0.18
@export var dash_cooldown: float = 0.8


@export_category("Animation")
@export var p_spriteframes: SpriteFrames:
	set(value):
		p_spriteframes = value
		if Engine.is_editor_hint() and is_node_ready():
			update_editor_preview()
@export var p_autoplay: String:
	set(value):
		p_autoplay = value
		if Engine.is_editor_hint() and is_node_ready():
			update_editor_preview()


var facing: StringName = &"right"

var dash_direction: Vector2 = Vector2.RIGHT
var can_dash := true
var dash_cooldown_left := 0.0
var setup_completed := false
var player_initialized := false

func update_editor_preview() -> void:
	if p_spriteframes == null:
		return
	body.sprite_frames = p_spriteframes
	if p_spriteframes.has_animation(p_autoplay):
		body.animation = p_autoplay
	body.stop()

@export_category("Push")
@export var push_speed: float = 500.0
@export var push_friction: float = 600.0

var is_being_pushed := false
var respawn_position: Vector2
var ice_rect: ColorRect
var arena_configured := false


func configure_arena(ice: ColorRect) -> void:
	ice_rect = ice
	respawn_position = global_position
	arena_configured = true


func check_arena_bounds() -> void:
	if is_dead or not arena_configured or not is_instance_valid(ice_rect):
		return

	if ice_rect.get_global_rect().has_point(global_position):
		return

	lose_life()

func _ready() -> void:
	if Engine.is_editor_hint():
		update_editor_preview()
		return
	set_health(max_health)
	body.sprite_frames = p_spriteframes
	body.play(p_autoplay)

	movement_state_machine.init(self)
	
	if setup_completed:
		initialize_player()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or is_dead:
		return

	protection_left = maxf(0.0, protection_left - delta)
	body.self_modulate.a = 0.5 if protection_left > 0.0 else 1.0
	update_dash_cooldown(delta)

	if is_being_pushed:
		velocity = velocity.move_toward(
			Vector2.ZERO,
			push_friction * delta
		)

		move_and_slide()

		if velocity.length() < 10.0:
			velocity = Vector2.ZERO
			is_being_pushed = false
			movement_state_machine.change_state(&"Idle")
		
		check_arena_bounds()
		return

	movement_state_machine.physics_update(delta)
	

	var is_dashing: bool = (
		movement_state_machine.current_state != null
		and movement_state_machine.current_state.name == &"Dash"
	)

	move_and_slide()

	if is_dashing:
		check_dash_impact()
		
	check_arena_bounds()


func get_input_direction() -> Vector2:
	return MultiplayerInput.get_vector(
		device,
		"left",
		"right",
		"up",
		"down"
	)


# -------------------------
# ICE MOVEMENT
# -------------------------

func apply_ice_movement(input_dir: Vector2, delta: float) -> void:
	var target_velocity := input_dir * base_speed

	velocity = velocity.move_toward(
		target_velocity,
		ice_acceleration * delta
	)


func apply_ice_friction(delta: float) -> void:
	velocity = velocity.move_toward(
		Vector2.ZERO,
		ice_friction * delta
	)


# -------------------------
# DIRECTION / ANIMATION
# -------------------------

func update_facing(input_dir: Vector2) -> void:
	if input_dir == Vector2.ZERO:
		return

	if is_instance_valid(current_weapon):
		current_weapon.set_aim_direction(input_dir)

	if abs(input_dir.x) > abs(input_dir.y):
		if input_dir.x > 0:
			facing = &"right"
			body.flip_h = false
		else:
			facing = &"left"
			body.flip_h = true
	else:
		if input_dir.y > 0:
			facing = &"down"
		else:
			facing = &"up"


func play_animation(state: StringName) -> void:
	var animation_name := String(state) + "_" + String(facing)

	if not body.sprite_frames.has_animation(animation_name):
		animation_name = p_autoplay
	if body.animation != animation_name:
		body.play(animation_name)


# -------------------------
# DASH COOLDOWN
# -------------------------

func start_dash_cooldown() -> void:
	can_dash = false
	dash_cooldown_left = dash_cooldown


func update_dash_cooldown(delta: float) -> void:
	if can_dash:
		return

	dash_cooldown_left -= delta

	if dash_cooldown_left <= 0.0:
		can_dash = true

func setup(
	p_player_index: int,
	p_device: int,
) -> void:

	player_index = p_player_index
	device = p_device
	setup_completed = true

	if is_node_ready():
		initialize_player()
		
func initialize_player() -> void:
	if player_initialized:
		return

	player_initialized = true

	apply_player_identity()
	current_weapon = weapon_socket.get_node_or_null("EquippedWeapon") as WeaponBase
	if current_weapon != null and starting_weapon_data != null:
		current_weapon.wielder = self
		current_weapon.setup(device, starting_weapon_data)

func apply_player_identity() -> void:
	var color: Color = PlayerManager.get_player_color(player_index)
	modulate = color
	player_label.text = "P%d" % (player_index + 1)
	player_label.add_theme_color_override(
		"font_color",
		color
	)

	player_label.add_theme_color_override(
		"font_outline_color",
		Color.BLACK
	)

	player_label.add_theme_constant_override(
		"outline_size",
		3
	)
	
	player_arrow.color = color
	#Resolver color para identificar al jugador
	
	
func check_dash_impact() -> void:
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var other := collision.get_collider() as Penguin

		if other == null or other == self:
			continue

		# Solo empujar si el rival está frente a la embestida.
		if dash_direction.dot(-collision.get_normal()) <= 0.1:
			continue

		other.receive_push(dash_direction)

		velocity = Vector2.ZERO
		movement_state_machine.change_state(&"Idle")
		return


func receive_push(direction: Vector2) -> void:
	if is_dead or protection_left > 0.0:
		return
	movement_state_machine.change_state(&"Idle")
	is_being_pushed = true
	velocity = direction.normalized() * push_speed


# Shared entry point for projectile, melee, and future environmental damage.
func receive_damage(amount: float, source: Node2D = null, _direction: Vector2 = Vector2.ZERO) -> void:
	if is_dead or protection_left > 0.0 or amount <= 0.0 or source == self:
		return
	set_health(current_health - amount)
	if current_health <= 0.0:
		lose_life()


func set_health(value: float) -> void:
	current_health = clampf(value, 0.0, max_health)
	health_changed.emit(current_health, max_health)


func lose_life() -> void:
	if is_dead:
		return
	# Set the guard before signals/overlaps can cause a second death this frame.
	is_dead = true
	set_health(0.0)
	PlayerManager.lose_life(player_index)
	velocity = Vector2.ZERO
	is_being_pushed = false
	movement_state_machine.change_state(&"Idle")
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	if is_instance_valid(current_weapon):
		current_weapon.can_attack = false
		current_weapon.process_mode = Node.PROCESS_MODE_DISABLED
	hide()
	if PlayerManager.get_lives(player_index) <= 0:
		is_eliminated = true
		eliminated.emit(player_index)
	else:
		respawn_timer.start(respawn_delay)


func _on_respawn_timer_timeout() -> void:
	if is_eliminated:
		return
	global_position = respawn_position
	velocity = Vector2.ZERO
	is_being_pushed = false
	can_dash = true
	dash_cooldown_left = 0.0
	movement_state_machine.change_state(&"Idle")
	set_health(max_health)
	protection_left = respawn_protection
	body.self_modulate.a = 0.5 if protection_left > 0.0 else 1.0
	set_deferred("collision_layer", original_collision_layer)
	set_deferred("collision_mask", original_collision_mask)
	if is_instance_valid(current_weapon):
		current_weapon.attack_cooldown.stop()
		current_weapon.can_attack = true
		current_weapon.process_mode = Node.PROCESS_MODE_INHERIT
	is_dead = false
	show()
