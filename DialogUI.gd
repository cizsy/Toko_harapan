extends CanvasLayer

signal dialog_selesai

onready var panel_dialog = $DialogBox
onready var label_nama = $DialogBox/NamaLabel
onready var label_teks = $DialogBox/TeksLabel
onready var portrait_kiri = $DialogBox/PortraitKiri
onready var portrait_kanan = $DialogBox/PortraitKanan
onready var tween = $Tween

var data_dialog = []
var indeks_sekarang = 0
var sedang_mengetik = false

func _ready():
	add_to_group("DialogSystem")
	panel_dialog.visible = false

func mulai_dialog(list_percakapan: Array):
	data_dialog = list_percakapan
	indeks_sekarang = 0
	GameManager.player_bisa_gerak = false
	panel_dialog.visible = true
	tampilkan_baris_dialog()

func tampilkan_baris_dialog():
	if indeks_sekarang >= data_dialog.size():
		selesai_dialog()
		return
		
	var data = data_dialog[indeks_sekarang]
	
	label_nama.text = data.get("nama", "")
	label_teks.text = data.get("teks", "")
	
	# Sembunyikan kedua portrait terlebih dahulu sebelum menentukan posisi
	portrait_kiri.visible = false
	portrait_kanan.visible = false
	
	var jalur_foto = data.get("portrait", "")
	var posisi = data.get("posisi", "kiri") # Default ke kiri jika tidak diisi
	
	if jalur_foto != "":
		if posisi == "kiri":
			portrait_kiri.texture = load(jalur_foto)
			portrait_kiri.visible = true
		elif posisi == "kanan":
			portrait_kanan.texture = load(jalur_foto)
			portrait_kanan.visible = true
			
	# Animasi Teks Mengetik
	label_teks.percent_visible = 0.0
	var durasi_ketik = label_teks.text.length() * 0.03
	
	tween.interpolate_property(
		label_teks, "percent_visible",
		0.0, 1.0, durasi_ketik,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	tween.start()
	sedang_mengetik = true

func _input(event):
	if not panel_dialog.visible:
		return
		
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		if sedang_mengetik:
			tween.stop_all()
			label_teks.percent_visible = 1.0
			sedang_mengetik = false
		else:
			indeks_sekarang += 1
			tampilkan_baris_dialog()

func selesai_dialog():
	panel_dialog.visible = false
	GameManager.player_bisa_gerak = true
	emit_signal("dialog_selesai")

func _on_Tween_tween_all_completed():
	sedang_mengetik = false
