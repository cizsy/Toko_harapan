extends KinematicBody2D

var kecepatan = 100
var titik_kasir = Vector2(451, 405)
var titik_pintu = Vector2(439, 577)

var target_tujuan = titik_kasir
var sudah_sampai = false
var sedang_pulang = false
var dialog_sudah_mulai = false

var event_item = "telur"

var event_icons = {
	"telur": "🥚",
	"gas": "🟩",
	"sabun": "🧼",
	"galon": "💧"
}

func _ready():
	_update_request_label()


func _physics_process(_delta):
	if not sudah_sampai:
		var arah = (target_tujuan - global_position).normalized()
		move_and_slide(arah * kecepatan)

		if global_position.distance_to(target_tujuan) < 10:
			sudah_sampai = true

			if sedang_pulang:
				queue_free()
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
		get_tree().call_group("UI", "tampilkan_info", "Pelanggan belum sampai kasir.", Color.orange)
		return

	mulai_event()


func mulai_event():
	if dialog_sudah_mulai:
		return

	dialog_sudah_mulai = true

	get_tree().call_group("UI", "tampilkan_info", "Pelanggan mencari barang yang belum tersedia.", Color.orange)
	yield(get_tree().create_timer(2.0), "timeout")

	get_tree().call_group("UI", "tampilkan_info", "Pelanggan: Telur ada, Mas?", Color.black)
	yield(get_tree().create_timer(2.0), "timeout")

	get_tree().call_group("UI", "tampilkan_info", "Raka: Belum ada, Bu. Maaf.", Color.black)
	yield(get_tree().create_timer(2.0), "timeout")

	get_tree().call_group("UI", "tampilkan_info", "Pelanggan: Oh... ya sudah, saya ke toko sebelah dulu.", Color.black)
	yield(get_tree().create_timer(2.0), "timeout")

	get_tree().call_group("UI", "tampilkan_info", "Raka: Toko ini butuh barang yang lebih lengkap.", Color.darkblue)
	yield(get_tree().create_timer(2.0), "timeout")

	
	get_tree().call_group("LevelToko", "selesai_event_hari3")
	
	pulang()


func pulang():
	target_tujuan = titik_pintu
	sudah_sampai = false
	sedang_pulang = true
