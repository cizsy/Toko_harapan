extends Area2D

var player_di_area = false
onready var tombolInteract = $Interact
onready var signBuka = $SignBuka
onready var signTutup = $SignTutup


func _ready():
	tombolInteract.visible = false
	_update_sign()


func _process(_delta):
	tombolInteract.visible = player_di_area

	if player_di_area and Input.is_action_just_pressed("interact"):
		# KUNCI HARI 1: Dilarang buka toko di hari pertama tutorial
		if GameManager.current_day == 1:
			get_tree().call_group("UI", "tampilkan_info", "Hari pertama fokus periksa toko dulu.", Color.red)
			return

		if not GameManager.toko_buka:
			# CEK EXPLOIT: Pastikan toko belum pernah dibuka hari ini
			if GameManager.toko_sudah_dibuka_hari_ini:
				get_tree().call_group("UI", "tampilkan_info", "Toko sudah tutup untuk hari ini. Silakan pulang.", Color.orange)
				return

			if GameManager.jam >= 15:
				eksekusi_buka_toko()
			else:
				get_tree().call_group("UI", "tampilkan_info", "Belum jam 15:00!", Color.orange)
		else:
			eksekusi_tutup_toko()


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player") or body.name == "Player" or body.name == "player":
		player_di_area = true
		
		# Teks petunjuk yang adaptif sesuai kondisi toko saat player mendekat
		var pesan = "Tekan E untuk Tutup Toko" if GameManager.toko_buka else "Tekan E untuk Buka Toko"
		if GameManager.current_day == 1:
			pesan = "Papan Toko (Tutup)"
			
		get_tree().call_group("UI", "tampilkan_info", pesan, Color.black)


func _on_Area2D_body_exited(body):
	if body.is_in_group("Player") or body.name == "Player" or body.name == "player":
		player_di_area = false


func eksekusi_buka_toko():
	if GameManager.toko_buka:
		return

	# ==========================
	# KUNCI HARI 1
	# ==========================
	if GameManager.current_day == 1:
		get_tree().call_group("UI", "tampilkan_info", "Hari pertama fokus periksa toko dulu.", Color.red)
		return

	# ==========================
	# KUNCI HARI 2
	# ==========================
	if GameManager.current_day == 2 and GameManager.story_step != "hari_2_buka_toko":
		get_tree().call_group("UI", "tampilkan_info", "Bersihkan toko dulu sebelum buka.", Color.orange)
		return

	# ==========================
	# KUNCI HARI 4
	# Day 4 event sudah jalan saat masuk toko,
	# jadi buka toko hanya boleh setelah dialog Pak Beni selesai.
	# ==========================
	if GameManager.current_day == 4 and GameManager.story_step != "hari_4_buka_toko":
		get_tree().call_group("UI", "tampilkan_info", "Bicara dengan Pak Beni dulu.", Color.orange)
		return

	# ==========================
	# BUKA TOKO
	# ==========================
	GameManager.toko_buka = true
	GameManager.toko_sudah_dibuka_hari_ini = true

	_update_sign()

	get_tree().call_group("UI", "tampilkan_info", "Toko Dibuka!", Color.green)

	# ==========================
	# HARI 2
	# ==========================
	if GameManager.current_day == 2 and GameManager.story_step == "hari_2_buka_toko":
		GameManager.set_story_step("hari_2_jualan")
		get_tree().call_group("UI", "tampilkan_info", "Tunggu pelanggan sampai kasir.", Color.black)
		get_tree().call_group("LevelToko", "spawn_npc")
		GameManager.emit_signal("data_update")
		return

	# ==========================
	# HARI 4
	# Event modal sudah selesai sebelum buka toko,
	# jadi setelah buka langsung jualan normal.
	# ==========================
	if GameManager.current_day == 4 and GameManager.story_step == "hari_4_buka_toko":
		GameManager.set_story_step("hari_4_jualan")
		get_tree().call_group("UI", "tampilkan_info", "Shift sore dimulai. Layani pelanggan seperti biasa.", Color.black)
		get_tree().call_group("LevelToko", "spawn_npc")
		GameManager.emit_signal("data_update")
		return

	# ==========================
	# HARI 3 / HARI 5 / HARI NORMAL
	# ==========================
	var event = GameManager.check_story_event_on_open_store()

	if event == "hari_3":
		print("Trigger event Hari 3: pelanggan kecewa")
		get_tree().call_group("LevelToko", "spawn_npc_event_hari3")

	elif event == "hari_5":
		print("Trigger event Hari 5: iklan pinjol")
		get_tree().call_group("LevelToko", "mulai_event_hari5_pinjol")

	else:
		get_tree().call_group("LevelToko", "spawn_npc")

	GameManager.emit_signal("data_update")

func eksekusi_tutup_toko():
	if not GameManager.day_can_end:
		get_tree().call_group("UI", "tampilkan_info", "Layani semua pelanggan dulu sebelum tutup toko.", Color.red)
		return

	GameManager.toko_buka = false
	_update_sign()

	get_tree().call_group("UI", "tampilkan_info", "Toko Ditutup! Pulang dan tidur untuk lanjut hari.", Color.red)

	GameManager.emit_signal("data_update")

func _update_sign():
	if GameManager.toko_buka:
		signBuka.visible = true
		signTutup.visible = false
	else:
		signBuka.visible = false
		signTutup.visible = true
