extends PanelContainer

const Heart = preload("res://src/ui/arena/heart.gd")
var hearts: Array[Control] = []
var health_bar: ProgressBar
var health_label: Label
var observed_penguin: Penguin


func configure(player: Dictionary, right_side: bool) -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var slot: int = player["slot"]
	var color: Color = PlayerManager.get_player_color(slot)
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color("101d32", 0.95)
	panel.border_color = color
	panel.set_border_width_all(2)
	panel.set_corner_radius_all(12)
	panel.content_margin_left = 12
	panel.content_margin_right = 12
	panel.content_margin_top = 10
	panel.content_margin_bottom = 10
	panel.shadow_color = Color(0, 0, 0, 0.25)
	panel.shadow_size = 4
	add_theme_stylebox_override("panel", panel)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 12)
	add_child(row)
	var badge := PanelContainer.new()
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.custom_minimum_size = Vector2(48, 48)
	var badge_style := StyleBoxFlat.new()
	badge_style.bg_color = color
	badge_style.set_corner_radius_all(8)
	badge.add_theme_stylebox_override("panel", badge_style)
	var identifier := Label.new()
	identifier.text = "P%d" % (slot + 1)
	identifier.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	identifier.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	identifier.add_theme_font_size_override("font_size", 22)
	identifier.add_theme_color_override("font_color", Color("101d32"))
	badge.add_child(identifier)
	var info := VBoxContainer.new()
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.add_theme_constant_override("separation", 6)
	var title := Label.new()
	var character: CharacterData = player.get("character")
	title.text = character.key.to_upper() if character != null else "PLAYER %d" % (slot + 1)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if right_side else HORIZONTAL_ALIGNMENT_LEFT
	title.add_theme_font_size_override("font_size", 13)
	title.add_theme_color_override("font_color", Color("dbe9ff"))
	info.add_child(title)
	var health_header := HBoxContainer.new()
	health_header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var caption := Label.new()
	caption.text = "HP"
	caption.add_theme_font_size_override("font_size", 11)
	caption.add_theme_color_override("font_color", Color("a5b8d0"))
	caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	health_header.add_child(caption)
	health_label = Label.new()
	health_label.add_theme_font_size_override("font_size", 12)
	health_label.add_theme_color_override("font_color", Color("edf5ff"))
	health_header.add_child(health_label)
	info.add_child(health_header)
	health_bar = ProgressBar.new()
	health_bar.name = "HealthBar"
	health_bar.custom_minimum_size = Vector2(144, 12)
	health_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	health_bar.show_percentage = false
	health_bar.fill_mode = ProgressBar.FILL_END_TO_BEGIN if right_side else ProgressBar.FILL_BEGIN_TO_END
	var health_background := StyleBoxFlat.new()
	health_background.bg_color = Color("07101f")
	health_background.border_color = Color("34465e")
	health_background.set_border_width_all(1)
	health_background.set_corner_radius_all(4)
	var health_fill := StyleBoxFlat.new()
	health_fill.bg_color = color
	health_fill.set_corner_radius_all(4)
	health_bar.add_theme_stylebox_override("background", health_background)
	health_bar.add_theme_stylebox_override("fill", health_fill)
	info.add_child(health_bar)
	set_health(0.0, 100.0)
	var heart_row := HBoxContainer.new()
	heart_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	heart_row.alignment = BoxContainer.ALIGNMENT_END if right_side else BoxContainer.ALIGNMENT_BEGIN
	heart_row.add_theme_constant_override("separation", 5)
	info.add_child(heart_row)
	for i in PlayerManager.STARTING_LIVES:
		var heart := Heart.new()
		heart_row.add_child(heart)
		hearts.append(heart)
	row.add_child(info if right_side else badge)
	row.add_child(badge if right_side else info)
	set_lives(int(player.get("lives", PlayerManager.STARTING_LIVES)))


func set_lives(lives: int) -> void:
	for i in hearts.size():
		hearts[i].set("filled", i < lives)


func bind_penguin(penguin: Penguin) -> void:
	if is_instance_valid(observed_penguin) and observed_penguin.health_changed.is_connected(set_health):
		observed_penguin.health_changed.disconnect(set_health)
	observed_penguin = penguin
	penguin.health_changed.connect(set_health)
	set_health(penguin.current_health, penguin.max_health)


func set_health(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
	health_label.text = "%d / %d" % [ceili(current), ceili(maximum)]
