extends Node

signal data_update

#player
var player_bisa_gerak = true

#entahlah
var prev_scen = ""

# waktu
var max_month = 3
var jam = 15        # Raka mulai jam 3 sore
var menit = 0   
var current_day = 1
var current_month = 1
var days_per_month = 5
	 
var timer_detik = 0.0
var kecepatan_waktu = 1.0

var day_can_end = false

# ekonomi
var money = 5_000_000
var hasil_uang = 10000

# stok barang
var stock = {
	"mie": 10,
	"minyak": 5,
	"beras": 3
}

#reputasi
var reputasi = 0

#hutang
var hutang_utama = 20_000_000

#pinjol
var pinjol = 0

#status toko
var toko_buka = false
#pelanggan
var served_today = 0
var max_customer_per_day = 5

func _process(delta):
	if toko_buka:
		jalankan_jam(delta)


#bayar hutang
func pay_debt(amount):
	var payment = min(amount, hutang_utama)
	if money >= payment:
		money -= payment
		hutang_utama -= payment
		get_tree().call_group("UI", "tampilkan_info", "Hutang Terbayar: - Rp" + str(payment))
	else:
		print("Uang tidak cukup")

#ganti hari
func end_day():
	if served_today >= max_customer_per_day:
		current_day += 1
		served_today = 0
		# Munculkan info ke UI
		get_tree().call_group("UI", "tampilkan_info", "Hari Ke-" + str(current_day) + " Dimulai!", Color.gold)
		# Di sini kamu bisa tambahin fungsi buat nge-spawn NPC lagi buat besok
	else:
		get_tree().call_group("UI", "tampilkan_info", "Belum bisa tutup toko!", Color.red)	

#func ganti bulan
func end_month():
	current_day = 1
	current_month += 1
	max_customer_per_day = get_max_customer()   # Add this line
	evaluate_month()
	if current_month > max_month:
		check_ending()


#evaluasi perbulan
func evaluate_month():
	#dummy
	print("evaluasi bulan ", current_month - 1)

func check_ending():
	if hutang_utama <= 0:
		print("GOOD ENDING")
	else:
		print("BAD ENDING")


func customer_served():
	served_today += 1
	
	var profit = 10000
	money += profit
	
	emit_signal("data_update")
	
	print("Pelanggan dilayani + Rp. " + str(profit))
	
	if served_today >= max_customer_per_day:
		day_can_end = true
		print("Semua pelanggan selesai! kamu bisa mengakhiri hari")

func get_max_customer():
	return 3 + current_month

func pindah_ke_settings():
	prev_scen = get_tree().current_scene.filename
	
	get_tree().change_scene("res://scene/settings.tscn")

func jalankan_jam(delta):
	timer_detik += delta

	if timer_detik >= kecepatan_waktu:
		menit += 1
		timer_detik = 0 # Reset timer

		# Tampilkan jam di panel Output (bawah Godot) biar gampang nge-test
		print("Jam: ", str(jam).pad_zeros(2), ":", str(menit).pad_zeros(2))

		# Kalau menit sudah 60, tambah 1 jam
		if menit >= 60:
			menit = 0
			jam += 1
			
		# Kalau sudah jam 24 (Tengah Malam)
		if jam >= 24:
			jam = 0 # Kembali ke jam 00:00
			paksa_tutup_toko()

func paksa_tutup_toko():
	toko_buka = false
	print("TENG TONG! Tengah malam, toko otomatis tutup.")
	get_tree().call_group("UI", "tampilkan_info", "Sudah larut malam! Toko Tutup.", Color.red)
