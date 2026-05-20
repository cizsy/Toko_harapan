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
		if not GameManager.toko_buka:
			if GameManager.jam >= 15:
				eksekusi_buka_toko()
			else:
				get_tree().call_group("UI", "tampilkan_info", "Belum jam 15:00!", Color.orange)
		else:
			eksekusi_tutup_toko()

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player") or body.name == "Player" or body.name == "player":
		player_di_area = true
		var pesan = "Tekan E untuk Tutup Toko" if GameManager.toko_buka else "Tekan E untuk Buka Toko"
		get_tree().call_group("UI", "tampilkan_info", pesan, Color.black)

func _on_Area2D_body_exited(body):
	if body.is_in_group("Player") or body.name == "Player" or body.name == "player":
		player_di_area = false

func eksekusi_buka_toko():
	if GameManager.toko_buka:
		return

	GameManager.toko_buka = true
	GameManager.toko_sudah_dibuka_hari_ini = true

	_update_sign()

	get_tree().call_group("UI", "tampilkan_info", "Toko Dibuka!", Color.green)

	var event = GameManager.check_story_event_on_open_store()

	if event == "hari_3":
		print("Trigger event Hari 3: pelanggan kecewa")
		get_tree().call_group("LevelToko", "spawn_npc_event_hari3")

	elif event == "hari_4":
		print("Trigger event Hari 4: masalah modal")
		get_tree().call_group("UI", "tampilkan_info", "Pak Beni ingin membicarakan soal modal.", Color.orange)
		get_tree().call_group("LevelToko", "spawn_npc")

	elif event == "hari_5":
		print("Trigger event Hari 5: iklan pinjol")
		get_tree().call_group("UI", "tampilkan_info", "HP Raka bergetar. Ada iklan mencurigakan.", Color.orange)
		get_tree().call_group("LevelToko", "spawn_npc")

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
