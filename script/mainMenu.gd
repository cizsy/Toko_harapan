extends Control

func _ready():
	var save_file = File.new()
	if not save_file.file_exists("user://save_game.save"):
		if has_node("Continue"):
			$Continue.disabled = true


func _on_Start_pressed():
	GameManager.reset_new_game()
	get_tree().change_scene("res://scene/day1_toko.tscn")


func _on_Continue_pressed():
	var berhasil_load = GameManager.load_game()
	if not berhasil_load:
		print("Gagal meload permainan!")
		if has_node("Continue"):
			$Continue.disabled = true


func _on_Settings_pressed():
	if get_tree().current_scene:
		GameManager.prev_scen = get_tree().current_scene.filename
	else:
		GameManager.prev_scen = "res://scene/mainMenu.tscn"

	get_tree().change_scene("res://scene/settings.tscn")


func _on_Exit_pressed():
	get_tree().quit()
