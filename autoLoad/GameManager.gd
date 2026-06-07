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

var money = 2000000
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
var jumlah_objek_dibersihkan = 0
var total_objek_bersih = 4

var next_player_position = null

var pemasukan_min_pak_beni = 150000
var pemasukan_max_pak_beni = 350000
var pak_beni_income_given_today = false

var ending_choice = ""

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
		if story_step != "hari_1_tidur":
			get_tree().call_group("UI", "tampilkan_info", "Belum waktunya tidur.", Color.red)
			return false

		current_day += 1
		reset_day_state()
		save_game()
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
	pak_beni_income_given_today = false


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
	# KUNCI: Player harus sudah selesai ngobrol dengan Pak Beni baru bisa periksa barang!
	if story_step != "hari_1_periksa":
		get_tree().call_group("UI", "tampilkan_info", "Bicara dengan Pak Beni dulu sebelum memeriksa toko.", Color.orange)
		return

	jumlah_objek_dicek += 1
	cek_explore_toko_selesai()


func cek_explore_toko_selesai():
	if jumlah_objek_dicek >= total_objek_wajib:
		set_story_step("hari_1_pulang")
		get_tree().call_group("UI", "tampilkan_info", "Pemeriksaan selesai. Sekarang pulanglah ke rumah untuk istirahat.", Color.green)




func check_story_event_on_open_store():
	if current_day == 3 and not event_hari_3_done:
		event_hari_3_done = true
		get_tree().call_group("UI", "tampilkan_info", "Ada pelanggan mencari barang yang belum tersedia.", Color.orange)
		emit_signal("data_update")
		return "hari_3"

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
	day_can_end = true
	player_bisa_gerak = true

	get_tree().call_group("UI", "tampilkan_info", "Sudah larut malam. Toko harus ditutup untuk hari ini.", Color.red)
	get_tree().call_group("BukaToko", "force_update_sign")

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
	pak_beni_income_given_today = false

	jumlah_objek_dicek = 0
	jumlah_objek_dibersihkan = 0

	if day == 1:
		story_step = "hari_1_intro"

	elif day == 2:
		story_step = "hari_2_sore_di_rumah"

	elif day == 3:
		story_step = "hari_3_sore_di_rumah"
		event_hari_3_done = false

	elif day == 4:
		story_step = "hari_4_sore_di_rumah"
		event_hari_4_done = false

	elif day == 5:
		story_step = "hari_5_sore_di_rumah"
		event_hari_5_done = false

	else:
		story_step = "normal_gameplay"

	emit_signal("data_update")
	get_tree().call_group("UI", "tampilkan_info", "DEBUG: Lompat ke Hari " + str(day), Color.orange)

func reset_new_game():
	current_day = 1
	current_month = 1
	story_step = "hari_1_intro"

	money = 2000000
	hutang_utama = 20000000
	pinjol = 0
	reputasi = 0
	ending_choice = ""

	toko_buka = false
	toko_sudah_dibuka_hari_ini = false
	served_today = 0
	day_can_end = false

	event_hari_3_done = false
	event_hari_4_done = false
	event_hari_5_done = false

	jumlah_objek_dicek = 0
	jumlah_objek_dibersihkan = 0

	jam = 15
	menit = 0
	timer_detik = 0.0
	player_bisa_gerak = true
	pak_beni_income_given_today = false
	next_player_position = null

	stock = {
		"mie": 10,
		"minyak": 5,
		"beras": 3
	}

	emit_signal("data_update")

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
		money = int(save_data.get("money", 2000000))
		hutang_utama = int(save_data.get("hutang_utama", 20000000))
		pinjol = int(save_data.get("pinjol", 0))
		reputasi = int(save_data.get("reputasi", 0))
		stock = save_data.get("stock", stock)
		story_step = save_data.get("story_step", "hari_1_intro")

		var target_scene = save_data.get("last_scene", "res://scene/rumah.tscn")

		var file_check = File.new()
		if not file_check.file_exists(target_scene):
			print("Scene save tidak ditemukan: ", target_scene)
			target_scene = "res://scene/rumah.tscn"

		var change_err = get_tree().change_scene(target_scene)

		if change_err != OK:
			print("Gagal pindah ke scene save. Error: ", change_err)
			get_tree().change_scene("res://scene/rumah.tscn")

		emit_signal("data_update")
		return true

	return false


func apply_next_player_position():
	if next_player_position == null:
		return

	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		players[0].global_position = next_player_position
		next_player_position = null

func reset_bersih_toko():
	jumlah_objek_dibersihkan = 0
	emit_signal("data_update")

func tambah_progres_bersih():
	if story_step != "hari_2_bersih_toko":
		get_tree().call_group("UI", "tampilkan_info", "Belum waktunya bersih-bersih.", Color.orange)
		return

	jumlah_objek_dibersihkan += 1
	emit_signal("data_update")

	print("DEBUG BERSIH: ", jumlah_objek_dibersihkan, "/", total_objek_bersih)

	if jumlah_objek_dibersihkan >= total_objek_bersih:
		set_story_step("hari_2_pindah_toko")
		print("DEBUG: Semua bersih, panggil selesai_bersih_toko")
		get_tree().call_group("LevelToko", "selesai_bersih_toko")

func beri_pemasukan_pagi():
	if pak_beni_income_given_today:
		return 0

	randomize()

	var pemasukan = int(rand_range(pemasukan_min_pak_beni, pemasukan_max_pak_beni))
	money += pemasukan
	pak_beni_income_given_today = true

	emit_signal("data_update")
	return pemasukan

func pilih_ending(choice):
	ending_choice = choice
	emit_signal("data_update")
