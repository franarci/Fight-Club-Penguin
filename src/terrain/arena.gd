extends Node2D

## Arena size in world pixels; independent of the window and camera zoom.
@export var world_size := Vector2(1843.2, 1036.8)
@export var background_margin: float = 0.0

func _ready() -> void:
	_apply_world_size()


func set_background_margin(value: float) -> void:
	background_margin = maxf(value, 0.0)
	if is_node_ready():
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
	var ocean_material := ocean.material as ShaderMaterial
	ocean_material.set_shader_parameter("world_dimensions", world_size + Vector2.ONE * background_margin * 2.0)
	ocean_material.set_shader_parameter("arena_dimensions", world_size)
	ocean_material.set_shader_parameter("background_margin", background_margin)
	ocean_material.set_shader_parameter("source_texture", $TextureRect.texture)
