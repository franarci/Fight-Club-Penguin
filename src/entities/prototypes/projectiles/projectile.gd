extends Sprite2D
class_name Projectile

signal hit(target: Node2D, amount: float, source: Node2D, hit_direction: Vector2)

@export_category("Projectile")
@export var speed: float = 800.0
@export var damage: float = 10.0
@export_range(0.01, 30.0) var lifetime: float = 2.0
@export_flags_2d_physics var collision_mask: int = 1
@export var remove_offscreen: bool = true
@export var screen_margin: float = 32.0

@onready var lifetime_timer: Timer = $LifetimeTimer
@onready var hitbox: Area2D = $Hitbox

var direction := Vector2.RIGHT
var shooter: Node2D
var _active := false
var _removed := false
var _excluded: Array[RID] = []

# Set launch data before entering the tree; @onready children exist after add_child.
func initialize(container: Node, spawn_position: Vector2, p_direction: Vector2,
		p_shooter: Node2D = null, p_speed: float = -1.0, p_damage: float = -1.0) -> void:
	direction = p_direction.normalized()
	shooter = p_shooter
	if p_speed >= 0.0:
		speed = p_speed
	if p_damage >= 0.0:
		damage = p_damage
	container.add_child(self)
	global_position = spawn_position
	global_rotation = direction.angle()
	hitbox.collision_mask = collision_mask
	_excluded.append(hitbox.get_rid())
	if is_instance_valid(shooter):
		_exclude_shooter(shooter)
	_active = direction != Vector2.ZERO
	if not _active:
		_remove()
		return
	lifetime_timer.start(lifetime)

func _exclude_shooter(node: Node) -> void:
	if node is CollisionObject2D:
		_excluded.append(node.get_rid())
	for child in node.get_children():
		_exclude_shooter(child)

func _physics_process(delta: float) -> void:
	if not _active or _removed:
		return
	var next_position := global_position + direction * speed * delta
	# Sweep the travel segment so fast bullets cannot jump through thin targets.
	var query := PhysicsRayQueryParameters2D.create(global_position, next_position, collision_mask, _excluded)
	query.collide_with_areas = true
	query.hit_from_inside = true
	var collision := get_world_2d().direct_space_state.intersect_ray(query)
	if not collision.is_empty():
		global_position = collision["position"]
		_handle_hit(collision["collider"] as Node2D)
		return
	global_position = next_position
	if remove_offscreen:
		var screen_position := get_viewport().get_canvas_transform() * global_position
		if not get_viewport().get_visible_rect().grow(screen_margin).has_point(screen_position):
			_remove()

func _is_shooter(target: Node2D) -> bool:
	return is_instance_valid(shooter) and (target == shooter or shooter.is_ancestor_of(target))

func _handle_hit(target: Node2D) -> void:
	if _removed or target == null or _is_shooter(target):
		return
	# Mark consumed before notifying listeners, preventing duplicate hits.
	_remove()
	var source: Node2D = shooter if is_instance_valid(shooter) else null
	hit.emit(target, damage, source, direction)
	if target.has_method("receive_damage"):
		target.receive_damage(damage, source, direction)
	elif target.has_method("notify_hit"):
		target.notify_hit()

func _on_hitbox_body_entered(body: Node2D) -> void:
	_handle_hit(body)

func _on_hitbox_area_entered(area: Area2D) -> void:
	_handle_hit(area)

func _on_lifetime_timer_timeout() -> void:
	_remove()

func _remove() -> void:
	if _removed:
		return
	_removed = true
	_active = false
	lifetime_timer.stop()
	hitbox.set_deferred("monitoring", false)
	queue_free()
