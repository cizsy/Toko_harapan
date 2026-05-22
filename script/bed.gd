extends Area2D

var player_in_range = false

func _ready():
	connect("body_entered", self, "_on_Bed_body_entered")
	connect("body_exited", self, "_on_Bed_body_exited")

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		tidur()

func _on_Bed_body_entered(body):
	if body.is_in_group("Player") or body.name == "Player" or body.name == "player":
		player_in_range = true
		get_tree().call_group("UI", "tampilkan_info", "Tekan E untuk tidur", Color.white)

func _on_Bed_body_exited(body):
	if body.is_in_group("Player") or body.name == "Player" or body.name == "player":
		player_in_range = false

func tidur():
	if not GameManager.toko_sudah_dibuka_hari_ini:
		get_tree().call_group("UI", "tampilkan_info", "Buka toko dulu sebelum tidur.", Color.red)
		return
	
	if GameManager.current_day == 1 and GameManager.story_step == "hari_1_tidur":
		GameManager.day_can_end = true
		GameManager.end_day()
		return
	
	if GameManager.toko_buka:
		get_tree().call_group("UI", "tampilkan_info", "Tutup toko dulu sebelum tidur.", Color.red)
		return

	if not GameManager.day_can_end:
		get_tree().call_group("UI", "tampilkan_info", "Masih ada pelanggan hari ini.", Color.red)
		return

	var success = GameManager.end_day()
	if success:
		get_tree().call_group("UI", "tampilkan_info", "Kamu beristirahat. Hari berikutnya dimulai.", Color.gold)
	
