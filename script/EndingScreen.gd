extends Control

onready var teks_label = $Label
onready var tombol_menu = $MenuButton

var narasi_pinjaman = [
	"Beberapa minggu setelah pinjaman itu cair, rak toko akhirnya kembali penuh.",
	"Pelanggan mulai datang lebih sering.",
	"Raka sempat merasa semuanya akan baik-baik saja.",
	"Tapi setiap pemasukan yang masuk, selalu habis untuk menutup tagihan berikutnya.",
	"Angka di layar HP terus bertambah.",
	"Bukan stok yang paling sering Raka hitung sekarang,",
	"melainkan sisa waktu sebelum pembayaran berikutnya.",
	"Toko Sinar Harapan masih berdiri. Lampunya masih menyala.",
	"Tapi untuk pertama kalinya, Raka merasa toko itu tidak lagi terasa seperti harapan."
]

var narasi_tanpa_pinjaman = [
	"Raka tidak jadi mengambil pinjaman itu.",
	"Besoknya, Pak Beni membantu Raka menemui supplier lama.",
	"Tidak semua barang bisa masuk sekaligus.",
	"Tidak semua orang langsung percaya lagi.",
	"Tapi satu per satu, rak yang kosong mulai terisi.",
	"Pelanggan belum sebanyak dulu. Keuntungan juga belum besar.",
	"Namun setiap sore, pintu toko tetap dibuka.",
	"Dan setiap malam, Raka pulang dengan satu hal yang masih ia jaga:",
	"toko ini belum selesai."
]

var baris_aktif = []
var indeks_teks = 0


func _ready():
	tombol_menu.visible = false
	teks_label.text = ""
	GameManager.player_bisa_gerak = false

	if GameManager.story_step == "ending_pinjaman":
		baris_aktif = narasi_pinjaman
	elif GameManager.story_step == "ending_tanpa_pinjaman":
		baris_aktif = narasi_tanpa_pinjaman
	else:
		# Fallback kalau masuk scene ending tanpa step yang jelas
		baris_aktif = narasi_tanpa_pinjaman

	tampilkan_baris_berikutnya()


func _input(event):
	if tombol_menu.visible:
		return

	if event.is_action_just_pressed("ui_accept") or event.is_action_just_pressed("interact") or (event is InputEventMouseButton and event.pressed):
		tampilkan_baris_berikutnya()


func tampilkan_baris_berikutnya():
	if indeks_teks < baris_aktif.size():
		teks_label.text = baris_aktif[indeks_teks]
		indeks_teks += 1
	else:
		teks_label.text = "--- TAMAT ---"
		tombol_menu.visible = true


func _on_MenuButton_pressed():
	reset_game_state()
	get_tree().change_scene("res://scene/mainMenu.tscn")


func reset_game_state():
	GameManager.current_day = 1
	GameManager.current_month = 1
	GameManager.story_step = "hari_1_intro"

	GameManager.money = 2000000
	GameManager.hutang_utama = 20000000
	GameManager.pinjol = 0
	GameManager.reputasi = 0

	GameManager.toko_buka = false
	GameManager.toko_sudah_dibuka_hari_ini = false
	GameManager.day_can_end = false
	GameManager.served_today = 0

	GameManager.event_hari_3_done = false
	GameManager.event_hari_4_done = false
	GameManager.event_hari_5_done = false

	GameManager.jumlah_objek_dicek = 0
	GameManager.jumlah_objek_dibersihkan = 0

	GameManager.jam = 15
	GameManager.menit = 0
	GameManager.timer_detik = 0.0
	GameManager.player_bisa_gerak = true

	GameManager.stock = {
		"mie": 10,
		"minyak": 5,
		"beras": 3
	}

	GameManager.emit_signal("data_update")
