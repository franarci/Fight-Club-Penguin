extends Label

signal expired

@onready var timer: Timer = $Timer

var started := false


func _ready() -> void:
	hide()
	timer.timeout.connect(_on_timeout)
	_update_display()


func start() -> void:
	if started:
		return
	started = true
	timer.start()
	_update_display()
	show()


func stop() -> void:
	timer.paused = true
	_update_display()


func _process(_delta: float) -> void:
	if started:
		_update_display()


func _update_display() -> void:
	var seconds := ceili(timer.time_left if started else timer.wait_time)
	text = "%d:%02d" % [seconds / 60, seconds % 60]


func _on_timeout() -> void:
	_update_display()
	expired.emit()
