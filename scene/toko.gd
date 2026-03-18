extends Node2D

var hud = preload("res://scene/main_UI.tscn")

func _ready():
	var hud_instance = hud.instance()
	add_child(hud_instance)


func _on_teleport_body_entered(body):
	pass # Replace with function body.
