extends Control


	
func _on_Start_pressed():
	get_tree().change_scene("res://scene/toko.tscn")

func _on_Settings_pressed():
	get_tree().change_scene("res://scene/settings.tscn")

func _on_Exit_pressed():
	get_tree().quit()
