extends Node2D

@onready var animation: AnimatedSprite2D = $Animation


func _ready() -> void:
	animation.animation_finished.connect(queue_free)
	animation.play(&"default")
