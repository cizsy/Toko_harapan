extends KinematicBody2D

export var speed := 150.0
export var acceleration := 1000.0
export var friction := 500.0

var velocity := Vector2.ZERO
var last_direction := Vector2.DOWN  # arah default waktu idle

onready var anim: AnimatedSprite = $AnimatedSprite

func _physics_process(delta: float) -> void:
	var input_dir := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		# pakai acceleration biar geraknya smooth, bukan langsung speed penuh
		velocity = velocity.move_toward(input_dir * speed, acceleration * delta)
		last_direction = input_dir
	else:
		# pakai friction biar berhentinya smooth, bukan langsung stop
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	velocity = move_and_slide(velocity)
	_update_animation()

func _update_animation() -> void:
	if velocity.length() < 5.0:
		# idle — pakai last_direction biar sprite nghadap arah terakhir
		_play_anim("idle_" + _get_dir_name(last_direction))
		return

	_play_anim("walk_" + _get_dir_name(last_direction))

func _get_dir_name(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0 else "left"
	else:
		return "down" if dir.y > 0 else "up"

func _play_anim(anim_name: String) -> void:
	# cek dulu biar animasi gak restart tiap frame
	if anim.animation != anim_name or not anim.is_playing():
		anim.play(anim_name)
