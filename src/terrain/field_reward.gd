extends Area2D
class_name FieldReward

enum RewardKind { FISH, EXTRA_LIFE, ICE_SHIELD }

signal collected(kind: RewardKind, penguin: Penguin, reward: FieldReward)

var reward_kind: RewardKind = RewardKind.FISH
var lifetime_seconds := 14.0
var blink_duration := 3.0
var blink_frequency := 5.0
var pickup_radius := 28.0
var visual_scale := Vector2.ONE
var depth_z_index := 0
var float_amplitude := 5.0
var float_frequency := 1.0
var _float_phase := 0.0

var _elapsed := 0.0
var _collected := false
var _collection_pending := false
var _locked_out_penguin_ids: Dictionary = {}
var _visual: Node2D
var _visual_rest_position := Vector2.ZERO


func configure(
	kind: RewardKind,
	visual_scene: PackedScene,
	lifetime: float,
	blink_time: float,
	blink_rate: float,
	radius: float,
	item_scale: Vector2,
	depth: int,
	bob_amplitude: float,
	bob_frequency: float,
	randomize_bob_phase: bool
) -> void:
	reward_kind = kind
	lifetime_seconds = maxf(lifetime, 0.1)
	blink_duration = clampf(blink_time, 0.0, lifetime_seconds)
	blink_frequency = maxf(blink_rate, 0.1)
	pickup_radius = maxf(radius, 1.0)
	visual_scale = item_scale
	depth_z_index = depth
	float_amplitude = maxf(bob_amplitude, 0.0)
	float_frequency = maxf(bob_frequency, 0.0)
	_float_phase = randf_range(0.0, TAU) if randomize_bob_phase else 0.0
	top_level = true
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	monitorable = false
	z_as_relative = false
	z_index = depth_z_index

	var pickup_shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = pickup_radius
	pickup_shape.shape = circle
	add_child(pickup_shape)

	if visual_scene != null:
		var visual := visual_scene.instantiate()
		add_child(visual)
		if visual is Node2D:
			_visual = visual as Node2D
			_visual.scale = visual_scale
			_visual.z_index = 1
			_visual_rest_position = _visual.position
		if visual is AnimatedSprite2D:
			(visual as AnimatedSprite2D).play()


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func exclude_penguins_until_they_leave(penguins: Array[Penguin]) -> void:
	for penguin in penguins:
		if is_instance_valid(penguin):
			_locked_out_penguin_ids[penguin.get_instance_id()] = true


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= lifetime_seconds:
		queue_free()
		return
	if is_instance_valid(_visual) and float_amplitude > 0.0 and float_frequency > 0.0:
		var bob := sin(_elapsed * float_frequency * TAU + _float_phase) * float_amplitude
		_visual.position = _visual_rest_position + Vector2(0.0, -bob)
	var blink_start := lifetime_seconds - blink_duration
	if blink_duration > 0.0 and _elapsed >= blink_start:
		var phase := sin((_elapsed - blink_start) * blink_frequency * TAU)
		modulate.a = lerpf(0.18, 1.0, (phase + 1.0) * 0.5)


func _on_body_entered(body: Node2D) -> void:
	if _collected or _collection_pending or not body is Penguin:
		return
	var penguin := body as Penguin
	if _locked_out_penguin_ids.has(penguin.get_instance_id()):
		return
	if penguin.is_dead or penguin.is_eliminated:
		return
	if reward_kind == RewardKind.EXTRA_LIFE and PlayerManager.get_lives(penguin.player_index) >= PlayerManager.MAX_LIVES:
		return
	_collection_pending = true
	set_deferred("monitoring", false)
	_confirm_collection_after_physics_frame(penguin)


func _on_body_exited(body: Node2D) -> void:
	if not body is Penguin:
		return
	var penguin := body as Penguin
	if not penguin.is_dead and not penguin.is_eliminated:
		_locked_out_penguin_ids.erase(penguin.get_instance_id())


func _confirm_collection_after_physics_frame(penguin: Penguin) -> void:
	var scene_tree := get_tree()
	await scene_tree.physics_frame
	if not is_instance_valid(self):
		return
	_collection_pending = false
	if not is_instance_valid(penguin) or penguin.is_dead or penguin.is_eliminated:
		_resume_collection()
		return
	if reward_kind == RewardKind.EXTRA_LIFE and PlayerManager.get_lives(penguin.player_index) >= PlayerManager.MAX_LIVES:
		_resume_collection()
		return
	_collected = true
	collected.emit(reward_kind, penguin, self)


func _resume_collection() -> void:
	_collection_pending = false
	_collected = false
	set_deferred("monitoring", true)


func cancel_collection() -> void:
	if not _collected:
		return
	_resume_collection()
