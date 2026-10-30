extends HBoxContainer

const ControlHints = preload("res://src/ui/shared/control_hints.gd")

static var textures: Dictionary = {}


func configure(caption: String, devices: Array, actions: Array) -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 7)
	if not caption.is_empty():
		_add_label(caption)
	var seen := PackedStringArray()
	for device in devices:
		for action in actions:
			var paths: PackedStringArray = ControlHints.movement_icons(device) if action == "movement" else ControlHints.icon_paths(device, action)
			for path in paths:
				if seen.has(path):
					continue
				if not seen.is_empty():
					_add_label("/")
				seen.append(path)
				var texture: AtlasTexture = _texture(path)
				var icon := TextureRect.new()
				icon.texture = texture
				icon.custom_minimum_size = Vector2(32.0 * texture.get_width() / texture.get_height(), 32)
				icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
				icon.tooltip_text = ControlHints.movement(device) if action == "movement" else ControlHints.binding(device, action)
				add_child(icon)
			if paths.is_empty():
				var fallback: String = ControlHints.binding(device, action)
				if not fallback.is_empty() and not seen.has(fallback):
					seen.append(fallback)
					_add_label(fallback)


func _add_label(value: String) -> void:
	var label := Label.new()
	label.text = value
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 16)
	add_child(label)


static func _texture(path: String) -> AtlasTexture:
	if not textures.has(path):
		var source := load(path) as Texture2D
		var atlas := AtlasTexture.new()
		atlas.atlas = source
		atlas.region = source.get_image().get_used_rect()
		atlas.filter_clip = true
		textures[path] = atlas
	return textures[path]
