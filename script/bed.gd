extends Area2D

var player_in_range = false


func _ready():
	connect("body_entered", self, "_on_Bed_body_entered")
	connect("body_exited", self, "_on_Bed_body_exited")


func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		tidur()


func _on_Bed_body_entered(body):
	if body.is_in_group("Player") or body.name == "Player" or body.name == "player":
		player_in_range = true
		get_tree().call_group("UI", "tampilkan_info", "Tekan E untuk tidur", Color.white)


func _on_Bed_body_exited(body):
	if body.is_in_group("Player") or body.name == "Player" or body.name == "player":
		player_in_range = false


func tidur():
	if GameManager.current_day == 1:
		if GameManager.story_step == "hari_1_tidur":
			GameManager.day_can_end = true

			var success = GameManager.end_day()
			if success:
				jalankan_transisi_hari("Hari Ke-2", "res://scene/rumah.tscn", "hari_2_sore_di_rumah", Vector2(869, 366))
		else:
			get_tree().call_group("UI", "tampilkan_info", "Bicara dengan Laras dulu sebelum tidur.", Color.red)

		return

	if not GameManager.toko_sudah_dibuka_hari_ini:
		get_tree().call_group("UI", "tampilkan_info", "Buka toko dulu sebelum tidur.", Color.red)
		return
		
	if GameManager.toko_buka:
		get_tree().call_group("UI", "tampilkan_info", "Tutup toko dulu sebelum tidur.", Color.red)
		return

	if not GameManager.day_can_end:
		get_tree().call_group("UI", "tampilkan_info", "Masih ada pelanggan hari ini.", Color.red)
		return

	var success = GameManager.end_day()
	if success:
		jalankan_transisi_hari("Hari Ke-" + str(GameManager.current_day), "res://scene/toko.tscn", "normal_gameplay")

func jalankan_transisi_hari(teks_transisi, scene_tujuan, next_story_step, posisi_player = null):
	GameManager.player_bisa_gerak = false

	var ui_list = get_tree().get_nodes_in_group("UI")
	var ui_transisi = null

	for ui in ui_list:
		print("Node di group UI: ", ui.name)

		if ui.has_method("tampilkan_transisi_hari"):
			ui_transisi = ui
			break

	if ui_transisi != null:
		yield(ui_transisi.tampilkan_transisi_hari(teks_transisi), "completed")
	else:
		print("ERROR: Tidak ada UI yang punya method tampilkan_transisi_hari")
		yield(get_tree().create_timer(1.5), "timeout")

	GameManager.set_story_step(next_story_step)

	if posisi_player != null:
		GameManager.set_next_player_position(posisi_player)

	GameManager.player_bisa_gerak = true
	get_tree().change_scene(scene_tujuan)
