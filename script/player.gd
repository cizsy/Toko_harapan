extends KinematicBody2D

export var speed := 150.0
export var acceleration := 1000.0
export var friction := 800.0 

var velocity := Vector2.ZERO
var last_facing_dir := Vector2.DOWN 

onready var anim: AnimatedSprite = $AnimatedSprite
  # pastikan nama node bener

# ======================
# MOVEMENT
# ======================

func _physics_process(delta):
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_dir = input_dir.normalized()

	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(input_dir * speed, acceleration * delta)
		last_facing_dir = input_dir 
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	velocity = move_and_slide(velocity)
	_update_animation(input_dir)

func _update_animation(input_dir):
	var dir_name = _get_dir_name(last_facing_dir)
	
	if input_dir == Vector2.ZERO and velocity.length() < 10.0:
		_play_anim("idle_" + dir_name)
	else:
		_play_anim("walk_" + dir_name)

func _get_dir_name(dir):
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0 else "left"
	else:
		return "down" if dir.y > 0 else "up"

func _play_anim(anim_name):
	if anim.animation != anim_name:
		anim.play(anim_name)

# ======================
# INTERACTION SYSTEM
# ======================

var interactables = []
var current_interactable = null

func _process(_delta):
	if Input.is_action_just_pressed("interact"):
		if current_interactable:
			current_interactable.interact()


# ======================
# ICON
# ======================
