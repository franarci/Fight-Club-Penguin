@tool
extends CharacterBody2D
class_name Penguin


@onready var body: AnimatedSprite2D = $Body
@onready var movement_state_machine: Node = $MovementStateMachine
@onready var player_indicator: Node2D = $PlayerIndicator
@onready var player_label: Label = $PlayerIndicator/Label
@onready var player_arrow: Polygon2D = $PlayerIndicator/Arrow

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
@export var p_spriteframes: SpriteFrames
@export var p_autoplay: String


var facing: StringName = &"right"

var dash_direction: Vector2 = Vector2.RIGHT
var can_dash := true
var dash_cooldown_left := 0.0
var setup_completed := false
var player_initialized := false

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
	if not arena_configured:
		return

	if ice_rect.get_global_rect().has_point(global_position):
		return

	velocity = Vector2.ZERO
	is_being_pushed = false
	movement_state_machine.change_state(&"Idle")
	global_position = respawn_position

func _ready() -> void:
	body.sprite_frames = p_spriteframes
	body.play(p_autoplay)

	# Keep the sprite preview, but do not run gameplay scripts in the editor.
	if Engine.is_editor_hint():
		return

	movement_state_machine.init(self)
	
	if setup_completed:
		initialize_player()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

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
	movement_state_machine.change_state(&"Idle")
	is_being_pushed = true
	velocity = direction.normalized() * push_speed
