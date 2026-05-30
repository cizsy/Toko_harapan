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


func spawn_pak_beni():
	if is_instance_valid(pak_beni_instance):
		return

	pak_beni_instance = pak_beni_scene.instance()
	pak_beni_instance.global_position = Vector2(451, 473)
	add_child(pak_beni_instance)

func mode_day2():
	if GameManager.story_step == "hari_2_pergi_ke_toko":
		GameManager.set_story_step("hari_2_bersih_toko")
		GameManager.reset_bersih_toko()

	get_tree().call_group("UI", "tampilkan_info", "Bersihkan toko dulu sebelum buka.", Color.orange)
