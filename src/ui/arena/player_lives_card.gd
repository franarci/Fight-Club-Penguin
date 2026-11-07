extends PanelContainer
class_name PlayerLivesCard

@onready var content: HBoxContainer = $MarginContainer/Content
@onready var portrait_frame: PanelContainer = $MarginContainer/Content/PortraitFrame
@onready var portrait: TextureRect = $MarginContainer/Content/PortraitFrame/Portrait
@onready var player_id: Label = $MarginContainer/Content/PortraitFrame/PlayerId
@onready var title: Label = $MarginContainer/Content/Info/Title
@onready var health_header: HBoxContainer = $MarginContainer/Content/Info/HealthHeader
@onready var health_label: Label = $MarginContainer/Content/Info/HealthHeader/HealthLabel
@onready var health_bar: ProgressBar = $MarginContainer/Content/Info/HealthBar
@onready var weapon_status: Control = $MarginContainer/Content/Info/WeaponStatus
@onready var ammo_pips: AmmoBullets = $MarginContainer/Content/Info/WeaponStatus/AmmoPips
@onready var reload_bar: ProgressBar = $MarginContainer/Content/Info/WeaponStatus/ReloadBar
@onready var weapon_meter: VBoxContainer = $MarginContainer/Content/Info/WeaponMeter
@onready var weapon_meter_label: Label = $MarginContainer/Content/Info/WeaponMeter/WeaponMeterLabel
@onready var weapon_meter_bar: ProgressBar = $MarginContainer/Content/Info/WeaponMeter/WeaponMeterBar
@onready var hearts_row: HBoxContainer = $MarginContainer/Content/Info/Hearts

var hearts: Array[Control] = []
var observed_penguin: Penguin
var observed_ranged_weapon: RangedWeapon
var observed_melee_weapon: MeleeWeapon
var right_side := false


func _ready() -> void:
	for child in hearts_row.get_children():
		hearts.append(child)


func configure(player: Dictionary, p_right_side: bool) -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	right_side = p_right_side
	var slot: int = player["slot"]
	var color: Color = PlayerManager.get_player_color(slot)
	var panel_style := get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	panel_style.border_color = color
	add_theme_stylebox_override("panel", panel_style)
	var portrait_style := portrait_frame.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	portrait_style.border_color = color
	portrait_frame.add_theme_stylebox_override("panel", portrait_style)
	var health_fill := health_bar.get_theme_stylebox("fill").duplicate() as StyleBoxFlat
	health_fill.bg_color = color
	health_bar.add_theme_stylebox_override("fill", health_fill)
	var character: CharacterData = player.get("character")
	title.text = character.key.to_upper() if character != null else "PLAYER %d" % (slot + 1)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if right_side else HORIZONTAL_ALIGNMENT_LEFT
	player_id.text = "P%d" % (slot + 1)
	portrait.texture = character.Img if character != null else null
	portrait_frame.visible = character != null
	content.move_child(portrait_frame, 1 if right_side else 0)
	health_bar.fill_mode = ProgressBar.FILL_END_TO_BEGIN if right_side else ProgressBar.FILL_BEGIN_TO_END
	health_header.alignment = BoxContainer.ALIGNMENT_END if right_side else BoxContainer.ALIGNMENT_BEGIN
	hearts_row.alignment = BoxContainer.ALIGNMENT_END if right_side else BoxContainer.ALIGNMENT_BEGIN
	weapon_status.visible = character != null and character.key == "Gunner"
	ammo_pips.configure(12, 12, right_side)
	reload_bar.fill_mode = ProgressBar.FILL_END_TO_BEGIN if right_side else ProgressBar.FILL_BEGIN_TO_END
	ammo_pips.show()
	reload_bar.hide()
	set_reload_progress(false, 0.0)
	weapon_meter.hide()
	set_lives(int(player.get("lives", PlayerManager.STARTING_LIVES)))
	set_health(100.0, 100.0)


func set_lives(lives: int) -> void:
	for index in hearts.size():
		hearts[index].set("filled", index < lives)


func bind_penguin(penguin: Penguin) -> void:
	if is_instance_valid(observed_penguin) and observed_penguin.health_changed.is_connected(set_health):
		observed_penguin.health_changed.disconnect(set_health)
	if is_instance_valid(observed_ranged_weapon):
		if observed_ranged_weapon.ammo_changed.is_connected(set_ammo):
			observed_ranged_weapon.ammo_changed.disconnect(set_ammo)
		if observed_ranged_weapon.reload_changed.is_connected(set_reload_progress):
			observed_ranged_weapon.reload_changed.disconnect(set_reload_progress)
	if is_instance_valid(observed_melee_weapon) and observed_melee_weapon.charge_progress_changed.is_connected(set_charge_progress):
		observed_melee_weapon.charge_progress_changed.disconnect(set_charge_progress)
	observed_penguin = penguin
	penguin.health_changed.connect(set_health)
	set_health(penguin.current_health, penguin.max_health)
	var ranged_weapon := penguin.current_weapon as RangedWeapon
	if is_instance_valid(ranged_weapon) and ranged_weapon.magazine_enabled:
		observed_ranged_weapon = ranged_weapon
		weapon_status.show()
		ranged_weapon.ammo_changed.connect(set_ammo)
		ranged_weapon.reload_changed.connect(set_reload_progress)
		set_ammo(ranged_weapon.current_ammo, ranged_weapon.ranged_data.magazine_capacity)
		var reload_progress := 1.0 - ranged_weapon.reload_time_left / ranged_weapon.ranged_data.reload_duration if ranged_weapon.reload_time_left > 0.0 else 0.0
		set_reload_progress(ranged_weapon.reload_time_left > 0.0, reload_progress)
	else:
		observed_ranged_weapon = null
		weapon_status.hide()
	var melee_weapon := penguin.current_weapon as MeleeWeapon
	if is_instance_valid(melee_weapon):
		observed_melee_weapon = melee_weapon
		melee_weapon.charge_progress_changed.connect(set_charge_progress)
		weapon_meter_label.text = "CHARGE"
		set_charge_progress(0.0, false)
	else:
		observed_melee_weapon = null
		weapon_meter.hide()


func set_health(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
	health_label.text = "%d / %d" % [ceili(current), ceili(maximum)]


func set_ammo(current: int, capacity: int) -> void:
	if ammo_pips.capacity != capacity:
		ammo_pips.configure(capacity, current, right_side)
	else:
		ammo_pips.set_current_ammo(current)


func set_reload_progress(is_reloading: bool, progress: float) -> void:
	var show_reload := is_reloading and weapon_status.visible
	ammo_pips.visible = not show_reload
	reload_bar.visible = show_reload
	reload_bar.value = clampf(progress, 0.0, 1.0) * 100.0


func set_weapon_meter(label: String, progress: float, visible: bool = true) -> void:
	weapon_meter_label.text = label
	weapon_meter_bar.value = clampf(progress, 0.0, 1.0) * 100.0
	weapon_meter_bar.fill_mode = ProgressBar.FILL_END_TO_BEGIN if right_side else ProgressBar.FILL_BEGIN_TO_END
	var fill_style := weapon_meter_bar.get_theme_stylebox("fill").duplicate() as StyleBoxFlat
	fill_style.bg_color = Color("#f2b64c").lerp(Color("#ff3030"), clampf(progress, 0.0, 1.0))
	weapon_meter_bar.add_theme_stylebox_override("fill", fill_style)
	weapon_meter.visible = visible


func set_charge_progress(progress: float, _visible: bool) -> void:
	# Keep the melee charge meter present while idle so players can track it at a glance.
	set_weapon_meter("CHARGE", progress, true)
