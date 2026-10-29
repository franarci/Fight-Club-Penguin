extends Resource
class_name CharacterData

@export var key: String
@export var Img: Texture2D

@export_category("Selection profile: prototype")
@export_range(0, 100, 1) var selection_speed: float = 50.0
@export_range(0, 100, 1) var selection_strength: float = 50.0
@export_range(0, 100, 1) var selection_resistance: float = 50.0
