extends Control

func _ready():
	$VBoxContainer/Start.connect("pressed", self, "_on_Start_pressed")
	$VBoxContainer/Settings.connect("pressed", self, "_on_Settings_pressed")
	$VBoxContainer/Exit.connect("pressed", self, "_on_Exit_pressed")

func _on_Start_pressed():
	get_tree().change_scene("res://scene/toko.tscn")

func _on_Settings_pressed():
	get_tree().change_scene("res://scene/settings.tscn")

func _on_Exit_pressed():
	get_tree().quit()
