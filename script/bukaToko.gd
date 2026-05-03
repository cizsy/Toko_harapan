extends Area2D

var player_di_area = false
onready var tombolInteract = $Interact
onready var signBuka = $SignBuka
onready var signTutup = $SignTutup

func _ready():
	tombolInteract.visible = false
	signBuka.visible = false
	signTutup.visible = true
	
func _process(_delta):
	# 1. LOGIKA TOMBOL MUNCUL
	# Sekarang tombol muncul tiap player di area, gak peduli toko buka atau tutup
	if player_di_area:
		tombolInteract.visible = true
	else:
		tombolInteract.visible = false

	# 2. LOGIKA INTERAKSI (TEKAN E)
	if player_di_area and Input.is_action_just_pressed("interact"):
		if not GameManager.toko_buka:
			# Kondisi mau BUKA
			if GameManager.jam >= 15:
				eksekusi_buka_toko()
			else:
				get_tree().call_group("UI", "tampilkan_info", "Belum jam 15:00!", Color.orange)
		else:
			# Kondisi mau TUTUP
			eksekusi_tutup_toko()

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		player_di_area = true
		# Notifikasinya kita bikin dinamis ya
		var pesan = "Tekan 'E' untuk Tutup Toko" if GameManager.toko_buka else "Tekan 'E' untuk Buka Toko"
		get_tree().call_group("UI", "tampilkan_info", pesan, Color.black)

func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		player_di_area = false

func eksekusi_buka_toko():
	GameManager.toko_buka = true
	signTutup.visible = false
	signBuka.visible = true
	get_tree().call_group("UI", "tampilkan_info", "Toko Dibuka!", Color.green)
	get_tree().call_group("LevelToko", "spawn_npc")

# --- INI FUNGSI BARUNYA ---
func eksekusi_tutup_toko():
	GameManager.toko_buka = false
	signBuka.visible = false
	signTutup.visible = true
	get_tree().call_group("UI", "tampilkan_info", "Toko Ditutup!", Color.red)
	# Jam di GameManager otomatis berhenti karena 'if toko_buka' di sana
