extends Node2D


func _ready():
	var dialog = Dialogic.start("day1")
	add_child(dialog)
	
