extends Node

signal data_update

#player
var player_bisa_gerak = true

#entahlah
var prev_scen = ""

# waktu
var current_day = 1
var current_month = 1

var days_per_month = 5
var max_month = 3

var day_can_end = false

# ekonomi
var money = 5_000_000
var hasil_uang = 10000

#pelanggan
var served_today = 0
var max_customer_per_day = 5


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


