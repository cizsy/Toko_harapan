extends Node2D


func _ready():
	var dialog = Dialogic.start("scene1")
	add_child(dialog)
	
