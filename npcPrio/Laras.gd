extends KinematicBody2D

var player_in_area = false
var dialog_started = false

onready var interact_icon = $Interact


func _ready():
	interact_icon.visible = false


func _process(_delta):
	interact_icon.visible = player_in_area and not dialog_started

	if player_in_area and Input.is_action_just_pressed("interact"):
		if GameManager.current_day == 1 and GameManager.story_step == "hari_1_laras":
			mulai_dialog_laras()


func mulai_dialog_laras():
	if dialog_started:
		return

	dialog_started = true
	interact_icon.visible = false

	var percakapan = [
		{
			"nama": "Laras",
			"teks": "Mas, tadi dari toko?",
			"portrait": "res://Asset/character/PortraitsFinal/Girl2.png",
			"posisi": "kanan"
		},
		{
			"nama": "Raka",
			"teks": "Iya.",
			"portrait": "res://Asset/character/PortraitsFinal/raka.png",
			"posisi": "kiri"
		},
		{
			"nama": "Laras",
			"teks": "Gimana?",
			"portrait": "res://Asset/character/PortraitsFinal/Girl2.png",
			"posisi": "kanan"
		},
		{
			"nama": "Raka",
			"teks": "Kotor. Sepi. Raknya kosong.",
			"portrait": "res://Asset/character/PortraitsFinal/raka.png",
			"posisi": "kiri"
		},
		{
			"nama": "Laras",
			"teks": "Besok dibuka?",
			"portrait": "res://Asset/character/PortraitsFinal/Girl2.png",
			"posisi": "kanan"
		},
		{
			"nama": "Raka",
			"teks": "Belum. Besok mulai pelan-pelan dulu.",
			"portrait": "res://Asset/character/PortraitsFinal/raka.png",
			"posisi": "kiri"
		},
		{
			"nama": "Laras",
			"teks": "Mas mukanya udah kayak orang tua.",
			"portrait": "res://Asset/character/PortraitsFinal/Girl2.png",
			"posisi": "kanan"
		},
		{
			"nama": "Raka",
			"teks": "Kurang ajar.",
			"portrait": "res://Asset/character/PortraitsFinal/raka.png",
			"posisi": "kiri"
		},
		{
			"nama": "Laras",
			"teks": "Ya udah tidur sana. Besok hari masih panjang mas.",
			"portrait": "res://Asset/character/PortraitsFinal/Girl2.png",
			"posisi": "kanan"
		}
	]

	var dialog_list = get_tree().get_nodes_in_group("DialogSystem")

	if dialog_list.size() == 0:
		print("ERROR: DialogSystem tidak ditemukan di rumah.")
		get_tree().call_group("UI", "tampilkan_info", "DialogSystem belum ada di rumah.", Color.red)
		return

	var dialog_ui = dialog_list[0]
	dialog_ui.mulai_dialog(percakapan)

	yield(dialog_ui, "dialog_selesai")

	GameManager.set_story_step("hari_1_tidur")
	get_tree().call_group("UI", "tampilkan_info", "Kamu bisa tidur sekarang.", Color.gold)


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player") or body.name == "Player" or body.name == "player":
		player_in_area = true

		if GameManager.current_day == 1 and GameManager.story_step == "hari_1_laras":
			get_tree().call_group("UI", "tampilkan_info", "Tekan E untuk bicara dengan Laras", Color.black)


func _on_Area2D_body_exited(body):
	if body.is_in_group("Player") or body.name == "Player" or body.name == "player":
		player_in_area = false
