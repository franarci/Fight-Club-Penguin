@tool
extends CharacterBody2D
class_name Penguin

signal health_changed(current: float, maximum: float)
signal eliminated(slot: int)

@export_category("Equipment Colors")
## Shared palette settings. Runtime duplicates the material for each player.
## Expand Shader Parameters to adjust source colors, tolerance and shading.
@export var equipment_palette: ShaderMaterial = preload("res://src/entities/prototypes/penguin/player_palette.tres")
## Only Body and these optional child sprites are recolored. Weapons remain untouched.
@export var equipment_sprite_paths: Array[NodePath] = [NodePath("Arm")]
## Optional editor preview; gameplay always uses the assigned player slot color.
@export var preview_equipment_color: bool = false:
	set(value):
		preview_equipment_color = value
		if Engine.is_editor_hint() and is_node_ready():
			update_equipment_preview()
@export var equipment_preview_color: Color = Color("e74c3c"):
	set(value):
		equipment_preview_color = value
		if Engine.is_editor_hint() and is_node_ready():
			update_equipment_preview()
var player_palette_instance: ShaderMaterial

@export_category("Combat Stats")
## Relative mass: 1 is average. Incoming push speed is divided by mass.
## Does not change movement speed, outgoing damage, or incoming damage.
@export_range(0.1, 5.0, 0.05) var mass: float = 1.0
## Multiplies the equipped melee weapon's damage. 1.2 means 20% more damage.
@export_range(0.0, 3.0, 0.05) var melee_power: float = 1.0
## Divides ranged cooldown. 1.15 means 15% more shots per second.
@export_range(0.1, 3.0, 0.05) var ranged_attack_speed: float = 1.0
## Divides weapon spread. Values above 1 improve accuracy; zero-spread guns stay accurate.
## Reloading is not implemented yet, so this currently affects only spread.
@export_range(0.1, 3.0, 0.05) var ranged_handling: float = 1.0

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
@onready var feet_marker: Marker2D = $FeetMarker
@onready var movement_state_machine: Node = $MovementStateMachine
@onready var player_indicator: Node2D = $PlayerIndicator
@onready var player_label: Label = $PlayerIndicator/Label
@onready var player_arrow: Polygon2D = $PlayerIndicator/Arrow
@onready var weapon_socket: Node2D = $Weapon
@onready var arm: Sprite2D = get_node_or_null("Arm") as Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var standing_weapon_position: Vector2 = $Weapon.position
@onready var standing_arm_position: Vector2 = arm.position if arm != null else Vector2.ZERO

var current_weapon: WeaponBase
@export_category("Weapon Attachment")
## Directional hand positions in Weapon socket coordinates. Shared by all equipped weapons.
@export var hand_positions: Resource

func get_weapon_hand_position(direction_name: String) -> Variant:
	return hand_positions.get(direction_name) if hand_positions != null else null

var pending_weapon: WeaponBase
var weapon_change_pending := false
var weapon_attack_ready_at := 0
var empty_weapon_attachment: Node2D

@export_category("Player Identifier")
## Automatically place and size P1/P2 and the triangle using the Body sprite bounds.
## Disable to position PlayerIndicator and its children manually.
@export var auto_player_identifier: bool = true
## First frame used to size the identifier, independently of the playing animation.
@export var identifier_reference_animation: StringName = &"idle_right"
## Identifier width as a fraction of the scaled reference frame width.
@export_range(0.1, 1.5, 0.05) var identifier_width_ratio: float = 0.6
## Space from the top of Body to the triangle tip, in penguin-local pixels.
@export_range(0.0, 50.0, 0.5) var identifier_head_gap: float = 4.0
## Space between the label and triangle, before identifier scaling.
@export_range(0.0, 20.0, 0.5) var identifier_label_gap: float = 2.0
## Fine adjustment in penguin-local coordinates; positive Y moves downward.
@export var identifier_offset := Vector2.ZERO

func _process(_delta: float) -> void:
	update_player_identifier()

func update_player_identifier() -> void:
	if not auto_player_identifier or not is_instance_valid(body) or not is_instance_valid(player_indicator):
		return
	var sprite_rect := get_body_display_rect()
	if not sprite_rect.has_area():
		return
	# Both nodes are siblings: Body's transform includes its own scale and offset,
	# while their shared parent scale naturally scales the whole result once.
	var bounds: Rect2 = body.transform * sprite_rect
	if player_arrow.polygon.is_empty():
		return
	if Engine.is_editor_hint() and player_label.text.is_empty():
		player_label.text = "P%d" % (player_index + 1)
	var label_size := player_label.get_minimum_size()
	var arrow_bounds := Rect2(player_arrow.polygon[0], Vector2.ZERO)
	for vertex in player_arrow.polygon:
		arrow_bounds = arrow_bounds.expand(vertex)
	var content_width := maxf(maxf(label_size.x, arrow_bounds.size.x), 1.0)
	var reference_width := get_identifier_reference_width()
	var indicator_scale := reference_width * identifier_width_ratio / content_width
	player_indicator.scale = Vector2.ONE * indicator_scale
	player_indicator.position = Vector2(bounds.get_center().x, bounds.position.y - identifier_head_gap) + identifier_offset
	# Put the triangle tip at the identifier origin, and center the label above it.
	player_arrow.position = Vector2(-arrow_bounds.get_center().x, -arrow_bounds.end.y)
	player_label.size = label_size
	player_label.position = Vector2(-label_size.x * 0.5, -arrow_bounds.size.y - identifier_label_gap - label_size.y)

func get_identifier_reference_width() -> float:
	var frames := body.sprite_frames
	if frames == null:
		return 0.0
	# Fallbacks remain independent of the current animation and frame.
	var candidates: Array[StringName] = [identifier_reference_animation, &"idle_right", StringName(p_autoplay)]
	for animation_name in candidates:
		if not frames.has_animation(animation_name) or frames.get_frame_count(animation_name) == 0:
			continue
		var texture := frames.get_frame_texture(animation_name, 0)
		if texture != null:
			return texture.get_size().x * absf(body.scale.x)
	return 1.0 * absf(body.scale.x)

func get_body_display_rect() -> Rect2:
	if body.sprite_frames == null or not body.sprite_frames.has_animation(body.animation):
		return Rect2()
	var count := body.sprite_frames.get_frame_count(body.animation)
	if count == 0:
		return Rect2()
	var texture := body.sprite_frames.get_frame_texture(body.animation, clampi(body.frame, 0, count - 1))
	if texture == null:
		return Rect2()
	var size := texture.get_size()
	var origin := body.offset - (size * 0.5 if body.centered else Vector2.ZERO)
	if body.flip_h:
		origin.x = -origin.x - size.x
	if body.flip_v:
		origin.y = -origin.y - size.y
	return Rect2(origin, size)

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
var dash_pose_active := false

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
var ice_boundary: CollisionPolygon2D
var arena_configured := false


func configure_arena(boundary: CollisionPolygon2D) -> void:
	ice_boundary = boundary
	respawn_position = global_position
	arena_configured = true


func check_arena_bounds() -> void:
	if is_dead or not arena_configured or not is_instance_valid(ice_boundary):
		return

	# Test the penguin's feet against the ice surface in image coordinates.
	# Converting through the polygon also accounts for viewport scaling.
	if Geometry2D.is_point_in_polygon(ice_boundary.to_local(feet_marker.global_position), ice_boundary.polygon):
		return

	lose_life()

func _ready() -> void:
	if Engine.is_editor_hint():
		update_editor_preview()
		update_equipment_preview()
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
	# Resolve at runtime: the input plugin temporarily unregisters its autoload
	# during editor shutdown, while this @tool script is still loaded.
	return get_node("/root/MultiplayerInput").get_vector(
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
	# Keep the penguin and hammer facing together until the swing finishes.
	# Movement still receives input independently of facing.
	if current_weapon is MeleeWeapon and current_weapon.swing_time_left > 0.0:
		return

	if is_instance_valid(current_weapon):
		current_weapon.set_aim_direction(input_dir)

	# Equal 45-degree sectors also work with analog stick input.
	var sector := posmod(roundi(input_dir.angle() / (PI / 4.0)), 8)
	var directions: Array[StringName] = [
		&"right", &"down_right", &"down", &"down_left",
		&"left", &"up_left", &"up", &"up_right",
	]
	facing = directions[sector]
	if arm != null:
		arm.visible = facing == &"right"


func has_body_animation(animation_name: String) -> bool:
	return body.sprite_frames.has_animation(animation_name) and body.sprite_frames.get_frame_count(animation_name) > 0


func play_animation(state: StringName) -> void:
	var animation_name := String(state) + "_" + String(facing)
	var requested_animation := animation_name
	# Existing cardinal left animations use right-facing artwork.
	body.flip_h = facing == &"left"
	var direction_name := String(facing)
	if direction_name.contains("_") and not has_body_animation(animation_name):
		var mirrored_direction := direction_name.replace("left", "right") if direction_name.ends_with("left") else direction_name.replace("right", "left")
		var mirrored_animation := String(state) + "_" + mirrored_direction
		if has_body_animation(mirrored_animation):
			animation_name = mirrored_animation
			body.flip_h = true
		else:
			# Keep the same action when diagonal artwork is missing.
			animation_name = String(state) + "_" + direction_name.get_slice("_", 0)
	if not has_body_animation(animation_name):
		animation_name = p_autoplay
		body.flip_h = false
	var timeline_name := requested_animation if animation_player.has_animation(requested_animation) else animation_name
	if state == &"dash" and animation_player.has_animation(timeline_name):
		# One timeline owns body frames and attachment positions during the dash.
		dash_pose_active = true
		body.stop()
		var clip := animation_player.get_animation(timeline_name)
		animation_player.play(timeline_name, -1, clip.length / maxf(dash_duration, 0.001))
		animation_player.advance(0.0)
		return

	stop_dash_animation()
	if body.animation != animation_name or not body.is_playing():
		body.play(animation_name)


func advance_dash_animation(delta: float) -> void:
	if animation_player.is_playing():
		animation_player.advance(delta)


func stop_dash_animation() -> void:
	if not dash_pose_active:
		return
	dash_pose_active = false
	animation_player.stop()
	weapon_socket.position = standing_weapon_position
	if is_instance_valid(current_weapon):
		current_weapon.restore_directional_layer()
	if arm != null:
		arm.position = standing_arm_position
	if weapon_change_pending:
		apply_weapon_change()


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
	if current_weapon != null:
		current_weapon.wielder = self
		var data := starting_weapon_data if starting_weapon_data != null else current_weapon.default_weapon_data
		if data != null:
			current_weapon.setup(device, data)

## Returns true when accepted. During a dash, replacement waits for its timeline to end.
## Call deferred from physics overlap signals (for example, a pickup's body_entered).
func equip_weapon(scene: PackedScene, data_override: WeaponData = null) -> bool:
	if not is_node_ready() or is_dead or is_eliminated or scene == null:
		return false
	var candidate := scene.instantiate()
	if not candidate is WeaponBase:
		candidate.free()
		return false
	var data: WeaponData = data_override if data_override != null else candidate.default_weapon_data
	if data == null or (candidate is RangedWeapon and not data is RangedWeaponData) or (candidate is MeleeWeapon and not data is MeleeWeaponData):
		candidate.free()
		return false
	candidate.default_weapon_data = data
	queue_weapon_change(candidate)
	return true

func unequip_weapon() -> bool:
	if not is_node_ready() or is_dead or is_eliminated:
		return false
	queue_weapon_change(null)
	return true

func queue_weapon_change(candidate: WeaponBase) -> void:
	if is_instance_valid(pending_weapon):
		pending_weapon.free()
	pending_weapon = candidate
	weapon_change_pending = true
	if not dash_pose_active:
		apply_weapon_change()

func apply_weapon_change() -> void:
	weapon_change_pending = false
	var candidate := pending_weapon
	pending_weapon = null
	if is_dead or is_eliminated:
		if is_instance_valid(candidate):
			candidate.free()
		return
	var direction := Vector2.RIGHT.rotated(WeaponBase.POSE_DIRECTIONS.find(String(facing)) * PI / 4.0)
	var cooldown := maxf(0.0, (weapon_attack_ready_at - Time.get_ticks_msec()) / 1000.0)
	if is_instance_valid(current_weapon):
		direction = current_weapon.aim_direction
		cooldown = maxf(cooldown, current_weapon.attack_cooldown.time_left)
		if current_weapon is MeleeWeapon and current_weapon.swing_time_left > 0.0:
			cooldown = maxf(cooldown, current_weapon.swing_time_left + current_weapon.get_attack_cooldown())
		if current_weapon.has_method("cancel_attack"):
			current_weapon.cancel_attack()
		current_weapon.process_mode = Node.PROCESS_MODE_DISABLED
		weapon_socket.remove_child(current_weapon)
		current_weapon.queue_free()
	weapon_attack_ready_at = Time.get_ticks_msec() + ceili(cooldown * 1000.0)
	if is_instance_valid(empty_weapon_attachment):
		empty_weapon_attachment.free()
		empty_weapon_attachment = null
	current_weapon = candidate
	animation_player.clear_caches()
	if current_weapon == null:
		# Keep existing dash layer tracks valid while the character is unarmed.
		empty_weapon_attachment = Node2D.new()
		empty_weapon_attachment.name = "EquippedWeapon"
		weapon_socket.add_child(empty_weapon_attachment)
		return
	current_weapon.name = "EquippedWeapon"
	current_weapon.wielder = self
	weapon_socket.add_child(current_weapon)
	current_weapon.setup(device, current_weapon.default_weapon_data)
	current_weapon.set_aim_direction(direction)
	if cooldown > 0.0:
		current_weapon.can_attack = false
		current_weapon.attack_cooldown.start(cooldown)

func _exit_tree() -> void:
	if is_instance_valid(pending_weapon):
		pending_weapon.free()

func apply_player_identity() -> void:
	var color: Color = PlayerManager.get_player_color(player_index)
	modulate = Color.WHITE
	apply_equipment_color(color)
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

func apply_equipment_color(color: Color) -> void:
	if equipment_palette == null:
		return
	player_palette_instance = equipment_palette.duplicate() as ShaderMaterial
	player_palette_instance.set_shader_parameter("player_color", color)
	player_palette_instance.set_shader_parameter("preserve_original", not Engine.is_editor_hint() and player_index == 0)
	body.material = player_palette_instance
	for path in equipment_sprite_paths:
		var equipment_sprite := get_node_or_null(path) as CanvasItem
		if equipment_sprite != null:
			equipment_sprite.material = player_palette_instance

func update_equipment_preview() -> void:
	if preview_equipment_color:
		apply_equipment_color(equipment_preview_color)
	elif player_palette_instance != null:
		if body.material == player_palette_instance:
			body.material = null
		for path in equipment_sprite_paths:
			var equipment_sprite := get_node_or_null(path) as CanvasItem
			if equipment_sprite != null and equipment_sprite.material == player_palette_instance:
				equipment_sprite.material = null
		player_palette_instance = null
	
	
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


func receive_push(direction: Vector2, strength: float = -1.0) -> void:
	if is_dead or protection_left > 0.0:
		return
	var speed := push_speed if strength < 0.0 else strength
	if speed <= 0.0 or direction.is_zero_approx():
		return
	movement_state_machine.change_state(&"Idle")
	is_being_pushed = true
	velocity = direction.normalized() * speed / maxf(mass, 0.1)


# Shared entry point for projectile, melee, and future environmental damage.
func receive_damage(amount: float, source: Node2D = null, _direction: Vector2 = Vector2.ZERO) -> bool:
	if is_dead or protection_left > 0.0 or amount <= 0.0 or source == self:
		return false
	set_health(current_health - amount)
	if current_health <= 0.0:
		lose_life()
	return true


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
		if current_weapon.has_method("cancel_attack"):
			current_weapon.cancel_attack()
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
	weapon_attack_ready_at = 0
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
