extends VBoxContainer
class_name EliminationFeed

@export_range(0.1, 10.0, 0.1) var message_duration := 3.0

var announced_slots: Dictionary = {}


func announce(slot: int) -> void:
	if announced_slots.has(slot):
		return
	announced_slots[slot] = true
	var message := Label.new()
	message.text = "Player %d eliminated!" % (slot + 1)
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.mouse_filter = Control.MOUSE_FILTER_IGNORE
	message.add_theme_font_size_override("font_size", 20)
	message.add_theme_color_override("font_color", PlayerManager.get_player_color(slot).lightened(0.4))
	message.add_theme_color_override("font_outline_color", Color("07101f"))
	message.add_theme_constant_override("outline_size", 5)
	add_child(message)
	var lifetime := Timer.new()
	lifetime.one_shot = true
	lifetime.process_callback = Timer.TIMER_PROCESS_PHYSICS
	message.add_child(lifetime)
	lifetime.timeout.connect(message.queue_free)
	lifetime.start(message_duration)


func reset() -> void:
	announced_slots.clear()
	for message in get_children():
		remove_child(message)
		message.queue_free()
