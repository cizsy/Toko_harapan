extends CanvasLayer

signal dialog_selesai
signal pilihan_dipilih(pilihan)

onready var panel_dialog = $DialogBox
onready var label_nama_kiri = $DialogBox/NamaLabelKiri
onready var label_nama_kanan = $DialogBox/NamaLabelKanan
onready var label_teks = $DialogBox/TeksLabel
onready var portrait_kiri = $DialogBox/PortraitKiri
onready var portrait_kanan = $DialogBox/PortraitKanan
onready var tween = $Tween

onready var choice_panel = $ChoicePanel
onready var choice_label = $ChoicePanel/ChoiceLabel
onready var tombol_ambil_pinjaman = $ChoicePanel/ButtonAmbilPinjaman
onready var tombol_tanya_pak_beni = $ChoicePanel/ButtonTanyaPakBeni

var data_dialog = []
var indeks_sekarang = 0
var sedang_mengetik = false
var dialog_aktif = false

# Cache portrait biar tidak load ulang tiap baris
var portrait_cache = {}

# Cooldown biar tidak skip dua baris sekaligus
var input_cooldown = false


func _ready():
	add_to_group("DialogSystem")

	panel_dialog.visible = false
	label_nama_kiri.visible = false
	label_nama_kanan.visible = false
	portrait_kiri.visible = false
	portrait_kanan.visible = false

	if choice_panel:
		choice_panel.visible = false
	else:
		print("ERROR: ChoicePanel tidak ditemukan di DialogUI.")

	if tombol_ambil_pinjaman:
		if not tombol_ambil_pinjaman.is_connected("pressed", self, "_on_ambil_pinjaman_pressed"):
			tombol_ambil_pinjaman.connect("pressed", self, "_on_ambil_pinjaman_pressed")
	else:
		print("ERROR: ButtonAmbilPinjaman tidak ditemukan.")

	if tombol_tanya_pak_beni:
		if not tombol_tanya_pak_beni.is_connected("pressed", self, "_on_tanya_pak_beni_pressed"):
			tombol_tanya_pak_beni.connect("pressed", self, "_on_tanya_pak_beni_pressed")
	else:
		print("ERROR: ButtonTanyaPakBeni tidak ditemukan.")


func mulai_dialog(list_percakapan):
	if list_percakapan.empty():
		print("Dialog kosong.")
		return

	data_dialog = list_percakapan
	indeks_sekarang = 0
	sedang_mengetik = false
	dialog_aktif = true
	input_cooldown = false
	portrait_cache.clear()

	# Pre-load semua portrait sekaligus di awal biar tidak lag tiap baris
	for entry in data_dialog:
		var path = entry.get("portrait", "")
		if path != "" and not portrait_cache.has(path):
			var tex = load(path)
			if tex != null:
				portrait_cache[path] = tex

	GameManager.player_bisa_gerak = false
	get_tree().call_group("UI", "masuk_mode_dialog")

	if choice_panel:
		choice_panel.visible = false

	panel_dialog.visible = true
	tampilkan_baris_dialog()


func tampilkan_baris_dialog():
	if indeks_sekarang >= data_dialog.size():
		selesai_dialog()
		return

	var data = data_dialog[indeks_sekarang]

	var nama = data.get("nama", "")
	var teks = data.get("teks", "")
	var posisi = data.get("posisi", "kiri")
	var jalur_foto = data.get("portrait", "")

	# Reset semua dulu
	label_nama_kiri.visible = false
	label_nama_kanan.visible = false
	portrait_kiri.visible = false
	portrait_kanan.visible = false
	label_nama_kiri.text = ""
	label_nama_kanan.text = ""

	# Nama & portrait
	if posisi == "kiri":
		label_nama_kiri.text = nama
		label_nama_kiri.visible = true
		if jalur_foto != "" and portrait_cache.has(jalur_foto):
			portrait_kiri.texture = portrait_cache[jalur_foto]
			portrait_kiri.visible = true
	elif posisi == "kanan":
		label_nama_kanan.text = nama
		label_nama_kanan.visible = true
		if jalur_foto != "" and portrait_cache.has(jalur_foto):
			portrait_kanan.texture = portrait_cache[jalur_foto]
			portrait_kanan.visible = true

	# Typewriter effect
	label_teks.text = teks
	label_teks.percent_visible = 0.0

	var durasi_ketik = max(teks.length() * 0.03, 0.3)

	tween.stop_all()
	tween.interpolate_property(
		label_teks,
		"percent_visible",
		0.0,
		1.0,
		durasi_ketik,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	tween.start()
	sedang_mengetik = true

	# Cooldown singkat biar input sebelumnya tidak langsung skip baris ini
	input_cooldown = true
	yield(get_tree().create_timer(0.1), "timeout")
	input_cooldown = false


func _input(event):
	if not dialog_aktif:
		return

	if not panel_dialog.visible:
		return

	if input_cooldown:
		return

	# Hanya tangkap satu action, ui_accept ATAU interact — tidak keduanya
	var pressed = false
	if event.is_action_pressed("ui_accept"):
		pressed = true
	elif event.is_action_pressed("interact"):
		pressed = true

	if not pressed:
		return

	# Konsumsi event biar tidak tembus ke node lain
	get_tree().set_input_as_handled()

	if sedang_mengetik:
		# Skip typewriter — langsung tampilkan semua teks
		tween.stop_all()
		label_teks.percent_visible = 1.0
		sedang_mengetik = false
	else:
		# Lanjut ke baris berikutnya
		indeks_sekarang += 1
		tampilkan_baris_dialog()


func selesai_dialog():
	tween.stop_all()

	panel_dialog.visible = false
	label_nama_kiri.visible = false
	label_nama_kanan.visible = false
	portrait_kiri.visible = false
	portrait_kanan.visible = false

	data_dialog = []
	indeks_sekarang = 0
	sedang_mengetik = false
	dialog_aktif = false
	input_cooldown = false
	portrait_cache.clear()

	GameManager.player_bisa_gerak = true
	get_tree().call_group("UI", "keluar_mode_dialog")

	emit_signal("dialog_selesai")


func _on_Tween_tween_all_completed():
	sedang_mengetik = false


func tampilkan_choice_pinjol():
	if choice_panel == null:
		print("ERROR: ChoicePanel belum ada / path salah.")
		return

	if choice_label == null:
		print("ERROR: ChoiceLabel belum ada / path salah.")
		return

	panel_dialog.visible = false
	choice_panel.visible = true
	GameManager.player_bisa_gerak = false
	get_tree().call_group("UI", "masuk_mode_dialog")

	choice_label.text = "Raka mendapat tawaran pinjaman modal cepat.\nApa yang harus dilakukan?"

	if tombol_ambil_pinjaman:
		tombol_ambil_pinjaman.text = "Ambil Pinjaman"

	if tombol_tanya_pak_beni:
		tombol_tanya_pak_beni.text = "Tanya Pak Beni Dulu"


func _on_ambil_pinjaman_pressed():
	if choice_panel:
		choice_panel.visible = false

	get_tree().call_group("UI", "keluar_mode_dialog")
	emit_signal("pilihan_dipilih", "pinjol")


func _on_tanya_pak_beni_pressed():
	if choice_panel:
		choice_panel.visible = false

	get_tree().call_group("UI", "keluar_mode_dialog")
	emit_signal("pilihan_dipilih", "tanpa_pinjol")
