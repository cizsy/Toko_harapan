extends Area2D

export(String) var dialog_teks = "Tempat ini berdebu..."

var player_in_area = false
var sudah_dicek = false

onready var collision = get_node_or_null("CollisionShape2D")


func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")
	update_active_state()


func _process(_delta):
	update_active_state()

	if not boleh_aktif():
		return

	if player_in_area and Input.is_action_just_pressed("interact"):
		cek_object()


func boleh_aktif():
	return GameManager.current_day == 1 and GameManager.story_step == "hari_1_periksa" and not sudah_dicek


func update_active_state():
	var aktif = boleh_aktif()

	visible = aktif

	if collision:
		collision.set_deferred("disabled", not aktif)

	for child in get_children():
		if "Tandaseru" in child.name:
			child.visible = aktif


func cek_object():
	if sudah_dicek:
		get_tree().call_group("UI", "tampilkan_info", "Objek ini sudah kamu periksa.", Color.gray)
		return

	sudah_dicek = true
	
	for child in get_children():
		if "Tandaseru" in child.name:
			child.visible = false

	GameManager.jumlah_objek_dicek += 1

	var info_lengkap = dialog_teks + "\n\n(Objek diperiksa: " + str(GameManager.jumlah_objek_dicek) + "/" + str(GameManager.total_objek_wajib) + ")"
	get_tree().call_group("UI", "tampilkan_info", info_lengkap, Color.black)

	if GameManager.jumlah_objek_dicek >= GameManager.total_objek_wajib:
		GameManager.set_story_step("hari_1_pulang")
		
		yield(get_tree().create_timer(1.5), "timeout")
		get_tree().call_group("UI", "tampilkan_info", "Misi selesai. Semua sudut sudah dicek. Pulang ke rumah.", Color.gold)

	update_active_state()


func _on_body_entered(body):
	if body.is_in_group("Player") or body.name == "Player" or body.name == "player":
		player_in_area = true
		
		if boleh_aktif():
			get_tree().call_group("UI", "tampilkan_info", "Tekan E untuk melihat.", Color.black)


func _on_body_exited(body):
	if body.is_in_group("Player") or body.name == "Player" or body.name == "player":
		player_in_area = false
