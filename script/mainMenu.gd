extends Control

func _ready():
	# Opsional: Sembunyikan atau nonaktifkan tombol Continue kalau player belum punya file save
	var save_file = File.new()
	if not save_file.file_exists("user://save_game.save"):
		if has_node("Continue"):
			$Continue.disabled = true # Tombol abu-abu gak bisa diklik jika belum ada save-an


func _on_Start_pressed():
	# NEW GAME: Reset data GameManager ke setelan awal pabrik biar gak bawa data lama
	GameManager.current_day = 1
	GameManager.current_month = 1
	GameManager.money = 5000000
	GameManager.hutang_utama = 20000000
	GameManager.story_step = "hari_1_intro"
	GameManager.jumlah_objek_dicek = 0
	GameManager.prev_scen = ""
	GameManager.player_bisa_gerak = true
	
	# Lempar player langsung ke scene toko Day 1 (Eksplorasi/Tutorial)
	get_tree().change_scene("res://scene/day1_toko.tscn")


func _on_Continue_pressed():
	# Jalankan fungsi load_game dari GameManager
	var berhasil_load = GameManager.load_game()
	if not berhasil_load:
		# Jika gagal karena filenya corrupt atau hilang, paksa jalankan info di UI
		print("Gagal meload permainan!")


func _on_Settings_pressed():
	if get_tree().current_scene:
		GameManager.prev_scen = get_tree().current_scene.filename
	else:
		GameManager.prev_scen = "res://scene/mainMenu.tscn"
	get_tree().change_scene("res://scene/settings.tscn")


func _on_Exit_pressed():
	get_tree().quit()
