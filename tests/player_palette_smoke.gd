extends SceneTree

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var characters: Array[Node] = []
	for index in range(4):
		var scene = load("res://src/entities/prototypes/characters/Demolisher.tscn").instantiate()
		scene.get_child(0).setup(index, -1)
		root.add_child(scene)
		var penguin = scene.get_child(0)
		penguin.set_physics_process(false)
		penguin.current_weapon.set_process(false)
		characters.append(penguin)
		var expected: Color = root.get_node("PlayerManager").get_player_color(index)
		assert(penguin.modulate == Color.WHITE)
		assert(penguin.body.material is ShaderMaterial)
		assert(penguin.body.material != penguin.equipment_palette)
		assert(penguin.body.material.get_shader_parameter("player_color") == expected)
		assert(penguin.body.material.get_shader_parameter("preserve_original") == (index == 0))
		assert(penguin.arm.material == penguin.body.material)
		assert(penguin.current_weapon.body.material == null)
		assert(penguin.player_arrow.color == expected)
		assert(penguin.player_label.get_theme_color("font_color") == expected)
		if index > 0:
			assert(penguin.body.material != characters[0].body.material)
	var player_one_color: Color = characters[0].body.material.get_shader_parameter("player_color")
	characters[1].apply_equipment_color(Color.MAGENTA)
	assert(characters[0].body.material.get_shader_parameter("player_color") == player_one_color)
	characters[0].body.self_modulate.a = 0.5
	assert(characters[0].body.material.get_shader_parameter("player_color") == player_one_color)
	for penguin in characters:
		penguin.get_parent().free()
	print("PASS: four independent palette materials, same-class players, unmodified weapons, identity indicators and transparency retained")
	quit()
