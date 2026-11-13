extends Node


func _ready() -> void:
	call_deferred("run_checks")


func run_checks() -> void:
	PlayerManager.clear_players()
	var selector = load("res://src/ui/character_selection/character_select.tscn").instantiate()
	add_child(selector)
	selector.set_process(false)
	var characters: Array[Node] = []
	for index in range(4):
		var card: PlayerSelection = selector.player_slots[index]
		card.set_process(false)
		var color: Color = PlayerManager.get_player_color(index)
		assert(card.slot_index == index)
		assert(card.get_theme_stylebox("panel").bg_color == color)
		selector.activate_player_slot(index - 1)
		assert(card.get_theme_stylebox("panel").bg_color == color)
		card.confirm_character()
		assert(card.get_theme_stylebox("panel").bg_color == color)
		var scene = load("res://src/entities/prototypes/characters/Gunner.tscn").instantiate()
		var penguin: Penguin = scene.get_child(0)
		penguin.setup(index, index - 1)
		add_child(scene)
		penguin.set_physics_process(false)
		penguin.current_weapon.set_process(false)
		assert(penguin.body.material.get_shader_parameter("player_color") == color)
		assert(not penguin.body.material.get_shader_parameter("preserve_original"))
		assert(penguin.player_arrow.color == color)
		assert(penguin.player_label.get_theme_color("font_color") == color)
		characters.append(scene)
	var hud = load("res://src/ui/arena/arena_hud.tscn").instantiate()
	add_child(hud)
	hud.show_players(PlayerManager.players)
	for index in range(4):
		var color: Color = PlayerManager.get_player_color(index)
		var card: PlayerLivesCard = hud.cards[index]
		assert(card.get_theme_stylebox("panel").border_color == color)
		assert(card.portrait_frame.get_theme_stylebox("panel").border_color == color)
		assert(card.health_bar.get_theme_stylebox("fill").bg_color == color)
	var target: Penguin = characters[0].get_child(0)
	var attacker: Penguin = characters[1].get_child(0)
	assert(target.receive_damage(1, attacker, Vector2.LEFT))
	assert(target.player_palette_instance.get_shader_parameter("damage_flash") == 1.0)
	await get_tree().create_timer(0.3).timeout
	assert(target.player_palette_instance.get_shader_parameter("damage_flash") == 0.0)
	for index in range(4):
		var penguin: Penguin = characters[index].get_child(0)
		assert(penguin.player_palette_instance.get_shader_parameter("player_color") == PlayerManager.get_player_color(index))
	var first: PlayerSelection = selector.player_slots[0]
	var last_color: Color = selector.player_slots[3].get_theme_stylebox("panel").bg_color
	first.cancel_selection()
	first.cancel_selection()
	assert(not first.active and first.border_style.border_color == Color.TRANSPARENT)
	assert(first.border_style.bg_color == PlayerManager.get_player_color(0))
	assert(selector.player_slots[3].get_theme_stylebox("panel").bg_color == last_color)
	selector.activate_player_slot(-1)
	assert(first.border_style.bg_color == PlayerManager.get_player_color(0))
	assert(first.border_style != selector.player_slots[3].border_style)
	for scene in characters:
		scene.free()
	hud.free()
	selector.free()
	PlayerManager.clear_players()
	print("PASS: four slot colors agree across empty/active/ready selector, equipment, identifiers and HUD; leaving/rejoining preserves isolated styles")
	get_tree().quit()
