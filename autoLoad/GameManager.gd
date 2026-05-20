extends Node

signal data_update

# ======================
# PLAYER / UI STATE
# ======================
var player_bisa_gerak = true
var prev_scen = ""

# ======================
# WAKTU / HARI
# ======================
var max_month = 3
var jam = 15
var menit = 0
var current_day = 1
var current_month = 1
var days_per_month = 5

var timer_detik = 0.0
var kecepatan_waktu = 0.2

var day_can_end = false

# ======================
# EKONOMI
# ======================
var money = 5000000
var hutang_utama = 20000000
var pinjol = 0
var reputasi = 0

var stock = {
	"mie": 10,
	"minyak": 5,
	"beras": 3
}

var item_prices = {
	"mie": 3000,
	"minyak": 32000,
	"beras": 50000
}

# ======================
# TOKO / PELANGGAN
# ======================
var toko_buka = false
var toko_sudah_dibuka_hari_ini = false
var served_today = 0
var max_customer_per_day = 5

# ======================
# STORY EVENT
# ======================
var event_hari_3_done = false
var event_hari_4_done = false
var event_hari_5_done = false


func _process(delta):
	if toko_buka:
		jalankan_jam(delta)


func _ready():
	debug_go_to_day(3)

# ======================
# EKONOMI
# ======================

func sell_item(item_name):
	if not stock.has(item_name):
		get_tree().call_group("UI", "tampilkan_info", "Barang tidak dikenal: " + str(item_name), Color.red)
		return false

	if stock[item_name] <= 0:
		get_tree().call_group("UI", "tampilkan_info", "Stok " + str(item_name) + " habis!", Color.red)
		return false

	var harga = item_prices.get(item_name, 10000)

	stock[item_name] -= 1
	money += harga
	served_today += 1

	get_tree().call_group("UI", "tampilkan_info", "Terjual " + str(item_name) + " +Rp " + str(harga), Color.darkblue)

	if served_today >= max_customer_per_day:
		day_can_end = true
		get_tree().call_group("UI", "tampilkan_info", "Semua pelanggan selesai. Toko bisa ditutup.", Color.green)

	emit_signal("data_update")
	return true


func restock_item(item_name, amount, cost):
	if not stock.has(item_name):
		stock[item_name] = 0

	if money < cost:
		get_tree().call_group("UI", "tampilkan_info", "Uang tidak cukup untuk restock.", Color.red)
		return false

	money -= cost
	stock[item_name] += amount

	emit_signal("data_update")
	get_tree().call_group("UI", "tampilkan_info", "Restock " + str(item_name) + " +" + str(amount), Color.green)
	return true


func pay_debt(amount):
	var payment = min(amount, hutang_utama)

	if money >= payment:
		money -= payment
		hutang_utama -= payment
		emit_signal("data_update")
		get_tree().call_group("UI", "tampilkan_info", "Hutang terbayar: -Rp " + str(payment), Color.green)
	else:
		get_tree().call_group("UI", "tampilkan_info", "Uang tidak cukup.", Color.red)


func customer_served():
	sell_item("mie")


# ======================
# HARI / BULAN
# ======================

func end_day():
	if not day_can_end:
		get_tree().call_group("UI", "tampilkan_info", "Belum bisa tidur. Layani semua pelanggan dulu.", Color.red)
		return false

	current_day += 1

	if current_day > days_per_month:
		end_month()
	else:
		reset_day_state()

	get_tree().call_group("UI", "tampilkan_info", "Hari Ke-" + str(current_day) + " Dimulai!", Color.gold)
	emit_signal("data_update")
	return true


func reset_day_state():
	served_today = 0
	day_can_end = false
	toko_buka = false
	toko_sudah_dibuka_hari_ini = false
	jam = 15
	menit = 0
	timer_detik = 0.0
	player_bisa_gerak = true


func end_month():
	current_day = 1
	current_month += 1

	if current_month > max_month:
		check_ending()
		return

	max_customer_per_day = get_max_customer()
	reset_day_state()
	evaluate_month()


func evaluate_month():
	print("Evaluasi bulan ", current_month - 1)


func check_ending():
	if hutang_utama <= 0:
		print("GOOD ENDING")
	else:
		print("BAD ENDING")


func get_max_customer():
	return 3 + current_month

# ======================
# STORY EVENT
# ======================

func check_story_event_on_open_store():
	if current_day == 3 and not event_hari_3_done:
		event_hari_3_done = true
		get_tree().call_group("UI", "tampilkan_info", "Ada pelanggan mencari barang yang belum tersedia.", Color.orange)
		emit_signal("data_update")
		return "hari_3"

	if current_day == 4 and not event_hari_4_done:
		event_hari_4_done = true
		get_tree().call_group("UI", "tampilkan_info", "Pak Beni ingin membicarakan soal modal.", Color.orange)
		emit_signal("data_update")
		return "hari_4"

	if current_day == 5 and not event_hari_5_done:
		event_hari_5_done = true
		get_tree().call_group("UI", "tampilkan_info", "HP Raka bergetar. Ada iklan mencurigakan.", Color.orange)
		emit_signal("data_update")
		return "hari_5"

	return ""

# ======================
# SCENE
# ======================

func pindah_ke_settings():
	if get_tree().current_scene:
		prev_scen = get_tree().current_scene.filename
	else:
		prev_scen = ""

	player_bisa_gerak = true
	get_tree().change_scene("res://scene/settings.tscn")


# ======================
# JAM
# ======================

func jalankan_jam(delta):
	timer_detik += delta

	if timer_detik >= kecepatan_waktu:
		menit += 1
		timer_detik = 0.0

		if menit >= 60:
			menit = 0
			jam += 1

		if jam >= 24:
			jam = 0
			paksa_tutup_toko()


func paksa_tutup_toko():
	toko_buka = false
	player_bisa_gerak = true
	get_tree().call_group("UI", "tampilkan_info", "Sudah larut malam. Toko tutup.", Color.red)
	emit_signal("data_update")

func debug_go_to_day(day):
	current_day = day
	served_today = 0
	day_can_end = false
	toko_buka = false
	toko_sudah_dibuka_hari_ini = false
	jam = 15
	menit = 0
	timer_detik = 0.0
	player_bisa_gerak = true
	
	if day == 3:
		event_hari_3_done = false
	
	emit_signal("data_update")
	get_tree().call_group("UI", "tampilkan_info", "DEBUG: Lompat ke Hari " + str(day), Color.orange)
	current_day = day
	served_today = 0
	day_can_end = false
	toko_buka = false
	toko_sudah_dibuka_hari_ini = false
	jam = 15
	menit = 0
	timer_detik = 0.0
	player_bisa_gerak = true
	
	emit_signal("data_update")
	get_tree().call_group("UI", "tampilkan_info", "DEBUG: Lompat ke Hari " + str(day), Color.orange)
