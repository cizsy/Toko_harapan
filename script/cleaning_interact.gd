extends Area2D

export(NodePath) var target_kotor_path
export(String) var teks_selesai = "Bagian ini sudah dibersihkan."

var player_in_area = false
var sedang_membersihkan = false
var sudah_dibersihkan = false

onready var progress_bar = get_node_or_null("ProgressBar")
onready var interact_icon = get_node_or_null("Tandaseru")
onready var collision = get_node_or_null("CollisionShape2D")


func _ready():
	if not is_connected("body_entered", self, "_on_body_entered"):
		connect("body_entered", self, "_on_body_entered")

	if not is_connected("body_exited", self, "_on_body_exited"):
		connect("body_exited", self, "_on_body_exited")

	if progress_bar:
		progress_bar.visible = false
		progress_bar.value = 0

	update_visibility()


func _process(delta):
	update_visibility()

	if not boleh_muncul():
		return

	if sedang_membersihkan:
		if progress_bar:
			progress_bar.value += 50 * delta

			if progress_bar.value >= progress_bar.max_value:
				selesai_membersihkan()
				return

	if player_in_area and Input.is_action_just_pressed("interact"):
		mulai_membersihkan()


func boleh_muncul():
	return GameManager.current_day == 2 and GameManager.story_step == "hari_2_bersih_toko" and not sudah_dibersihkan


func update_visibility():
	var aktif = boleh_muncul()

	visible = aktif

	if collision:
		collision.set_deferred("disabled", not aktif)

	if interact_icon:
		interact_icon.visible = aktif

	if progress_bar:
		progress_bar.visible = sedang_membersihkan and aktif


func mulai_membersihkan():
	if sudah_dibersihkan or sedang_membersihkan:
		return

	sedang_membersihkan = true

	if progress_bar:
		progress_bar.visible = true
		progress_bar.value = 0

	GameManager.player_bisa_gerak = false


func selesai_membersihkan():
	sedang_membersihkan = false
	sudah_dibersihkan = true

	if progress_bar:
		progress_bar.visible = false

	GameManager.player_bisa_gerak = true

	var target_kotor = get_node_or_null(target_kotor_path)
	if target_kotor:
		target_kotor.visible = false
	else:
		print("WARNING: target_kotor_path belum diisi atau node tidak ditemukan.")

	if interact_icon:
		interact_icon.visible = false

	visible = false

	if collision:
		collision.set_deferred("disabled", true)

	get_tree().call_group("UI", "tampilkan_info", teks_selesai, Color.black)

	GameManager.tambah_progres_bersih()


func _on_body_entered(body):
	if body.is_in_group("Player") or body.name == "Player" or body.name == "player":
		player_in_area = true

		if boleh_muncul():
			get_tree().call_group("UI", "tampilkan_info", "Tekan E untuk membersihkan.", Color.black)


func _on_body_exited(body):
	if body.is_in_group("Player") or body.name == "Player" or body.name == "player":
		player_in_area = false
