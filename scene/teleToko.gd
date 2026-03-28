extends Node2D

var hud = preload("res://scene/main_UI.tscn")

func _ready():
	var canvas_layer = CanvasLayer.new() # Buat layer khusus UI
	add_child(canvas_layer)
	
	var hud_instance = hud.instance()
	canvas_layer.add_child(hud_instance)
