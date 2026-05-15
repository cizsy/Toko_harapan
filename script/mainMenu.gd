extends Control

func _on_Start_pressed():
	GameManager.prev_scen = ""
	GameManager.player_bisa_gerak = true
	get_tree().change_scene("res://scene/rumah.tscn")


func _on_Settings_pressed():
	if get_tree().current_scene:
		GameManager.prev_scen = get_tree().current_scene.filename
	else:
		GameManager.prev_scen = "res://scene/mainMenu.tscn"
	get_tree().change_scene("res://scene/settings.tscn")


func _on_Exit_pressed():
	get_tree().quit()


func _on_Continue_pressed():
	pass
