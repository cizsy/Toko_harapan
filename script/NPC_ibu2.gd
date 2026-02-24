extends KinematicBody2D

export var speed = 100
export var distance = 200   # jarak jalan ke kanan

var start_pos
var direction = 1
var done = false
var velocity = Vector2()

func _ready():
	start_pos = position

func _physics_process(delta):
	if done:
		velocity = Vector2.ZERO
		move_and_slide(velocity)
		return

	velocity.x = speed * direction
	move_and_slide(velocity)

	# Kalau sudah sampai jarak tujuan
	if direction == 1 and position.x >= start_pos.x + distance:
		direction = -1
	
	# Kalau sudah kembali ke titik awal → berhenti
	elif direction == -1 and position.x <= start_pos.x:
		done = true
