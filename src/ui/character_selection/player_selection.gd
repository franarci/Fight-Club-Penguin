extends Control
class_name PlayerSelection
var device: int = -99
var player_index: int
var slot_index := -1
@onready var player_label: Label = $VBoxContainer/PlayerLabel
@onready var character_container: CenterContainer = $VBoxContainer/CharacterCenter
@onready var navigation: HBoxContainer = $VBoxContainer/Navigation
#@onready var character: Sprite2D = $VBoxContainer/CharacterCenter/CharacterArea/Character
@onready var character: TextureRect = $VBoxContainer/CharacterCenter/Character
@onready var border_blink_timer: Timer = $BorderBlinkTimer
@onready var stats_container: VBoxContainer = $VBoxContainer/StatsMargin/StatsContainer
@onready var speed_stat: StatRow = $VBoxContainer/StatsMargin/StatsContainer/SpeedStat
@onready var strength_stat: StatRow = $VBoxContainer/StatsMargin/StatsContainer/StrengthStat
@onready var resistance_stat: StatRow = $VBoxContainer/StatsMargin/StatsContainer/ResistanceStat
@onready var selected_character:int = 0
@onready var select_button: Button = $VBoxContainer/Navigation/Select
@onready var prev_button: Button = $VBoxContainer/Navigation/Prev
@onready var next_button: Button = $VBoxContainer/Navigation/Next
var is_ready := false

@export var characters: Array[CharacterData] = []


signal ready_changed
var active := false
var border_style: StyleBoxFlat
var player_border_color: Color
var border_visible := true

#func setup(p_device: int, p_index: int) -> void:
	#device = p_device
	#player_index = p_index
#
	#$PlayerLabel.text = "PLAYER %d" % (player_index + 1)
#
	##update_character()
func activate(p_device: int, player_number: int) -> void:
	is_ready = false
	active = true
	device = p_device

	player_label.text = "JUGADOR %d" % (player_number + 1)
	select_button.text = "Seleccionar"
	var player_color = PlayerManager.get_player_color(player_number)
	set_player_color(player_color)
	character_container.visible = true
	stats_container.show()
	navigation.visible = true
	prev_button.show()
	next_button.show()
	selected_character = 0
	update_character_preview()
	set_border_visible(true)
	border_blink_timer.start()

func deactivate() -> void:
	is_ready = false
	if active:
		PlayerManager.remove_player(device)
		
	active = false
	device = -99

	player_label.text = "PRESIONÁ\nSTART"

	character_container.visible = false
	stats_container.hide()
	navigation.visible = false
	border_blink_timer.stop()
	set_border_visible(false)


func _ready() -> void:
	border_style = get_theme_stylebox("panel").duplicate() as StyleBoxFlat

	border_style.content_margin_left = 12
	border_style.content_margin_right = 12
	border_style.content_margin_top = 12
	border_style.content_margin_bottom = 16

	add_theme_stylebox_override("panel", border_style)


func next() -> void:
	if not active or is_ready:
		return

	selected_character = (selected_character + 1) % characters.size()
	update_character_preview()

func prev():
	if not active or is_ready:
		return

	selected_character = (selected_character - 1 + characters.size()) % characters.size()
	update_character_preview()

func _process(_delta: float) -> void:
	if not active:
		return

	if not is_ready:
		if MultiplayerInput.is_action_just_pressed(device, "left"):
			prev()

		if MultiplayerInput.is_action_just_pressed(device, "right"):
			next()

		if MultiplayerInput.is_action_just_pressed(device, "selection_accept"):
			confirm_character()

	if MultiplayerInput.is_action_just_pressed(device, "selection_cancel"):
		cancel_selection()
		
func confirm_character() -> void:
	if not active or is_ready:
		return

	is_ready = true

	PlayerManager.set_character(
		device,
		characters[selected_character]
	)
	PlayerManager.set_ready(device, true)

	prev_button.hide()
	next_button.hide()
	select_button.text = "Cambiar"

	border_blink_timer.stop()
	set_border_visible(true)

	ready_changed.emit()

func cancel_selection() -> void:
	if not active:
		return

	if is_ready:
		is_ready = false
		PlayerManager.set_ready(device, false)

		prev_button.show()
		next_button.show()
		select_button.text = "Seleccionar"

		set_border_visible(true)
		border_blink_timer.start()
	else:
		deactivate()

	ready_changed.emit()

func set_player_color(color: Color) -> void:
	border_style = get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	player_border_color = Color("#120305")

	border_style.border_color = Color("#120305")
	border_style.border_width_left = 5
	border_style.border_width_top = 5
	border_style.border_width_right = 5
	border_style.border_width_bottom = 5

	add_theme_stylebox_override("panel", border_style)

func set_border_visible(value: bool) -> void:
	border_visible = value

	if border_style == null:
		return

	if not active:
		border_style.border_color = Color.TRANSPARENT
	elif is_ready or value:
		border_style.border_color = Color.WHITE
	else:
		border_style.border_color = Color.BLACK


func _on_border_blink_timer_timeout() -> void:
	if active and not is_ready:
		set_border_visible(not border_visible)

func _on_select_pressed() -> void:
	if not active:
		return

	if is_ready:
		cancel_selection()
	else:
		confirm_character()


func update_character_preview() -> void:
	var data: CharacterData = characters[selected_character]

	character.texture = data.Img
	speed_stat.configure("Velocidad", data.selection_speed)
	strength_stat.configure("Fuerza", data.selection_strength)
	resistance_stat.configure("Resistencia", data.selection_resistance)
