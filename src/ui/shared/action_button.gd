extends Button
class_name ActionButton

const ControlPrompt = preload("res://src/ui/shared/control_prompt.gd")

var caption := ""
var prompt: HBoxContainer
var content_padding := Vector2(8, 4)
@onready var minimum_size_floor := custom_minimum_size


func _ready() -> void:
	flat = false


func configure(value: String, devices: Array, actions: Array) -> void:
	caption = value
	text = ""
	tooltip_text = value
	accessibility_name = value
	if is_instance_valid(prompt):
		remove_child(prompt)
		prompt.queue_free()
	prompt = ControlPrompt.new()
	prompt.configure(value, devices, actions)
	prompt.minimum_size_changed.connect(_fit_content)
	prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for control in prompt.get_children():
		if control is Control:
			control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(prompt)
	prompt.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	prompt.offset_left = content_padding.x
	prompt.offset_top = content_padding.y
	prompt.offset_right = -content_padding.x
	prompt.offset_bottom = -content_padding.y
	_fit_content()
	queue_redraw()


func _fit_content() -> void:
	if is_instance_valid(prompt):
		custom_minimum_size = minimum_size_floor.max(prompt.get_combined_minimum_size() + content_padding * 2.0)


func _draw() -> void:
	if is_instance_valid(prompt):
		prompt.modulate = Color(1, 1, 1, 0.4) if disabled else Color.WHITE
