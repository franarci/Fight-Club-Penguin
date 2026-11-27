extends VBoxContainer

const ControlPrompt = preload("res://src/ui/shared/control_prompt.gd")
const REST_DURATION := 0.7
const FULL_DURATION := 0.35
const ATTACK_DURATION := 2.0

@export var character_scene: PackedScene
@export var character_name: String
@export var attack_description: String
@export var player_slot := 0
@export var actor_position := Vector2(-40, 5)

@onready var viewport: SubViewport = $Display/Viewport
@onready var actors: Node2D = $Display/Viewport/Actors
@onready var camera: Camera2D = $Display/Viewport/Camera
@onready var meter: ProgressBar = $Charge
@onready var phase_label: Label = $Phase
@onready var button_panel: PanelContainer = $Button
@onready var button_content: HBoxContainer = $Button/Content

var penguin: Penguin
var weapon: MeleeWeapon
var character_instance: Node2D
var running := false
var phase: StringName = &"rest"
var phase_elapsed := 0.0
var attacks_shown := 0

func _ready() -> void:
	$Name.text = character_name
	$Description.text = attack_description
	viewport.size_changed.connect(_fit_camera)
	_fit_camera()
	set_physics_process(false)

func configure_devices(devices: Array) -> void:
	for child in button_content.get_children():
		button_content.remove_child(child)
		child.queue_free()
	var prompt := ControlPrompt.new()
	prompt.configure("", devices, ["attack"])
	button_content.add_child(prompt)

func set_running(value: bool) -> void:
	running = value
	set_physics_process(value)
	_clear_actor()
	meter.value = 0.0
	if value:
		_create_actor()
		_set_phase(&"rest")

func _create_actor() -> void:
	character_instance = character_scene.instantiate() as Node2D
	actors.add_child(character_instance)
	penguin = character_instance.get_child(0) as Penguin
	penguin.global_position = actor_position
	penguin.player_indicator.hide()
	penguin.apply_equipment_color(PlayerManager.get_player_color(player_slot))
	weapon = penguin.weapon_socket.get_node("EquippedWeapon") as MeleeWeapon
	penguin.current_weapon = weapon
	weapon.wielder = penguin
	weapon.setup(-1, penguin.starting_weapon_data)
	penguin.update_facing(Vector2.RIGHT)
	penguin.play_animation(&"idle")
	for node in character_instance.find_children("*", "Node", true, false):
		node.set_process(false)
		node.set_physics_process(false)
		node.set_process_input(false)
		node.set_process_unhandled_input(false)
		if node is CollisionObject2D:
			node.collision_layer = 0
			node.collision_mask = 0
		if node is Area2D:
			node.monitoring = false
			node.monitorable = false
		if node is AudioStreamPlayer or node is AudioStreamPlayer2D:
			node.volume_db = -80.0
		if node is Timer:
			node.stop()
		if node is AnimationPlayer:
			node.stop()
	weapon.set_physics_process(true)

func _clear_actor() -> void:
	if is_instance_valid(character_instance):
		actors.remove_child(character_instance)
		character_instance.queue_free()
	character_instance = null
	penguin = null
	weapon = null

func _physics_process(delta: float) -> void:
	if not running or not is_instance_valid(weapon):
		return
	phase_elapsed += delta
	match phase:
		&"rest":
			if phase_elapsed >= REST_DURATION:
				weapon.begin_charge()
				_set_phase(&"hold")
		&"hold":
			weapon.update_charge(delta)
			meter.value = weapon.charge_progress() * 100.0
			if weapon.charge_ready:
				_set_phase(&"full")
		&"full":
			if phase_elapsed >= FULL_DURATION:
				weapon.finish_charge()
				attacks_shown += 1
				_set_phase(&"release")
		&"release":
			if phase_elapsed >= ATTACK_DURATION:
				_clear_actor()
				_create_actor()
				meter.value = 0.0
				_set_phase(&"rest")
	if phase == &"hold" or phase == &"full":
		button_content.pivot_offset = button_content.size * 0.5
		button_content.scale = Vector2.ONE * (0.88 + sin(phase_elapsed * 7.0) * 0.012)

func _set_phase(value: StringName) -> void:
	phase = value
	phase_elapsed = 0.0
	var held := phase == &"hold" or phase == &"full"
	button_panel.modulate = Color(0.55, 0.85, 1) if held else Color.WHITE
	button_content.scale = Vector2.ONE * 0.88 if held else Vector2.ONE
	phase_label.text = {&"rest": "WATCH THE BUTTON", &"hold": "HOLD", &"full": "FULL CHARGE", &"release": "RELEASE TO ATTACK"}[phase]

func _fit_camera() -> void:
	var dimensions := Vector2(viewport.size)
	camera.zoom = Vector2.ONE * minf(dimensions.x / 460.0, dimensions.y / 230.0)
