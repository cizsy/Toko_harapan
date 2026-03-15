extends KinematicBody2D

var velocity = Vector2()
var speed = 80
var target = Vector2()

func _physics_process(delta):
	var dir = (target - global_position).normalized()
	velocity = dir * speed
	move_and_slide(velocity)
