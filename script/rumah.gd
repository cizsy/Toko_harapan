extends Node2D

var laras_scene = preload("res://npcPrio/Laras.tscn")
var laras_instance = null

export(bool) var debug_mode = false
export(int) var debug_day = 1

func _ready():
	if debug_mode:
		GameManager.debug_go_to_day(debug_day)

	call_deferred("atur_posisi_player_awal")

	if GameManager.current_day == 1 and GameManager.story_step == "hari_1_laras":
		spawn_laras()
		return

	if GameManager.current_day == 2 and GameManager.story_step == "hari_2_sore_di_rumah":
		call_deferred("mulai_dialog_hari_2_sore")
		return
	
	if GameManager.current_day >= 3 and GameManager.current_day <= 5:
		if GameManager.story_step == "hari_" + str(GameManager.current_day) + "_sore_di_rumah":
			call_deferred("mulai_dialog_hari_baru_sore")
			return

func spawn_laras():
	if is_instance_valid(laras_instance):
		return

	laras_instance = laras_scene.instance()
	laras_instance.global_position = Vector2(485, 427)
	add_child(laras_instance)


func atur_posisi_player_awal():
	GameManager.apply_next_player_position()


func mulai_dialog_hari_2_sore():
	var percakapan = [
		{
			"nama": "Raka",
			"teks": "Sudah sore.",
			"portrait": "res://Asset/character/PortraitsFinal/raka.png",
			"posisi": "kiri"
		},
		{
			"nama": "Raka",
			"teks": "Aku harus pergi ke toko.",
			"portrait": "res://Asset/character/PortraitsFinal/raka.png",
			"posisi": "kiri"
		}
	]

	var dialog_list = get_tree().get_nodes_in_group("DialogSystem")

	if dialog_list.size() == 0:
		print("ERROR: DialogSystem tidak ditemukan di rumah.")
		get_tree().call_group("UI", "tampilkan_info", "DialogUI belum ada di rumah.", Color.red)
		return

	var dialog_ui = dialog_list[0]
	dialog_ui.mulai_dialog(percakapan)

	yield(dialog_ui, "dialog_selesai")

	GameManager.set_story_step("hari_2_pergi_ke_toko")
	get_tree().call_group("UI", "tampilkan_info", "Pergi ke toko.", Color.gold)

func mulai_dialog_hari_baru_sore():
	var percakapan = [
		{
			"nama": "Raka",
			"teks": "Sudah sore.",
			"portrait": "res://Asset/character/PortraitsFinal/raka.png",
			"posisi": "kiri"
		},
		{
			"nama": "Raka",
			"teks": "Aku harus pergi ke toko.",
			"portrait": "res://Asset/character/PortraitsFinal/raka.png",
			"posisi": "kiri"
		}
	]

	var dialog_list = get_tree().get_nodes_in_group("DialogSystem")

	if dialog_list.size() == 0:
		print("ERROR: DialogSystem tidak ditemukan di rumah.")
		GameManager.set_story_step("hari_" + str(GameManager.current_day) + "_pergi_ke_toko")
		return

	var dialog_ui = dialog_list[0]
	dialog_ui.mulai_dialog(percakapan)

	yield(dialog_ui, "dialog_selesai")

	GameManager.set_story_step("hari_" + str(GameManager.current_day) + "_pergi_ke_toko")
	get_tree().call_group("UI", "tampilkan_info", "Pergi ke toko.", Color.gold)

