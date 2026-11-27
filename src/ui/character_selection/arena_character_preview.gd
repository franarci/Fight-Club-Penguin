extends SubViewportContainer

@onready var viewport: SubViewport = $Viewport
@onready var stage: Node2D = $Viewport/Stage

var character_instance: Node2D
var penguin: Penguin
var visual_bounds := Rect2()
var selected_scene: PackedScene
var resting_position := Vector2.ZERO
var resting_scale := Vector2.ONE
var idle_time := 0.0
@onready var shadow: Polygon2D = $Viewport/Shadow

func _ready() -> void:
	viewport.size_changed.connect(_fit_character)
	var points := PackedVector2Array()
	for index in range(32):
		points.append(Vector2(cos(TAU * index / 32.0) * 26.0, sin(TAU * index / 32.0) * 5.0))
	shadow.polygon = points
	shadow.hide()

func _process(delta: float) -> void:
	if not is_visible_in_tree() or not is_instance_valid(character_instance):
		return
	idle_time += delta
	var breath := sin(idle_time * 2.6)
	stage.scale = resting_scale * Vector2(1.0 + breath * 0.006, 1.0 - breath * 0.012)
	stage.position = resting_position + Vector2(0, -breath * 0.8)

func show_character(scene: PackedScene, color: Color) -> void:
	if scene == selected_scene and is_instance_valid(character_instance):
		set_player_color(color)
		return
	clear_character()
	if scene == null:
		return
	selected_scene = scene
	character_instance = scene.instantiate() as Node2D
	stage.add_child(character_instance)
	penguin = character_instance.get_child(0) as Penguin
	if penguin == null:
		clear_character()
		return
	penguin.player_indicator.hide()
	penguin.current_weapon = penguin.weapon_socket.get_node_or_null("EquippedWeapon") as WeaponBase
	if penguin.current_weapon != null:
		var weapon := penguin.current_weapon
		weapon.wielder = penguin
		var data := penguin.starting_weapon_data if penguin.starting_weapon_data != null else weapon.default_weapon_data
		if data != null:
			weapon.setup(-1, data)
	penguin.update_facing(Vector2(1, 1))
	penguin.play_animation(&"idle")
	set_player_color(color)
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
		if node is Timer:
			node.stop()
		if node is AnimationPlayer:
			node.stop()
		if node is AudioStreamPlayer or node is AudioStreamPlayer2D:
			node.stop()
	visual_bounds = _sprite_bounds(penguin.body)
	if penguin.current_weapon != null:
		visual_bounds = visual_bounds.merge(_sprite_bounds(penguin.current_weapon.body))
	_fit_character()

func set_player_color(color: Color) -> void:
	if is_instance_valid(penguin):
		penguin.apply_equipment_color(color)

func clear_character() -> void:
	if is_instance_valid(character_instance):
		stage.remove_child(character_instance)
		character_instance.queue_free()
	character_instance = null
	penguin = null
	selected_scene = null
	visual_bounds = Rect2()
	stage.transform = Transform2D.IDENTITY
	idle_time = 0.0
	shadow.hide()

func _sprite_bounds(sprite: AnimatedSprite2D) -> Rect2:
	var texture := sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	if texture == null:
		return Rect2()
	var rect := Rect2(Vector2.ZERO, texture.get_size())
	rect.position = sprite.offset - (rect.size * 0.5 if sprite.centered else Vector2.ZERO)
	return stage.global_transform.affine_inverse() * sprite.global_transform * rect

func _fit_character() -> void:
	if not is_instance_valid(character_instance) or not visual_bounds.has_area():
		return
	var available := Vector2(viewport.size) - Vector2(20, 20)
	var factor := minf(available.x / visual_bounds.size.x, available.y / visual_bounds.size.y)
	stage.scale = Vector2.ONE * maxf(factor, 0.01)
	stage.position = Vector2(viewport.size) * 0.5 - Vector2(0, 5) - visual_bounds.get_center() * stage.scale
	resting_position = stage.position
	resting_scale = stage.scale
	shadow.position = stage.transform * character_instance.transform * penguin.transform * penguin.feet_marker.position
	shadow.show()
