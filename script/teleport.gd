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

		# ==========================
		# HARI 1
		# ==========================
		if GameManager.current_day == 1:
			if GameManager.story_step != "hari_1_pulang":
				get_tree().call_group("UI", "tampilkan_info", "Periksa semua sudut toko dulu sebelum pulang.", Color.red)
				return

			GameManager.set_story_step("hari_1_laras")
			get_tree().change_scene("res://scene/rumah.tscn")
			return

		# ==========================
		# HARI 2 KE ATAS
		# ==========================
		if GameManager.toko_buka:
			get_tree().call_group("UI", "tampilkan_info", "Tutup toko dulu sebelum pulang.", Color.red)
			return

		if not GameManager.toko_sudah_dibuka_hari_ini:
			get_tree().call_group("UI", "tampilkan_info", "Buka toko dulu sebelum pulang.", Color.red)
			return

		if not GameManager.day_can_end:
			get_tree().call_group("UI", "tampilkan_info", "Selesaikan pelanggan hari ini dulu.", Color.red)
			return

		if GameManager.current_day == 2:
			GameManager.set_story_step("hari_2_tidur")

		get_tree().change_scene("res://scene/rumah.tscn")
