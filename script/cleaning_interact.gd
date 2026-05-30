extends Area2D

export(NodePath) var target_kotor_path
export(String) var teks_selesai = "Bagian ini sudah dibersihkan."

var player_in_area = false
var sedang_membersihkan = false
var sudah_dibersihkan = false

onready var target_kotor = get_node(target_kotor_path)
onready var progress_bar = $ProgressBar
onready var interact_icon = $Tandaseru


func _ready():
	progress_bar.visible = false
	progress_bar.value = 0

	if interact_icon:
		interact_icon.visible = true

	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")


func _process(delta):
	if sedang_membersihkan:
		progress_bar.value += 50 * delta

		if progress_bar.value >= progress_bar.max_value:
			selesai_membersihkan()
			return

	if player_in_area and Input.is_action_just_pressed("interact"):
		if GameManager.current_day == 2 and GameManager.story_step == "hari_2_bersih_toko":
			mulai_membersihkan()


func mulai_membersihkan():
	if sudah_dibersihkan or sedang_membersihkan:
		return

	sedang_membersihkan = true
	progress_bar.visible = true
	progress_bar.value = 0
	GameManager.player_bisa_gerak = false


func selesai_membersihkan():
	sedang_membersihkan = false
	sudah_dibersihkan = true
	progress_bar.visible = false
	GameManager.player_bisa_gerak = true

	if is_instance_valid(target_kotor):
		target_kotor.visible = false

	if interact_icon:
		interact_icon.visible = false

	get_tree().call_group("UI", "tampilkan_info", teks_selesai, Color.black)
	GameManager.tambah_progres_bersih()


func _on_body_entered(body):
	if body.is_in_group("Player") or body.name == "Player" or body.name == "player":
		player_in_area = true

		if not sudah_dibersihkan and GameManager.current_day == 2 and GameManager.story_step == "hari_2_bersih_toko":
			get_tree().call_group("UI", "tampilkan_info", "Tekan E untuk membersihkan.", Color.black)


func _on_body_exited(body):
	if body.is_in_group("Player") or body.name == "Player" or body.name == "player":
		player_in_area = false
