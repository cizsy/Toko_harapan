extends KinematicBody2D

var speed = 100
var velocity = Vector2()

func _physics_process(delta):
	velocity = Vector2()
	
	velocity.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	velocity = velocity.normalized() * speed

