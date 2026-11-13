extends Control

@onready var penguin: TextureRect = $Penguin
@onready var scarf: Node2D = $Scarf


func _ready() -> void:
	resized.connect(_layout)
	_layout()


func _layout() -> void:
	var factor := minf(size.x / 1152.0, size.y / 648.0)
	penguin.size = Vector2(210, 210) * factor
	penguin.position = Vector2(size.x * 0.75, size.y * 0.52)
	scarf.position = penguin.position + penguin.size * Vector2(0.65, 0.455)
	scarf.scale = Vector2.ONE * factor
