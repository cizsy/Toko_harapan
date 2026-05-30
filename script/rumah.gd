extends Node2D

var laras_scene = preload("res://npcPrio/Laras.tscn")
var laras_instance = null


func _ready():
	if GameManager.current_day == 1 and GameManager.story_step == "hari_1_laras":
		spawn_laras()


func spawn_laras():
	if is_instance_valid(laras_instance):
		return

	laras_instance = laras_scene.instance()
	laras_instance.global_position = Vector2(485, 427) # ganti sesuai posisi Laras di rumahmu
	add_child(laras_instance)
