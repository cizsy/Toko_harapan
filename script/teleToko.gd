extends Area2D

var active = false

onready var interact_icon = get_node_or_null("Interact")


func _ready():
	if not is_connected("body_entered", self, "_on_body_entered"):
		var _err = connect("body_entered", self, "_on_body_entered")

	if not is_connected("body_exited", self, "_on_body_exited"):
		var _err = connect("body_exited", self, "_on_body_exited")

	if interact_icon:
		interact_icon.visible = false


func _on_body_entered(body):
	if body.is_in_group("Player") or body.name == "Player" or body.name == "player":
		active = true


func _on_body_exited(body):
	if body.is_in_group("Player") or body.name == "Player" or body.name == "player":
		active = false


func _process(_delta):
	if interact_icon:
		interact_icon.visible = active

	if active and Input.is_action_just_pressed("interact"):
		# INTEGRASI HARI 1: Kalau sudah di rumah, dilarang balik ke toko, disuruh tidur!
		if GameManager.current_day == 1 and GameManager.story_step == "hari_1_pulang":
			get_tree().call_group("UI", "tampilkan_info", "Sudah malam, sebaiknya kamu langsung tidur di kasur.", Color.orange)
			return # Batalkan pindah scene
			
		# Hari biasa (Hari 2 ke atas) boleh bolak-balik normal
		get_tree().change_scene("res://res://scene/toko.tscn")
