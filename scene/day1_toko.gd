extends Node2D

var pak_beni_scene = preload("res://npcPrio/pakBeni.tscn")
var pak_beni_instance = null


func _ready():
	add_to_group("Day1Toko")

	GameManager.current_day = 1

	if GameManager.story_step == "":
		GameManager.story_step = "hari_1_intro"

	GameManager.player_bisa_gerak = true
	GameManager.emit_signal("data_update")

	if GameManager.story_step == "hari_1_intro":
		spawn_pak_beni()


func spawn_pak_beni():
	if is_instance_valid(pak_beni_instance):
		return

	pak_beni_instance = pak_beni_scene.instance()
	pak_beni_instance.global_position = Vector2(451, 473)
	add_child(pak_beni_instance)
