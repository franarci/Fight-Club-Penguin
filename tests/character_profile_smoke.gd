extends SceneTree


func _initialize() -> void:
	call_deferred("run_checks")


func run_checks() -> void:
	var manager = root.get_node("PlayerManager")
	manager.clear_players()
	var home = load("res://src/ui/home/Home.tscn").instantiate()
	root.add_child(home)
	assert(home.get_node("CenterContainer/VBoxContainer/OptionsButton").visible)
	assert(home.play_button.has_focus())
	home.free()
	var selector = load("res://src/ui/character_selection/character_select.tscn").instantiate()
	root.add_child(selector)
	selector.set_process(false)
	for slot in selector.player_slots:
		slot.set_process(false)
	selector.activate_player_slot(-1)
	var card = selector.player_slots[0]
	assert(card.characters[0].key == "Gunner")
	assert(is_equal_approx(card.speed_stat.bar.value, 90.0))
	assert(is_equal_approx(card.strength_stat.bar.value, 20.0))
	assert(is_equal_approx(card.resistance_stat.bar.value, 50.0))
	card.next()
	assert(card.characters[card.selected_character].key == "Demolisher")
	assert(is_equal_approx(card.speed_stat.bar.value, 82.5))
	assert(is_equal_approx(card.strength_stat.bar.value, 80.0))
	assert(is_equal_approx(card.resistance_stat.bar.value, 50.0))
	for i in range(2):
		card.next()
		assert(card.speed_stat.bar.value == 50 and card.strength_stat.bar.value == 50 and card.resistance_stat.bar.value == 50)
	var character := Node2D.new()
	var body := CharacterBody2D.new()
	body.set_script(load("res://src/entities/prototypes/penguin/penguin_base.gd"))
	character.add_child(body)
	body.owner = character
	body.set("base_speed", 100.0)
	body.set("mass", 1.6)
	var weapon = load("res://src/entities/prototypes/weapons/ranged/gunner_rifle_data.tres").duplicate()
	weapon.damage = 25.0
	body.set("starting_weapon_data", weapon)
	var modified := PackedScene.new()
	assert(modified.pack(character) == OK)
	character.free()
	var data := CharacterData.new()
	data.character_scene = modified
	var profile := data.get_selection_profile()
	assert(is_equal_approx(profile["speed"], 50.0))
	assert(is_equal_approx(profile["strength"], 50.0))
	assert(is_equal_approx(profile["resistance"], 80.0))
	assert(card.characters[0].get_selection_profile()["strength"] == 20)
	selector.free()
	manager.clear_players()
	print("PASS: Options available, profiles derived from gameplay scenes, preview updates, prototype fallback and isolated resource changes")
	quit()
