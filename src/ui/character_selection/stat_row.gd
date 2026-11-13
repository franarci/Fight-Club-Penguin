extends HBoxContainer
class_name StatRow

@onready var name_label: Label = $NameLabel
@onready var bar: ProgressBar = $Bar


func configure(attribute_name: String, value: float) -> void:
	name_label.text = attribute_name
	bar.value = clampf(value, bar.min_value, bar.max_value)
