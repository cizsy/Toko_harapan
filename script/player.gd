extends KinematicBody2D

export var speed := 100
export var target_position := Vector2(300, 200)

var velocity := Vector2.ZERO

func _physics_process(delta):
	var direction = (target_position - global_position)

	if direction.length() > 5:
		direction = direction.normalized()
		velocity = direction * speed
		move_and_slide(velocity)
	else:
		velocity = Vector2.ZERO
		print("NPC sampai kasir")
		set_physics_process(false) # berhenti gerak
