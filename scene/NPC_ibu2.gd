extends KinematicBody2D

var kecepatan = 100
var titik_kasir = Vector2(398, 344)
var titik_pintu = Vector2(414, 609)
var target_tujuan = titik_kasir # Ganti angka ini dengan koordinat depan kasirmu
var sudah_sampai = false

func _physics_process(_delta):
	if not sudah_sampai:
		var arah = (target_tujuan - global_position).normalized()
		move_and_slide(arah * kecepatan)
		
		if global_position.distance_to(target_tujuan) < 10:
			sudah_sampai = true
			
			# JIKA sudah sampai di pintu setelah pulang, hapus NPC-nya
			if target_tujuan == titik_pintu:
				queue_free()

# Fungsi ini akan dipanggil oleh script Toko
func pulang():
	target_tujuan = titik_pintu
	sudah_sampai = false
	print("NPC: Makasih ya, saya pulang dulu!")
