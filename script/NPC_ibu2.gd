extends KinematicBody2D

var target_position = Vector2()

func _physics_process(delta):
	var direction = (target_position - global_position).normalized()
	velocity = direction * 50
	move_and_slide(velocity)
