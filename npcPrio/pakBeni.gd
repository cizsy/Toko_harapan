extends KinematicBody2D

var kecepatan = 100

var titik_keluar = Vector2(439, 577)
var target_tujuan = Vector2.ZERO

var player_in_area = false
var dialog_started = false
var sedang_pulang = false
var sudah_sampai = true

onready var interact_icon = $Interact


func _ready():
	global_position = Vector2(451, 473)
	target_tujuan = global_position
	interact_icon.visible = false


func _physics_process(_delta):
	if sedang_pulang:
		var arah = (target_tujuan - global_position).normalized()
		move_and_slide(arah * kecepatan)

		# PERBAIKAN FATAL: Pengecekan jarak dimasukkan ke dalam scope 'sedang_pulang'
		if global_position.distance_to(target_tujuan) < 10:
			queue_free()


func _process(_delta):
	interact_icon.visible = player_in_area and not dialog_started and not sedang_pulang

	if player_in_area and Input.is_action_just_pressed("interact"):
		if GameManager.current_day == 1 and GameManager.story_step == "hari_1_intro":
			mulai_dialog_hari_1()

func mulai_dialog_hari_1():
	if dialog_started:
		return

	dialog_started = true
	interact_icon.visible = false
	get_tree().call_group("UI", "masuk_mode_dialog")

	var percakapan = [
		{
			"nama": "Pak Beni",
			"teks": "Raka, akhirnya kamu datang juga. Mulai hari ini kamu yang pegang toko ini ya.",
			"portrait": "res://aset/portrait/pak_beni.png",
			"posisi": "kiri" # Pak Beni muncul di kiri
		},
		{
			"nama": "Raka",
			"teks": "Baik, Pak. Tapi saya harus mulai dari mana dulu?",
			"portrait": "res://aset/portrait/raka.png",
			"posisi": "kanan" # Raka muncul di kanan saat membalas obrolan
		},
		{
			"nama": "Pak Beni",
			"teks": "Tolong periksa 6 objek vital di toko ini sebelum kita mulai jualan besok.",
			"portrait": "res://aset/portrait/pak_beni.png",
			"posisi": "kiri" # Kamera fokus kembali ke Pak Beni di kiri
		}
	]

	var dialog_ui = get_tree().get_nodes_in_group("DialogSystem")[0]
	dialog_ui.mulai_dialog(percakapan)
	
	yield(dialog_ui, "dialog_selesai")
	selesai_dialog_hari_1()


func selesai_dialog_hari_1():
	GameManager.set_story_step("hari_1_periksa") 
	
	get_tree().call_group("UI", "keluar_mode_dialog")
	pulang()


func pulang():
	player_in_area = false
	interact_icon.visible = false
	target_tujuan = titik_keluar
	sedang_pulang = true
	
	print("Pak Beni pulang lewat pintu.")


func _on_Area2D_body_entered(body):
	if sedang_pulang:
		return

	if body.is_in_group("Player") or body.name == "Player" or body.name == "player":
		player_in_area = true

		if GameManager.current_day == 1 and GameManager.story_step == "hari_1_intro":
			get_tree().call_group("UI", "tampilkan_info", "Tekan E untuk bicara dengan Pak Beni", Color.black)


func _on_Area2D_body_exited(body):
	if body.is_in_group("Player") or body.name == "Player" or body.name == "player":
		player_in_area = false
