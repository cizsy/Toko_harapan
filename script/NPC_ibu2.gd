extends KinematicBody2D

var speed = 50
var target_position = Vector2()
var state = "walk"

var player_in_range = false
var requested_item = "mie" # nanti bisa random

func _ready():
	target_position = Vector2(300, 200) # posisi kasir (ubah sesuai map kamu)

func _physics_process(_delta):
	if state == "walk":
		move_to_target()
	elif state == "leave":
		move_to_exit()

func move_to_target():
	var dir = (target_position - global_position).normalized()
	move_and_slide(dir * speed)

	if global_position.distance_to(target_position) < 5:
		state = "wait"

func move_to_exit():
	var exit_pos = Vector2(-100, 200) # keluar kiri (ubah sesuai map)
	var dir = (exit_pos - global_position).normalized()
	move_and_slide(dir * speed)

	if global_position.distance_to(exit_pos) < 10:
		queue_free()

func _process(_delta):
	if state == "wait" and player_in_range:
		if Input.is_action_just_pressed("ui_accept"):
			sell_item()

func sell_item():
	if GameManager.stock.has(requested_item) and GameManager.stock[requested_item] > 0:
		GameManager.stock[requested_item] -= 1
		GameManager.money += 3000

		print("Jual:", requested_item)

		state = "leave"
	else:
		print("Stok habis!")


func _on_Area2D_body_entered(body):
	if body.name == "player":
		player_in_range = true


func _on_Area2D_body_exited(body):
	if body.name == "Player":
		player_in_range = false
