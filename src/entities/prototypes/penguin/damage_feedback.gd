extends Node
class_name DamageFeedback

@export_range(0.01, 0.5, 0.01) var flash_duration: float = 0.1
@export_range(0.0, 20.0, 0.5) var tilt_degrees: float = 8.0
@export_range(0.01, 0.5, 0.01) var recovery_duration: float = 0.18

@onready var body: AnimatedSprite2D = $"../Body"
@onready var rest_rotation: float = body.rotation
@onready var hit_audio: AudioStreamPlayer = $HitAudio

var effect_tween: Tween
var flash_material: ShaderMaterial
var active := false


func play_hit_sound() -> void:
	hit_audio.play()


func play(hit_direction: Vector2 = Vector2.RIGHT) -> void:
	reset()
	active = true
	flash_material = body.material as ShaderMaterial
	_set_flash(1.0)
	var side := -1.0 if hit_direction.x < 0.0 else 1.0
	var tilt := rest_rotation + deg_to_rad(tilt_degrees) * side
	effect_tween = create_tween().set_parallel(true)
	effect_tween.tween_method(_set_flash, 1.0, 0.0, flash_duration).set_delay(0.025)
	effect_tween.tween_property(body, "rotation", tilt, 0.035)
	effect_tween.tween_property(body, "rotation", rest_rotation, recovery_duration).from(tilt).set_delay(0.035).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	effect_tween.chain().tween_callback(reset)


func _set_flash(amount: float) -> void:
	if flash_material != null:
		flash_material.set_shader_parameter("damage_flash", amount)


func reset() -> void:
	if effect_tween != null:
		effect_tween.kill()
		effect_tween = null
	_set_flash(0.0)
	flash_material = null
	if is_instance_valid(body):
		body.rotation = rest_rotation
	active = false


func _exit_tree() -> void:
	reset()
