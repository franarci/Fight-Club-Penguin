extends Node2D


func _ready() -> void:
	get_viewport().size_changed.connect(_fit_to_viewport)
	_fit_to_viewport()


func _fit_to_viewport() -> void:
	# The artwork and polygon share the image's original pixel coordinates.
	# Scale their common parent so they stay aligned at every window size.
	var image_size: Vector2 = $TextureRect.texture.get_size()
	scale = get_viewport_rect().size / image_size
