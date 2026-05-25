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
	# ==========================================
	# KHUSUS HARI 1: Harus sudah selesai tutorial (story_step == "hari_1_pulang")
	# ==========================================
	if GameManager.current_day == 1:
		if GameManager.story_step == "hari_1_pulang":
			var success = GameManager.end_day()
			if success:
				get_tree().call_group("UI", "tampilkan_info", "Hari pertama selesai. Kamu tidur bersiap untuk besok...", Color.gold)
				# Pindah scene otomatis ke Toko untuk memulai Hari 2 jualan!
				get_tree().change_scene("res://scene/toko.tscn")
		else:
			get_tree().call_group("UI", "tampilkan_info", "Periksa kondisi toko dulu sebelum pulang dan tidur.", Color.red)
		return # Kunci alur agar tidak bocor ke logika hari normal di bawah
	
	# ==========================================
	# LOGIKA GAMEPLAY NORMAL (HARI 2 KE ATAS)
	# ==========================================
	if not GameManager.toko_sudah_dibuka_hari_ini:
		get_tree().call_group("UI", "tampilkan_info", "Buka toko dulu sebelum tidur.", Color.red)
		return
		
	if GameManager.toko_buka:
		get_tree().call_group("UI", "tampilkan_info", "Tutup toko dulu sebelum tidur.", Color.red)
		return

	if not GameManager.day_can_end:
		get_tree().call_group("UI", "tampilkan_info", "Masih ada pelanggan hari ini.", Color.red)
		return

	# Eksekusi ganti hari untuk gameplay normal
	var success = GameManager.end_day()
	if success:
		get_tree().call_group("UI", "tampilkan_info", "Kamu beristirahat. Hari berikutnya dimulai.", Color.gold)
		# FIX BUG: Lempar kembali player ke Toko setelah bangun tidur di hari baru!
		get_tree().change_scene("res://scene/toko.tscn")
