extends Node2D

var pak_beni_scene = preload("res://npcPrio/pakBeni.tscn")
var pak_beni_instance = null

onready var dialog_ui = $DialogUI


func _ready():
	add_to_group("Day1Toko")
	add_to_group("LevelToko")

	GameManager.player_bisa_gerak = true
	GameManager.emit_signal("data_update")

	if GameManager.current_day == 1:
		mode_day1()
	elif GameManager.current_day == 2:
		mode_day2()


func mode_day1():
	if GameManager.story_step == "hari_1_intro":
		spawn_pak_beni()


func mode_day2():
	if GameManager.story_step == "hari_2_pergi_ke_toko":
		GameManager.set_story_step("hari_2_bersih_toko")
		GameManager.reset_bersih_toko()

	get_tree().call_group("UI", "tampilkan_info", "Bersihkan toko dulu sebelum buka.", Color.orange)


func spawn_pak_beni():
	if is_instance_valid(pak_beni_instance):
		return

	pak_beni_instance = pak_beni_scene.instance()
	pak_beni_instance.global_position = Vector2(451, 473)
	add_child(pak_beni_instance)

func selesai_bersih_toko():
	print("DEBUG: selesai_bersih_toko kepanggil")

	if GameManager.current_day != 2:
		print("DEBUG: bukan day 2")
		return

	if GameManager.story_step != "hari_2_pindah_toko":
		print("DEBUG: step salah: ", GameManager.story_step)
		return

	call_deferred("mulai_dialog_selesai_bersih")

func mulai_dialog_selesai_bersih():
	print("DEBUG: mulai dialog selesai bersih")

	var percakapan = [
		{
			"nama": "Raka",
			"teks": "Oke... toko ini mulai kelihatan lebih layak.",
			"portrait": "res://Asset/character/PortraitsFinal/raka.png",
			"posisi": "kiri"
		},
		{
			"nama": "Raka",
			"teks": "Sekarang tinggal buka toko dan coba layani pelanggan.",
			"portrait": "res://Asset/character/PortraitsFinal/raka.png",
			"posisi": "kiri"
		}
	]

	var dialog_list = get_tree().get_nodes_in_group("DialogSystem")

	if dialog_list.size() == 0:
		print("ERROR: DialogSystem tidak ditemukan di day1_toko.")
		pindah_ke_toko_normal()
		return

	var dialog_ui = dialog_list[0]
	dialog_ui.mulai_dialog(percakapan)

	yield(dialog_ui, "dialog_selesai")

	pindah_ke_toko_normal()
	
func pindah_ke_toko_normal():
	GameManager.player_bisa_gerak = false

	var ui_list = get_tree().get_nodes_in_group("UI")
	var ui_transisi = null

	for ui in ui_list:
		if ui.has_method("tampilkan_transisi_hari"):
			ui_transisi = ui
			break

	if ui_transisi != null:
		yield(ui_transisi.tampilkan_transisi_hari("Toko Siap Dibuka"), "completed")
	else:
		yield(get_tree().create_timer(1.5), "timeout")

	GameManager.set_story_step("hari_2_buka_toko")
	GameManager.player_bisa_gerak = true

	get_tree().change_scene("res://scene/toko.tscn")
