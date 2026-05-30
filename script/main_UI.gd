extends Control

var hp_scene = preload("res://scene/ui_hp.tscn")
var hp_instance = null

onready var label_uang = $moneyPanel/moneyLabel
onready var day_label = $dayPanel/dayLabel
onready var infoLabel = $infoPanel/infoLabel
onready var infoPanel = $infoPanel
onready var hp_button = $HpButton
onready var day_transition = $DayTransition/ColorRect
onready var day_transition_label = $DayTransition/ColorRect/Label
onready var misiPanel = $MisiPanel
onready var misiLabel = $MisiPanel/MisiLabel

func _ready():
	add_to_group("UI")

	infoLabel.text = ""
	infoPanel.visible = false
	hp_button.visible = true
	misiPanel.visible = true

	if is_instance_valid(day_transition):
		day_transition.visible = false
		day_transition.modulate.a = 0

	if not GameManager.is_connected("data_update", self, "update_ui"):
		GameManager.connect("data_update", self, "update_ui")

	update_ui()


func _process(_delta):
	update_ui()


func update_ui():
	day_label.text = "Hari " + str(GameManager.current_day)
	label_uang.text = "💰 Rp " + str(GameManager.money)
	update_misi()


func update_misi():
	# ======================
	# HARI 1 - OPENING (FIXED SINKRON)
	# ======================
	if GameManager.current_day == 1:
		if GameManager.story_step == "hari_1_intro":
			misiLabel.text = "Misi: Bicara dengan Pak Beni"
		elif GameManager.story_step == "hari_1_periksa":
			misiLabel.text = "Misi: Periksa kondisi toko (" + str(GameManager.jumlah_objek_dicek) + "/" + str(GameManager.total_objek_wajib) + ")"
		elif GameManager.story_step == "hari_1_pulang":
			misiLabel.text = "Misi: Pulang ke rumah dan tidur"
		else:
			misiLabel.text = "Misi: Lanjutkan aktivitas"
		return

	# ======================
	# HARI 2 - TUTORIAL USAHA
	# ======================
	if GameManager.current_day == 2:
		if not GameManager.toko_sudah_dibuka_hari_ini:
			misiLabel.text = "Misi: Buka toko"
		elif GameManager.toko_buka and not GameManager.day_can_end:
			misiLabel.text = "Misi: Layani pelanggan " + str(GameManager.served_today) + "/" + str(GameManager.max_customer_per_day)
		elif GameManager.toko_buka and GameManager.day_can_end:
			misiLabel.text = "Misi: Tutup toko"
		elif not GameManager.toko_buka and GameManager.day_can_end:
			misiLabel.text = "Misi: Pulang ke rumah lalu tidur"
		else:
			misiLabel.text = "Misi: Cek HP Supplier untuk membeli stok"
		return

	# ======================
	# HARI 3 - MASALAH STOK
	# ======================
	if GameManager.current_day == 3:
		if not GameManager.toko_sudah_dibuka_hari_ini:
			misiLabel.text = "Misi: Buka toko"
		elif GameManager.toko_buka and not GameManager.day_can_end:
			misiLabel.text = "Misi: Layani pelanggan dan perhatikan stok toko"
		elif GameManager.toko_buka and GameManager.day_can_end:
			misiLabel.text = "Misi: Tutup toko"
		elif not GameManager.toko_buka and GameManager.day_can_end:
			misiLabel.text = "Misi: Pulang ke rumah lalu tidur"
		else:
			misiLabel.text = "Misi: Lanjutkan aktivitas"
		return

	# ======================
	# HARI 4 - MASALAH MODAL
	# ======================
	if GameManager.current_day == 4:
		if not GameManager.toko_sudah_dibuka_hari_ini:
			misiLabel.text = "Misi: Buka toko dan cari pemasukan"
		elif GameManager.toko_buka and not GameManager.day_can_end:
			misiLabel.text = "Misi: Layani pelanggan " + str(GameManager.served_today) + "/" + str(GameManager.max_customer_per_day)
		elif GameManager.toko_buka and GameManager.day_can_end:
			misiLabel.text = "Misi: Tutup toko"
		elif not GameManager.toko_buka and GameManager.day_can_end:
			misiLabel.text = "Misi: Pulang dan pikirkan cara menambah modal"
		else:
			misiLabel.text = "Misi: Bicara dengan Pak Beni"
		return

	# ======================
	# HARI 5 - PINJOL / CHOICE
	# ======================
	if GameManager.current_day == 5:
		if not GameManager.toko_sudah_dibuka_hari_ini:
			misiLabel.text = "Misi: Buka toko"
		elif GameManager.toko_buka and not GameManager.day_can_end:
			misiLabel.text = "Misi: Layani pelanggan sampai HP bergetar"
		elif GameManager.toko_buka and GameManager.day_can_end:
			misiLabel.text = "Misi: Cek HP"
		elif not GameManager.toko_buka and GameManager.day_can_end:
			misiLabel.text = "Misi: Tentukan keputusan modal"
		else:
			misiLabel.text = "Misi: Cek HP"
		return

	# ======================
	# DEFAULT / FALLBACK
	# ======================
	if not GameManager.toko_sudah_dibuka_hari_ini:
		misiLabel.text = "Misi: Buka toko"

	elif GameManager.toko_buka and not GameManager.day_can_end:
		misiLabel.text = "Misi: Layani pelanggan " + str(GameManager.served_today) + "/" + str(GameManager.max_customer_per_day)

	elif GameManager.toko_buka and GameManager.day_can_end:
		misiLabel.text = "Misi: Tutup toko"

	elif not GameManager.toko_buka and GameManager.day_can_end:
		misiLabel.text = "Misi: Pulang ke rumah lalu tidur"

	else:
		misiLabel.text = "Misi: Lanjutkan aktivitas"

func masuk_mode_dialog():
	# Tutup HP kalau sedang terbuka
	if is_instance_valid(hp_instance):
		hp_instance.queue_free()
		hp_instance = null

	# Sembunyikan semua UI gameplay
	$moneyPanel.visible = false
	$dayPanel.visible = false
	$MisiPanel.visible = false
	$infoPanel.visible = false
	$HpButton.visible = false

	# Kunci player
	GameManager.player_bisa_gerak = false


func keluar_mode_dialog():
	# Tampilkan lagi UI gameplay
	$moneyPanel.visible = true
	$dayPanel.visible = true
	$MisiPanel.visible = true
	$HpButton.visible = true

	# infoPanel tetap false dulu, nanti muncul kalau tampilkan_info dipanggil
	$infoPanel.visible = false

	# Buka gerakan player
	GameManager.player_bisa_gerak = true

	update_ui()

func _on_HpButton_pressed():
	if not is_instance_valid(hp_instance):
		hp_instance = hp_scene.instance()
		add_child(hp_instance)

		if hp_instance.has_signal("hp_ditutup"):
			hp_instance.connect("hp_ditutup", self, "_on_hp_terhapus_manual")
		hp_instance.connect("tree_exited", self, "_on_hp_tree_exited")

		hp_button.visible = false
		GameManager.player_bisa_gerak = false
	else:
		tutup_hp()


func _on_hp_terhapus_manual():
	hp_button.visible = true
	hp_instance = null
	GameManager.player_bisa_gerak = true


func _on_hp_tree_exited():
	hp_button.visible = true
	hp_instance = null
	GameManager.player_bisa_gerak = true


func tutup_hp():
	if is_instance_valid(hp_instance):
		hp_instance.queue_free()

	hp_instance = null
	hp_button.visible = true
	GameManager.player_bisa_gerak = true


func tampilkan_info(pesan, warna = Color.black):
	infoLabel.text = str(pesan)
	infoLabel.modulate = warna
	infoPanel.visible = true

	yield(get_tree().create_timer(2.0), "timeout")

	if infoLabel.text == str(pesan):
		infoLabel.text = ""
		infoPanel.visible = false


func tampilkan_transisi_hari(teks):
	if not is_instance_valid(day_transition):
		print("ERROR: DayTransition ColorRect tidak ditemukan.")
		return

	if not is_instance_valid(day_transition_label):
		print("ERROR: DayTransition Label tidak ditemukan.")
		return

	print("TRANSISI MULAI: " + str(teks))

	# Pastikan dia muncul di atas
	day_transition.visible = true
	day_transition.show()
	day_transition.raise()
	day_transition.modulate.a = 0.0
	day_transition_label.text = teks

	# Sembunyikan UI gameplay saat transisi
	$moneyPanel.visible = false
	$dayPanel.visible = false
	$MisiPanel.visible = false
	$infoPanel.visible = false
	$HpButton.visible = false

	var tween_baru = Tween.new()
	add_child(tween_baru)

	tween_baru.interpolate_property(
		day_transition,
		"modulate:a",
		0.0,
		1.0,
		0.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	tween_baru.start()
	yield(tween_baru, "tween_completed")

	yield(get_tree().create_timer(1.2), "timeout")

	tween_baru.interpolate_property(
		day_transition,
		"modulate:a",
		1.0,
		0.0,
		0.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	tween_baru.start()
	yield(tween_baru, "tween_completed")

	day_transition.visible = false
	tween_baru.queue_free()

	print("TRANSISI SELESAI")
