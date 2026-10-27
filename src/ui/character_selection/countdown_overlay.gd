extends Control

@onready var panel: PanelContainer = $CenterContainer/PanelContainer
@onready var number_label: Label = $CenterContainer/PanelContainer/NumberLabel

var pulse: Tween


func _ready() -> void:
	hide()


func show_step(text: String, duration: float) -> void:
	stop_animation()
	number_label.text = text
	show()
	panel.pivot_offset = panel.size / 2.0
	panel.scale = Vector2.ONE * 0.15
	var viewport_size := get_viewport_rect().size
	var target_scale: float = minf(
		viewport_size.y * 0.75 / panel.size.y,
		viewport_size.x * 0.85 / panel.size.x
	)
	pulse = create_tween()
	pulse.tween_property(panel, "scale", Vector2.ONE * target_scale, duration)


func cancel() -> void:
	stop_animation()
	hide()


func stop_animation() -> void:
	if pulse != null and pulse.is_valid():
		pulse.kill()
	pulse = null
