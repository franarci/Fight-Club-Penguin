extends CanvasLayer
## Screen-space cards follow slot/spawn order, even when slots are nonconsecutive.

const PlayerCard = preload("res://src/ui/arena/player_lives_card.gd")
const CORNERS := [Vector2(0, 0), Vector2(0, 1), Vector2(1, 0), Vector2(1, 1)]
const MARGIN := 20.0
var cards: Dictionary = {}


func _ready() -> void:
	PlayerManager.lives_changed.connect(_on_lives_changed)


func show_players(active_players: Array[Dictionary]) -> void:
	for card in cards.values():
		remove_child(card)
		card.queue_free()
	cards.clear()
	for player in active_players:
		var slot: int = player["slot"]
		var corner: Vector2 = CORNERS[slot]
		var card := PlayerCard.new()
		card.name = "Player%d" % (slot + 1)
		add_child(card)
		card.configure(player, corner.x > 0)
		card.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		card.anchor_left = corner.x
		card.anchor_right = corner.x
		card.anchor_top = corner.y
		card.anchor_bottom = corner.y
		card.grow_horizontal = Control.GROW_DIRECTION_BEGIN if corner.x > 0 else Control.GROW_DIRECTION_END
		card.grow_vertical = Control.GROW_DIRECTION_BEGIN if corner.y > 0 else Control.GROW_DIRECTION_END
		var card_size: Vector2 = card.get_combined_minimum_size()
		card.offset_left = -MARGIN - card_size.x if corner.x > 0 else MARGIN
		card.offset_right = -MARGIN if corner.x > 0 else MARGIN + card_size.x
		card.offset_top = -MARGIN - card_size.y if corner.y > 0 else MARGIN
		card.offset_bottom = -MARGIN if corner.y > 0 else MARGIN + card_size.y
		cards[slot] = card


func _on_lives_changed(slot: int, lives: int) -> void:
	if cards.has(slot):
		cards[slot].set_lives(lives)
