extends Area2D

onready var icon = $Interact

func _ready():
	icon.visible = false
	
func _on_teleport_body_entered(body):
	if body.name == "Player":
		body.can_interact = true
		body.interact_target = self

func _on_teleport_body_exited(body):
	if body.name == "Player":
		body.can_interact = false
		body.interact_target = null
	
func interact():
	get_tree().change_scene("res://scene/rumah.tscn")
	
