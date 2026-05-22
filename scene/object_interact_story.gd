extends Area2D

export(String) var object_type = ""

var player_in_area = false
var sudah_dicek = false


func _process(_delta):
	if player_in_area and Input.is_action_just_pressed("interact"):
		if GameManager.current_day == 1 and GameManager.story_step == "explore_toko":
			cek_object()


func cek_object():
	if sudah_dicek:
		return

	sudah_dicek = true

	if object_type == "rak":
		GameManager.rak_checked = true
		get_tree().call_group("UI", "tampilkan_info", "Rak ini kosong. Bahkan label harganya sudah pudar.", Color.black)

	elif object_type == "kardus":
		GameManager.kardus_checked = true
		get_tree().call_group("UI", "tampilkan_info", "Barang sisa. Beberapa mungkin masih bisa dijual.", Color.black)

	elif object_type == "kasir":
		GameManager.kasir_checked = true
		get_tree().call_group("UI", "tampilkan_info", "Besok aku harus berdiri di sini.", Color.black)

	GameManager.cek_explore_toko_selesai()


func player_masuk(body):
	if body.is_in_group("Player") or body.name == "Player" or body.name == "player":
		player_in_area = true
		get_tree().call_group("UI", "tampilkan_info", "Tekan E untuk melihat.", Color.black)


func player_keluar(body):
	if body.is_in_group("Player") or body.name == "Player" or body.name == "player":
		player_in_area = false


func _on_RakInteract_body_entered(body):
	player_masuk(body)


func _on_RakInteract_body_exited(body):
	player_keluar(body)


func _on_KardusInteract_body_entered(body):
	player_masuk(body)


func _on_KardusInteract_body_exited(body):
	player_keluar(body)


func _on_KasirInteract_body_entered(body):
	player_masuk(body)


func _on_KasirInteract_body_exited(body):
	player_keluar(body)
