extends Node

signal data_update

var player_bisa_gerak = true
var prev_scen = ""

var max_month = 3
var jam = 15
var menit = 0
var current_day = 1
var current_month = 1
var days_per_month = 5

var timer_detik = 0.0
var kecepatan_waktu = 0.2

var day_can_end = false

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

var toko_buka = false
var toko_sudah_dibuka_hari_ini = false
var served_today = 0
var max_customer_per_day = 5

var event_hari_3_done = false
var event_hari_4_done = false
var event_hari_5_done = false
var story_step = "hari_1_intro"

var total_objek_wajib = 6 
var jumlah_objek_dicek = 0


func _process(delta):
	if toko_buka:
		jalankan_jam(delta)


func _ready():
	pass


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


func end_day():
	if current_day == 1:
		if story_step != "hari_1_pulang":
			get_tree().call_group("UI", "tampilkan_info", "Periksa kondisi toko dulu sebelum pulang.", Color.red)
			return false
		else:
			current_day += 1
			set_story_step("normal_gameplay")
			reset_day_state()
			save_game()
			get_tree().call_group("UI", "tampilkan_info", "Hari Ke-" + str(current_day) + " Dimulai!", Color.gold)
			emit_signal("data_update")
			return true

	if not day_can_end:
		get_tree().call_group("UI", "tampilkan_info", "Belum bisa tidur. Layani semua pelanggan dulu.", Color.red)
		return false

	current_day += 1

	if current_day > days_per_month:
		end_month()
	else:
		reset_day_state()

	save_game()
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


func set_story_step(step):
	story_step = step
	emit_signal("data_update")


func reset_story_check():
	jumlah_objek_dicek = 0
	emit_signal("data_update")


func tambah_progres_eksplorasi():
	jumlah_objek_dicek += 1
	cek_explore_toko_selesai()


func cek_explore_toko_selesai():
	if jumlah_objek_dicek >= total_objek_wajib:
		set_story_step("hari_1_pulang")


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


func pindah_ke_settings():
	if get_tree().current_scene:
		prev_scen = get_tree().current_scene.filename
	else:
		prev_scen = ""

	player_bisa_gerak = true
	get_tree().change_scene("res://scene/settings.tscn")


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

	if day == 1:
		story_step = "hari_1_intro"
		reset_story_check()

	if day == 3:
		event_hari_3_done = false

	if day == 4:
		event_hari_4_done = false

	if day == 5:
		event_hari_5_done = false
	
	emit_signal("data_update")
	get_tree().call_group("UI", "tampilkan_info", "DEBUG: Lompat ke Hari " + str(day), Color.orange)


func save_game():
	var save_file = File.new()
	var err = save_file.open("user://save_game.save", File.WRITE)
	if err != OK:
		return

	var save_data = {
		"current_day": current_day,
		"current_month": current_month,
		"money": money,
		"hutang_utama": hutang_utama,
		"pinjol": pinjol,
		"reputasi": reputasi,
		"stock": stock,
		"story_step": story_step,
		"last_scene": get_tree().current_scene.filename if get_tree().current_scene else "res://scene/rumah.tscn"
	}

	save_file.store_line(to_json(save_data))
	save_file.close()


func load_game() -> bool:
	var save_file = File.new()
	if not save_file.file_exists("user://save_game.save"):
		return false

	var err = save_file.open("user://save_game.save", File.READ)
	if err != OK:
		return false

	var current_line = save_file.get_line()
	var save_data = parse_json(current_line)
	save_file.close()

	if typeof(save_data) == TYPE_DICTIONARY:
		current_day = int(save_data.get("current_day", 1))
		current_month = int(save_data.get("current_month", 1))
		money = int(save_data.get("money", 5000000))
		hutang_utama = int(save_data.get("hutang_utama", 20000000))
		pinjol = int(save_data.get("pinjol", 0))
		reputasi = int(save_data.get("reputasi", 0))
		stock = save_data.get("stock", stock)
		story_step = save_data.get("story_step", "normal_gameplay")
		
		var target_scene = save_data.get("last_scene", "res://scene/rumah.tscn")
		get_tree().change_scene(target_scene)
		
		emit_signal("data_update")
		return true

	return false
