extends KinematicBody2D

var kecepatan = 100

var titik_keluar = Vector2(439, 577)
var target_tujuan = Vector2.ZERO

var player_in_area = false
var dialog_started = false
var sedang_pulang = false

onready var interact_icon = $Interact
onready var body_collision = $CollisionShape2D


func _ready():
	global_position = Vector2(451, 473)
	target_tujuan = global_position
	interact_icon.visible = false


func _physics_process(_delta):
	if sedang_pulang:
		var arah = (target_tujuan - global_position).normalized()
		move_and_slide(arah * kecepatan)

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

	# Paksa player hadap atas (menghadap Pak Beni yang ada di atas player)
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		var player = players[0]
		if player.has_node("AnimatedSprite"):
			player.get_node("AnimatedSprite").play("idle_up")
		if "last_facing_dir" in player:
			player.last_facing_dir = Vector2.UP

	var percakapan = [
		{
			"nama": "Pak Beni",
			"teks": "Hati-hati, Ka. Lantainya agak licin.",
			"portrait": "res://Asset/character/PortraitsFinal/pakbeni.png",
			"posisi": "kanan"
		},
		{
			"nama": "Raka",
			"teks": "Iya, Pak.",
			"portrait": "res://Asset/character/PortraitsFinal/raka.png",
			"posisi": "kiri"
		},
		{
			"nama": "Raka",
			"teks": "Debunya tebal banget ya.",
			"portrait": "res://Asset/character/PortraitsFinal/raka.png",
			"posisi": "kiri"
		},
		{
			"nama": "Pak Beni",
			"teks": "Sudah lama toko ini nggak dibuka penuh.",
			"portrait": "res://Asset/character/PortraitsFinal/pakbeni.png",
			"posisi": "kanan"
		},
		{
			"nama": "Raka",
			"teks": "Dulu waktu Ayah masih ada... nggak sesepi ini kan?",
			"portrait": "res://Asset/character/PortraitsFinal/raka.png",
			"posisi": "kiri"
		},
		{
			"nama": "Pak Beni",
			"teks": "Nggak. Dulu jam segini biasanya masih ada orang beli.",
			"portrait": "res://Asset/character/PortraitsFinal/pakbeni.png",
			"posisi": "kanan"
		},
		{
			"nama": "Raka",
			"teks": "Sekarang raknya kosong semua.",
			"portrait": "res://Asset/character/PortraitsFinal/raka.png",
			"posisi": "kiri"
		},
		{
			"nama": "Pak Beni",
			"teks": "Barang yang sisa ada di kardus pojok. Nggak banyak.",
			"portrait": "res://Asset/character/PortraitsFinal/pakbeni.png",
			"posisi": "kanan"
		},
		{
			"nama": "Raka",
			"teks": "Berarti mulai dari sisa itu dulu?",
			"portrait": "res://Asset/character/PortraitsFinal/raka.png",
			"posisi": "kiri"
		},
		{
			"nama": "Pak Beni",
			"teks": "Iya. Pelan-pelan.",
			"portrait": "res://Asset/character/PortraitsFinal/pakbeni.png",
			"posisi": "kanan"
		},
		{
			"nama": "Raka",
			"teks": "Pak Beni masih mau bantu?",
			"portrait": "res://Asset/character/PortraitsFinal/raka.png",
			"posisi": "kiri"
		},
		{
			"nama": "Pak Beni",
			"teks": "Bapak biasa sif pagi dari dulu. Besok juga begitu.",
			"portrait": "res://Asset/character/PortraitsFinal/pakbeni.png",
			"posisi": "kanan"
		},
		{
			"nama": "Raka",
			"teks": "Tapi saya sekolah, Pak.",
			"portrait": "res://Asset/character/PortraitsFinal/raka.png",
			"posisi": "kiri"
		},
		{
			"nama": "Pak Beni",
			"teks": "Makanya kamu sekolah dulu. Pulang sekolah baru ke sini.",
			"portrait": "res://Asset/character/PortraitsFinal/pakbeni.png",
			"posisi": "kanan"
		},
		{
			"nama": "Raka",
			"teks": "Maaf ya, Pak. Jadi ngerepotin.",
			"portrait": "res://Asset/character/PortraitsFinal/raka.png",
			"posisi": "kiri"
		},
		{
			"nama": "Pak Beni",
			"teks": "Kalau Bapak merasa repot, Bapak nggak akan datang hari ini.",
			"portrait": "res://Asset/character/PortraitsFinal/pakbeni.png",
			"posisi": "kanan"
		},
		{
			"nama": "Raka",
			"teks": "...Makasih, Pak.",
			"portrait": "res://Asset/character/PortraitsFinal/raka.png",
			"posisi": "kiri"
		},
		{
			"nama": "Pak Beni",
			"teks": "Kuncinya kamu pegang. Agak macet, jadi pas diputer angkat sedikit.",
			"portrait": "res://Asset/character/PortraitsFinal/pakbeni.png",
			"posisi": "kanan"
		},
		{
			"nama": "Raka",
			"teks": "Iya.",
			"portrait": "res://Asset/character/PortraitsFinal/raka.png",
			"posisi": "kiri"
		},
		{
			"nama": "Pak Beni",
			"teks": "Bapak pulang dulu. Coba kamu lihat-lihat kondisi toko ini.",
			"portrait": "res://Asset/character/PortraitsFinal/pakbeni.png",
			"posisi": "kanan"
		}
	]

	var dialog_list = get_tree().get_nodes_in_group("DialogSystem")

	if dialog_list.size() == 0:
		print("ERROR: DialogSystem tidak ditemukan di scene.")
		get_tree().call_group("UI", "tampilkan_info", "DialogSystem belum ada di scene.", Color.red)
		return

	var dialog_ui = dialog_list[0]
	dialog_ui.mulai_dialog(percakapan)

	yield(dialog_ui, "dialog_selesai")
	selesai_dialog_hari_1()


func selesai_dialog_hari_1():
	GameManager.set_story_step("hari_1_periksa")
	# HAPUS keluar_mode_dialog di sini — DialogUI sudah panggil sendiri!
	pulang()


func pulang():
	player_in_area = false
	interact_icon.visible = false

	if is_instance_valid(body_collision):
		body_collision.set_deferred("disabled", true)

	collision_layer = 0
	collision_mask = 0

	target_tujuan = titik_keluar
	sedang_pulang = true


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
