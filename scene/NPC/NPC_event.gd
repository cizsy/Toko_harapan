extends KinematicBody2D

var kecepatan = 100
var titik_kasir = Vector2(451, 405)
var titik_pintu = Vector2(439, 577)
var target_tujuan = titik_kasir
var sudah_sampai = false
var sedang_pulang = false

var dialog_sudah_mulai = false
var event_sudah_dilapor = false

var event_item = "telur"

var event_icons = {
	"telur": "🥚",
	"gas": "⛽",
	"sabun": "🧼",
	"galon": "🪣"
}

func _ready():
	_update_request_label()
	# Putar animasi walk_up saat pertama kali muncul menuju kasir
	_update_animation(Vector2.UP)


func _physics_process(_delta):
	if not sudah_sampai:
		var arah = (target_tujuan - global_position).normalized()
		move_and_slide(arah * kecepatan)
		
		# Perbarui animasi berdasarkan arah pergerakan vektor
		_update_animation(arah)
		
		if global_position.distance_to(target_tujuan) < 10:
			sudah_sampai = true
			
			# Berhenti animasi jalan saat sudah sampai di kasir
			if not sedang_pulang:
				_stop_animation()
			
			if sedang_pulang:
				lapor_event_selesai()
				queue_free() # Menghapus NPC dari game
			else:
				get_tree().call_group("UI", "tampilkan_info", "Pelanggan menunggu dilayani.", Color.orange)


func _update_request_label():
	if has_node("RequestLabel"):
		var label = $RequestLabel
		
		if event_icons.has(event_item):
			label.text = event_icons[event_item]
		else:
			label.text = "?"


func get_requested_item():
	return event_item


func interact_event():
	if dialog_sudah_mulai:
		return

	if not sudah_sampai:
		get_tree().call_group("UI", "tampilkan_info", "Tunggu pelanggan sampai kasir dulu.", Color.orange)
		return

	mulai_event()


func mulai_event():
	if dialog_sudah_mulai:
		return

	dialog_sudah_mulai = true
	GameManager.player_bisa_gerak = false

	get_tree().call_group("UI", "tampilkan_info", "Pelanggan: Telur ada, Mas?", Color.black)
	yield(get_tree().create_timer(2.0), "timeout")

	# PERBAIKAN: String digabung agar tidak merusak jalannya fungsi
	get_tree().call_group("UI", "tampilkan_info", "Raka: Belum ada, Bu. Maaf.", Color.black)
	yield(get_tree().create_timer(2.0), "timeout")

	get_tree().call_group("UI", "tampilkan_info", "Pelanggan: Oh... ya sudah, saya ke toko sebelah dulu.", Color.black)
	yield(get_tree().create_timer(2.0), "timeout")

	get_tree().call_group("UI", "tampilkan_info", "Raka: Toko ini butuh barang yang lebih lengkap.", Color.darkblue)
	yield(get_tree().create_timer(2.0), "timeout")

	GameManager.player_bisa_gerak = true
	pulang()


func pulang():
	target_tujuan = titik_pintu
	sudah_sampai = false
	sedang_pulang = true
	
	# Mainkan animasi walk_down karena arahnya ke bawah (pintu)
	_update_animation(Vector2.DOWN)
	
	print("NPC Event: saya pulang dulu.")


func lapor_event_selesai():
	if event_sudah_dilapor:
		return

	event_sudah_dilapor = true
	get_tree().call_group("LevelToko", "selesai_event_hari3")


# --- FUNGSI TAMBAHAN UNTUK ANIMASI ---

func _update_animation(arah: Vector2):
	if has_node("AnimatedSprite"):
		var anim = $AnimatedSprite
		# Jika bergerak ke atas (nilai Y negatif)
		if arah.y < 0:
			anim.play("walk_up")
		# Jika bergerak ke bawah (nilai Y positif)
		elif arah.y > 0:
			anim.play("walk_down")


func _stop_animation():
	if has_node("AnimatedSprite"):
		$AnimatedSprite.stop()
		$AnimatedSprite.frame = 0 # Mengembalikan ke pose berdiri diam
