extends Control


func _ready():
	MainUi.hide()
	
func _on_Start_pressed():
	get_tree().change_scene("res://scene/tested.tscn")

func _on_Settings_pressed():
	get_tree().change_scene("res://scene/settings.tscn")

func _on_Exit_pressed():
	get_tree().quit()
