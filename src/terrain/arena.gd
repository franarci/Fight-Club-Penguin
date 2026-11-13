extends Node2D

## Arena size in world pixels; independent of the window and camera zoom.
@export var world_size := Vector2(1843.2, 1036.8)
@export var background_margin: float = 1536.0

func _ready() -> void:
	_apply_world_size()


func _apply_world_size() -> void:
	# The artwork and polygon share the image's original pixel coordinates.
	# Scale their common parent together, independently of camera zoom.
	var image_size: Vector2 = $TextureRect.texture.get_size()
	scale = world_size / image_size
	var margin := Vector2.ONE * background_margin / scale
	var ocean: ColorRect = $OceanBackdrop
	ocean.position = -margin
	ocean.size = image_size + margin * 2.0
	(ocean.material as ShaderMaterial).set_shader_parameter("world_dimensions", world_size + Vector2.ONE * background_margin * 2.0)
