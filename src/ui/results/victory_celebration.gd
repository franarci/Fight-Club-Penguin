extends Node

class SnowPuff extends Node2D:
	var age := 0.0

	func _process(delta: float) -> void:
		age += delta
		if age >= 0.6:
			queue_free()
		else:
			queue_redraw()

	func _draw() -> void:
		for index in range(12):
			var angle := PI + float(index) * PI / 11.0
			var speed := 25.0 + float(index % 4) * 9.0
			var point := Vector2(cos(angle), sin(angle)) * speed * age + Vector2(0, 65.0 * age * age)
			draw_circle(point, 1.7, Color(0.7, 0.93, 1.0, 1.0 - age / 0.6))

const CYCLE_DURATION := 2.6

var winner: Penguin
var kind: StringName
var running := false
var elapsed := 0.0
var body_position := Vector2.ZERO
var body_scale := Vector2.ONE
var weapon_position := Vector2.ZERO
var arm_position := Vector2.ZERO
var body_process_mode := Node.PROCESS_MODE_INHERIT
var weapon_process_mode := Node.PROCESS_MODE_INHERIT
var weapon_sprite: AnimatedSprite2D
var puffs: Array[Node2D] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(false)

func start(character: Penguin, character_kind: StringName) -> void:
	stop()
	winner = character
	kind = character_kind
	body_position = winner.body.position
	body_scale = winner.body.scale
	weapon_position = winner.weapon_socket.position
	arm_position = winner.arm.position if is_instance_valid(winner.arm) else Vector2.ZERO
	body_process_mode = winner.body.process_mode
	winner.body.process_mode = Node.PROCESS_MODE_ALWAYS
	if is_instance_valid(winner.current_weapon):
		weapon_sprite = winner.current_weapon.body
		weapon_process_mode = weapon_sprite.process_mode
		weapon_sprite.process_mode = Node.PROCESS_MODE_ALWAYS
	elapsed = 0.0
	running = true
	set_process(true)

func stop() -> void:
	running = false
	set_process(false)
	if is_instance_valid(winner) and is_instance_valid(winner.body):
		winner.body.position = body_position
		winner.body.scale = body_scale
		winner.body.process_mode = body_process_mode
		winner.weapon_socket.position = weapon_position
		if is_instance_valid(winner.arm):
			winner.arm.position = arm_position
	if is_instance_valid(weapon_sprite):
		weapon_sprite.process_mode = weapon_process_mode
	for puff in puffs:
		if is_instance_valid(puff):
			puff.queue_free()
	puffs.clear()
	winner = null
	weapon_sprite = null

func _process(delta: float) -> void:
	if not running or not is_instance_valid(winner):
		return
	var previous := fmod(elapsed, CYCLE_DURATION)
	elapsed += delta
	var time := fmod(elapsed, CYCLE_DURATION)
	var jump := 0.0
	var side := 0.0
	match kind:
		&"Demolisher":
			jump = _hop(time, 0.08, 0.88) * 36.0
			if previous < 0.88 and time >= 0.88:
				_emit_snow()
		&"Hunter":
			jump = _hop(time, 0.04, 0.68) * 28.0
		&"Scout":
			var left_hop := _hop(time, 0.04, 0.43)
			var right_hop := _hop(time, 0.53, 0.92)
			jump = (left_hop + right_hop) * 19.0
			side = (right_hop - left_hop) * 11.0
		_:
			jump = (_hop(time, 0.04, 0.46) + _hop(time, 0.57, 0.99)) * 23.0
	var scale_factor := winner.global_scale.abs().max(Vector2(0.001, 0.001))
	var offset := Vector2(side, -jump) / scale_factor
	winner.body.position = body_position + offset
	winner.weapon_socket.position = weapon_position + offset
	if is_instance_valid(winner.arm):
		winner.arm.position = arm_position + offset

func _hop(time: float, start_time: float, end_time: float) -> float:
	if time < start_time or time > end_time:
		return 0.0
	return sin((time - start_time) / (end_time - start_time) * PI)

func _emit_snow() -> void:
	var puff := SnowPuff.new()
	puff.process_mode = Node.PROCESS_MODE_ALWAYS
	puff.z_index = -1
	var rect := winner.get_body_display_rect()
	puff.position = body_position + Vector2(rect.get_center().x, rect.end.y) * body_scale
	winner.add_child(puff)
	for index in range(puffs.size() - 1, -1, -1):
		if not is_instance_valid(puffs[index]):
			puffs.remove_at(index)
	puffs.append(puff)

func _exit_tree() -> void:
	stop()
