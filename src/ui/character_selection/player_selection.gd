extends Control
class_name PlayerSelection
var device: int = -99
var player_index: int
var slot_index := -1
@onready var player_label: Label = $VBoxContainer/PlayerLabel
@onready var character_container: CenterContainer = $VBoxContainer/CharacterCenter
@onready var navigation: HBoxContainer = $VBoxContainer/Navigation
@onready var select_center: CenterContainer = $VBoxContainer/SelectCenter
#@onready var character: Sprite2D = $VBoxContainer/CharacterCenter/CharacterArea/Character
@onready var character: TextureRect = $VBoxContainer/CharacterCenter/Character

@onready var selected_character:int = 0
var is_ready := false

@export var characters: Array[CharacterData] = []


signal ready_changed
var active := false

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

	player_label.text = "PLAYER %d" % (player_number+1)
	var player_color = PlayerManager.get_player_color(player_number)
	set_player_color(player_color)
	character_container.visible = true
	navigation.visible = true
	select_center.visible = true
	selected_character = 0
	character.texture = characters[selected_character].Img
func deactivate() -> void:
	is_ready = false
	if active:
		PlayerManager.remove_player(device)
		
	active = false
	device = -99

	player_label.text = "PRESS START"

	character_container.visible = false
	navigation.visible = false
	select_center.visible = false
func next() -> void:
	if not active or is_ready:
		return

	selected_character = (selected_character + 1) % characters.size()
	character.texture = characters[selected_character].Img
func prev():
	if not active or is_ready:
		return

	selected_character = (selected_character - 1 + characters.size()) % characters.size()
	character.texture = characters[selected_character].Img

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
		
func confirm_character():
	is_ready = true
	PlayerManager.set_character(
		device,
		characters[selected_character]
	)
	PlayerManager.set_ready(device, true)

	ready_changed.emit()
func cancel_selection():
	PlayerManager.set_ready(device, false)
	deactivate()
	ready_changed.emit()

func set_player_color(color: Color) -> void:
	var style := get_theme_stylebox("panel").duplicate() as StyleBoxFlat

	style.border_color = color

	style.border_width_left = 5
	style.border_width_top = 5
	style.border_width_right = 5
	style.border_width_bottom = 5

	add_theme_stylebox_override("panel", style)

func _on_select_pressed() -> void:
	pass # Replace with function body.
