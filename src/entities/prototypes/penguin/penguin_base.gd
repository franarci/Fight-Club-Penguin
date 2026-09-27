extends CharacterBody2D

@onready var SPEED = 0.0
@onready var body: AnimatedSprite2D = $Body
@onready var dash_timer: Timer = $DashTimer
@onready var dash_cooldown_timer: Timer = $DashCooldown

@export_category("Stats")
@export var base_speed: float
@export var dash_speed: float
@export var dash_cooldown: float

@export_category("Animation") 
@export var p_spriteframes: SpriteFrames
@export var p_autoplay: String
#@export var body_texture: CompressedTexture2D
#@export var v_frames: int
#@export var h_frames: int
#@export var par_frame: int
#@export var par_frame_coords: Vector2

var last_direction = "right"
var last_x_direction = "right"
var is_dashing = false
var can_dash = true

func _ready() -> void:
	SPEED = base_speed
	body.sprite_frames = p_spriteframes
	body.autoplay = p_autoplay
	body.play(p_autoplay)
	dash_cooldown_timer.wait_time = dash_cooldown
	#body.texture = body_texture
	#body.hframes = h_frames
	#body.vframes = v_frames
	#body.frame = par_frame
	#body.frame_coords = par_frame_coords
	
	
func _physics_process(_delta: float) -> void:
	movement_loop()
	move_and_slide()
	
func movement_loop():
	
	if not is_dashing:
		#we should have 4 animations for movement: right, left, top, down
		var input_dir = Input.get_vector("p1_left", "p1_right", "p1_up", "p1_down")
		
		if input_dir == Vector2.ZERO:
			velocity = Vector2.ZERO
			update_animation("idle")
			return
		
		if Input.is_action_just_pressed("p1_dash") and can_dash:
			start_dash(input_dir)
			return
		
		if abs(input_dir.x) > abs(input_dir.y):
			last_direction = "right"
			if input_dir.x < 0:
				body.flip_h = true
			else:
				body.flip_h = false
				
		else:
			if input_dir.y > 0:
				last_direction = last_x_direction
			else:
				last_direction = "up"
				
		update_animation("walk")
		velocity = input_dir * SPEED
		

	
func update_animation(state):
	body.play(state + "_" + last_direction)

func start_dash(dir):
	is_dashing = true
	can_dash = false
	velocity = dir * dash_speed
	update_animation("dash")
	dash_timer.start()
	dash_cooldown_timer.start()

func _on_dash_timer_timeout() -> void:
	is_dashing = false
	velocity = Vector2.ZERO


func _on_dash_cooldown_timeout() -> void:
	can_dash = true
