extends KinematicBody2D

var kecepatan = 100
var titik_kasir = Vector2(451, 405)
var titik_pintu = Vector2(439, 577)
var target_tujuan = titik_kasir
var sudah_sampai = false
var sedang_pulang = false

var requested_item = "mie"
var request_icons = {
	"mie": "🍜",
	"minyak": "🛢️",
	"beras": "🍚"
}

func _ready():
	randomize()
	set_random_request()
	_update_request_label()

func _physics_process(_delta):
	if not sudah_sampai:
		var arah = (target_tujuan - global_position).normalized()
		# FIX: Gunakan move_and_slide dengan benar di Godot 3
		move_and_slide(arah * kecepatan)
		
		# Cek jarak ke target tujuan yang aktif saat ini
		if global_position.distance_to(target_tujuan) < 10:
			sudah_sampai = true
			
			# Jika target tujuan adalah pintu dan sudah sampai, hapus NPC
			if sedang_pulang:
				queue_free()

func set_random_request():
	var items = ["mie", "minyak", "beras"]
	requested_item = items[randi() % items.size()]

func _update_request_label():
	if has_node("RequestLabel"):
		var label = $RequestLabel
		if request_icons.has(requested_item):
			label.text = request_icons[requested_item]
		else:
			label.text = str(requested_item)

func get_requested_item():
	return requested_item

func pulang():
	# PENGAMAN: Mencegah fungsi terpanggil dua kali jika tombol kasir kepencet lagi
	if sedang_pulang:
		return
		
	target_tujuan = titik_pintu
	sedang_pulang = true
	sudah_sampai = false # Reset agar NPC mau berjalan lagi ke arah pintu
	
	# Sembunyikan emoji di atas kepalanya karena barangnya sudah dibeli
	if has_node("RequestLabel"):
		$RequestLabel.visible = false
		
	print("NPC: Makasih ya, saya pulang dulu!")
