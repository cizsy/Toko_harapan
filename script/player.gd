extends KinematicBody2D

export var speed := 150.0
export var acceleration := 1000.0
export var friction := 800.0 

var velocity := Vector2.ZERO
var last_facing_dir := Vector2.DOWN 
var interact_target = null

onready var anim: AnimatedSprite = $AnimatedSprite

func _physics_process(delta: float) -> void:
	var input_dir := Vector2.ZERO
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

func _update_animation(input_dir: Vector2) -> void:
	var dir_name = _get_dir_name(last_facing_dir)
	
	if input_dir == Vector2.ZERO and velocity.length() < 10.0:
		_play_anim("idle_" + dir_name)
	else:
		_play_anim("walk_" + dir_name)

func _get_dir_name(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0 else "left"
	else:
		return "down" if dir.y > 0 else "up"

func _play_anim(anim_name: String) -> void:
	if anim.animation != anim_name:
		anim.play(anim_name)
		
		
#interaction

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if is_instance_valid(interact_target):
			if interact_target.has_method("interact"):
				interact_target.interact()
		else:
			interact_target = null

func _on_InteractionArea_body_entered(body):
	if body.has_method("interact"):
		interact_target = body

func _on_InteractionArea_body_exited(body):
	if interact_target == body:
		interact_target = null



