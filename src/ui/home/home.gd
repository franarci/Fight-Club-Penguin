extends Control


@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var menu_layout: Control = $CenterContainer
@onready var menu: VBoxContainer = $CenterContainer/VBoxContainer
@onready var title_top: Label = $CenterContainer/VBoxContainer/Title/Top
@onready var title_bottom: Label = $CenterContainer/VBoxContainer/Title/Bottom
@onready var options_button: Button = $CenterContainer/VBoxContainer/OptionsButton
@onready var audio_options: Control = $AudioOptions

var menu_device := -1


func _ready() -> void:
	Music.play_menu()
	options_button.pressed.connect(_open_options)
	audio_options.closed.connect(options_button.grab_focus)
	resized.connect(_layout_home)
	_layout_home()
	play_button.grab_focus()


func _layout_home() -> void:
	var factor := clampf(minf(size.x / 1152.0, size.y / 648.0), 0.5, 1.8)
	menu_layout.position = Vector2(size.x * 0.045, size.y * 0.09)
	menu_layout.size = Vector2(size.x * 0.6, size.y * 0.8)
	title_top.add_theme_font_size_override("font_size", roundi(58 * factor))
	title_bottom.add_theme_font_size_override("font_size", roundi(80 * factor))
	menu.add_theme_constant_override("separation", roundi(36 * factor))
	for button in [play_button, options_button]:
		button.custom_minimum_size = Vector2(380 * factor, maxf(52, 68 * factor))
		button.add_theme_font_size_override("font_size", roundi(26 * factor))


func _on_play_button_pressed() -> void:
	PlayerManager.clear_players()
	get_tree().change_scene_to_file("res://Main.tscn")


func _open_options() -> void:
	audio_options.open(menu_device)


func _input(event: InputEvent) -> void:
	if audio_options.visible:
		audio_options.handle_input(event)
	elif event is InputEventKey or event is InputEventMouse:
		menu_device = -1
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		menu_device = event.device


func _unhandled_input(event: InputEvent) -> void:
	if audio_options.visible:
		return
	if not event is InputEventJoypadButton:
		return

	if not MultiplayerInput.device_actions.has(event.device):
		return

	var action: StringName = MultiplayerInput.get_action_name(
		event.device,
		"selection_accept"
	)

	if event.is_action_pressed(action):
		var focused_button := get_viewport().gui_get_focus_owner() as Button

		if focused_button != null and not focused_button.disabled:
			get_viewport().set_input_as_handled()
			menu_device = event.device
			focused_button.pressed.emit()
