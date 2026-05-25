extends Area2D

export(String) var dialog_teks = "Tempat ini berdebu..."

var player_in_area = false
var sudah_dicek = false 


func _ready():
	var _err1 = connect("body_entered", self, "_on_body_entered")
	var _err2 = connect("body_exited", self, "_on_body_exited")


func _process(_delta):
	if player_in_area and Input.is_action_just_pressed("interact"):
		if GameManager.current_day == 1 and GameManager.story_step == "explore_toko":
			cek_object()


func cek_object():
	if sudah_dicek:
		get_tree().call_group("UI", "tampilkan_info", "Objek ini sudah kamu periksa.", Color.gray)
		return

	sudah_dicek = true
	
	# CARA BARU: Otomatis mencari dan mematikan semua node yang ada kata "Tandaseru" di dalamnya
	for child in get_children():
		if "Tandaseru" in child.name:
			child.visible = false

	# Gabungkan teks cerita dari Inspector + info progres objek
	var total_baru = GameManager.jumlah_objek_dicek + 1
	var info_lengkap = dialog_teks + "\n\n(Objek diperiksa: " + str(total_baru) + "/" + str(GameManager.total_objek_wajib) + ")"
	
	get_tree().call_group("UI", "tampilkan_info", info_lengkap, Color.black)

	GameManager.jumlah_objek_dicek += 1
	if GameManager.jumlah_objek_dicek >= GameManager.total_objek_wajib:
		GameManager.set_story_step("hari_1_pulang")
		yield(get_tree().create_timer(1.5), "timeout")
		get_tree().call_group("UI", "tampilkan_info", "Misi selesai. Semua sudut sudah dicek. Pulang ke rumah.", Color.gold)

func _on_body_entered(body):
	if body.is_in_group("Player") or body.name == "Player" or body.name == "player":
		player_in_area = true
		if not sudah_dicek:
			get_tree().call_group("UI", "tampilkan_info", "Tekan E untuk melihat.", Color.black)


func _on_body_exited(body):
	if body.is_in_group("Player") or body.name == "Player" or body.name == "player":
		player_in_area = false
