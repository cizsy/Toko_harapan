extends KinematicBody2D

export var speed := 150.0
export var acceleration := 1000.0
export var friction := 800.0

var velocity := Vector2.ZERO
var last_facing_dir := Vector2.DOWN
var interactables = []
var current_interactable = null

onready var anim: AnimatedSprite = $AnimatedSprite


func _ready():
	add_to_group("Player")


func _physics_process(delta):
	if not GameManager.player_bisa_gerak:
		velocity = Vector2.ZERO
		_update_animation(Vector2.ZERO)
		return

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


func _process(_delta):
	if not GameManager.player_bisa_gerak:
		return

	if Input.is_action_just_pressed("interact"):
		if current_interactable and current_interactable.has_method("interact"):
			current_interactable.interact()


func _update_animation(input_dir):
	if not is_instance_valid(anim):
		return

	# PERBAIKAN: Atur flip_h berdasarkan arah horizontal terakhir
	if abs(last_facing_dir.x) > abs(last_facing_dir.y) and last_facing_dir.x < 0:
		anim.flip_h = true  # Aktifkan flip jika menghadap kiri
	else:
		anim.flip_h = false # Matikan flip jika menghadap kanan, atas, atau bawah

	var dir_name = _get_dir_name(last_facing_dir)

	if input_dir == Vector2.ZERO:
		_play_anim("idle_" + dir_name)
	else:
		_play_anim("walk_" + dir_name)


func _get_dir_name(dir):
	if abs(dir.x) > abs(dir.y):
		return "right"
	else:
		if dir.y > 0:
			return "down"
		else:
			return "up"


func _play_anim(anim_name):
	if anim.animation != anim_name:
		anim.play(anim_name)
