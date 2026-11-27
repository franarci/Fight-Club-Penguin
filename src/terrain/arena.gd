@tool
extends Node2D

## Arena size in world pixels; independent of the window and camera zoom.
@export var world_size := Vector2(1843.2, 1036.8)
## The new background adds this many source-image pixels around the original map.
@export var background_padding_pixels := Vector2(640.0, 640.0):
	set(value):
		background_padding_pixels = Vector2(maxf(value.x, 0.0), maxf(value.y, 0.0))
		if is_node_ready():
			_apply_world_size()


## Conservative world-space padding available on every side of the arena.
var background_margin: float:
	get:
		var texture_rect := get_node_or_null("TextureRect") as TextureRect
		if texture_rect == null or texture_rect.texture == null:
			return 0.0
		var content_size := texture_rect.texture.get_size() - background_padding_pixels * 2.0
		if content_size.x <= 0.0 or content_size.y <= 0.0:
			return 0.0
		var map_scale := world_size / content_size
		return minf(background_padding_pixels.x * map_scale.x, background_padding_pixels.y * map_scale.y)


func _ready() -> void:
	_apply_world_size()


func _apply_world_size() -> void:
	var texture_rect := $TextureRect as TextureRect
	var image_size: Vector2 = texture_rect.texture.get_size()
	var content_size := image_size - background_padding_pixels * 2.0
	if content_size.x <= 0.0 or content_size.y <= 0.0:
		push_warning("El margen de agua deja un área de terreno inválida.")
		return

	# The original terrain occupies the centered image area. Keep its world scale
	# and collision polygon unchanged while exposing the new ocean around it.
	scale = world_size / content_size
	texture_rect.position = -background_padding_pixels
	texture_rect.size = image_size

	var wave_material := texture_rect.material as ShaderMaterial
	if wave_material != null:
		wave_material.set_shader_parameter("terrain_dimensions", image_size)
		wave_material.set_shader_parameter("mask_content_offset", background_padding_pixels)
		wave_material.set_shader_parameter("mask_content_dimensions", content_size)
