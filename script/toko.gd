extends Node2D

signal pelayanan_selesai

var sedang_melayani = false
var npc_saat_ini = null
var player_di_kasir = false
var event_sedang_berjalan = false

var list_npc = [
	preload("res://scene/NPC/NPC_Base.tscn"),
	preload("res://scene/NPC/NPC_bapak2.tscn"),
	preload("res://scene/NPC/NPC_bocah.tscn"),
]

var pak_beni_scene = preload("res://npcPrio/pakBeni.tscn")
var pak_beni_instance = null

var npc_event = preload("res://scene/NPC/NPC_event.tscn")

onready var p_bar = $layani/pelangganBar
onready var tombol_layani = $layani/layaniPelanggan



func _ready():
	add_to_group("LevelToko")
	p_bar.visible = false
	p_bar.value = 0
	tombol_layani.visible = false
	tombol_layani.disabled = false
	
	randomize()
	
	if GameManager.current_day == 4 and not GameManager.event_hari_4_done:
		GameManager.set_story_step("hari_4_shift_sore")
		spawn_pak_beni()
		call_deferred("mulai_event_hari4_modal")

func _process(delta):
	if sedang_melayani:
		p_bar.value += 40 * delta
		
		if p_bar.value >= p_bar.max_value:
			selesai_melayani()


func _on_layaniPelanggan_pressed():
	mulaiLayanin()


func mulaiLayanin():
	if not _boleh_melayani():
		return

	# =========================
	# KHUSUS NPC EVENT
	# =========================
	if npc_saat_ini.has_method("interact_event"):
		event_sedang_berjalan = true
		sedang_melayani = false
		
		p_bar.visible = false
		p_bar.value = 0
		
		tombol_layani.disabled = true
		GameManager.player_bisa_gerak = false
		
		npc_saat_ini.interact_event()
		return

	# =========================
	# NPC BIASA
	# =========================
	sedang_melayani = true
	p_bar.value = 0
	p_bar.visible = true
	tombol_layani.disabled = true
	GameManager.player_bisa_gerak = false


# =========================
# NPC PRIORITAS
# =========================
func spawn_pak_beni():
	if is_instance_valid(pak_beni_instance):
		return

	pak_beni_instance = pak_beni_scene.instance()
	pak_beni_instance.global_position = Vector2(451, 473)
	add_child(pak_beni_instance)


func selesai_melayani():
	sedang_melayani = false
	p_bar.visible = false
	
	# Tombol langsung dibebaskan dari disable di awal biar tidak softlock kalau transaksi gagal
	tombol_layani.disabled = false
	GameManager.player_bisa_gerak = true

	if not is_instance_valid(npc_saat_ini):
		get_tree().call_group("UI", "tampilkan_info", "Tidak ada pelanggan yang dilayani.", Color.red)
		return

	if npc_saat_ini.has_method("interact_event"):
		return

	var item = "mie"

	if npc_saat_ini.has_method("get_requested_item"):
		item = npc_saat_ini.get_requested_item()
	elif "requested_item" in npc_saat_ini:
		item = npc_saat_ini.requested_item

	var success = GameManager.sell_item(item)

	if success:
		if is_instance_valid(npc_saat_ini):
			npc_saat_ini.pulang()
		
		if has_node("/root/SoundManager"):
			SoundManager.play("cash")
		
		npc_saat_ini = null
		emit_signal("pelayanan_selesai")
		
		if GameManager.served_today < GameManager.max_customer_per_day and GameManager.toko_buka:
			yield(get_tree().create_timer(2.0), "timeout")
			# PENGAMAN: Pastikan level/toko belum di-free saat timer selesai
			if is_inside_tree() and GameManager.toko_buka:
				spawn_npc()
	else:
		# Jika stok kurang, tombol_layani sudah otomatis bisa diklik lagi nanti setelah player restock!
		get_tree().call_group("UI", "tampilkan_info", "Stok " + item.to_upper() + " tidak cukup! Restock lewat HP.", Color.red)


func _boleh_melayani():
	if not GameManager.toko_buka:
		get_tree().call_group("UI", "tampilkan_info", "Toko belum buka.", Color.red)
		return false

	if event_sedang_berjalan:
		get_tree().call_group("UI", "tampilkan_info", "Tunggu pelanggan selesai bicara dulu.", Color.orange)
		return false

	if sedang_melayani:
		return false

	if not player_di_kasir:
		get_tree().call_group("UI", "tampilkan_info", "Dekati kasir dulu.", Color.red)
		return false

	if not is_instance_valid(npc_saat_ini):
		get_tree().call_group("UI", "tampilkan_info", "Belum ada pelanggan.", Color.red)
		return false

	if "sudah_sampai" in npc_saat_ini and not npc_saat_ini.sudah_sampai:
		get_tree().call_group("UI", "tampilkan_info", "Tunggu pelanggan sampai kasir dulu.", Color.orange)
		return false

	return true


func spawn_npc():
	if not GameManager.toko_buka:
		return

	if event_sedang_berjalan:
		return

	if is_instance_valid(npc_saat_ini):
		return

	if GameManager.served_today >= GameManager.max_customer_per_day:
		GameManager.day_can_end = true
		get_tree().call_group("UI", "tampilkan_info", "Semua pelanggan selesai. Toko bisa ditutup.", Color.green)
		GameManager.emit_signal("data_update")
		return

	var index_acak = randi() % list_npc.size()
	var npc = list_npc[index_acak].instance()

	npc.position = Vector2(439, 577)
	add_child(npc)

	npc_saat_ini = npc

	if GameManager.current_day == 2 and GameManager.story_step == "hari_2_jualan":
		get_tree().call_group("UI", "tampilkan_info", "Kalau pelanggan sudah sampai kasir, tekan Layani Pelanggan.", Color.black)
	
	if player_di_kasir:
		tombol_layani.visible = true
		tombol_layani.disabled = false


func spawn_npc_event_hari3():
	if not GameManager.toko_buka:
		return

	if event_sedang_berjalan:
		return

	if is_instance_valid(npc_saat_ini):
		return

	var npc = npc_event.instance()
	npc.global_position = Vector2(439, 577)
	add_child(npc)
	
	npc_saat_ini = npc

	GameManager.player_bisa_gerak = true

	if player_di_kasir:
		tombol_layani.visible = true
		tombol_layani.disabled = false


func selesai_event_hari3():
	event_sedang_berjalan = false
	sedang_melayani = false
	
	p_bar.visible = false
	p_bar.value = 0
	
	tombol_layani.disabled = false
	GameManager.player_bisa_gerak = true

	npc_saat_ini = null

	if player_di_kasir:
		tombol_layani.visible = true
	else:
		tombol_layani.visible = false

	if GameManager.toko_buka:
		yield(get_tree().create_timer(2.0), "timeout")
		if is_inside_tree() and GameManager.toko_buka:
			spawn_npc()


func _on_player_bisa_layani_body_entered(body):
	if body.is_in_group("Player") or body.name == "Player" or body.name == "player":
		player_di_kasir = true
		
		if GameManager.toko_buka and not event_sedang_berjalan and is_instance_valid(npc_saat_ini):
			tombol_layani.visible = true


func _on_player_bisa_layani_body_exited(body):
	if body.is_in_group("Player") or body.name == "Player" or body.name == "player":
		player_di_kasir = false
		tombol_layani.visible = false

func mulai_event_hari4_modal():
	if GameManager.event_hari_4_done:
		return

	GameManager.event_hari_4_done = true
	GameManager.player_bisa_gerak = false

	var pemasukan_pagi = 0

	if GameManager.has_method("beri_pemasukan_pagi"):
		pemasukan_pagi = GameManager.beri_pemasukan_pagi()

	var percakapan = [
		{
			"nama": "Pak Beni",
			"teks": "Kamu sudah datang, Ka? Shift pagi sudah Bapak tutup.",
			"portrait": "res://Asset/character/PortraitsFinal/pakbeni.png",
			"posisi": "kanan"
		},
		{
			"nama": "Raka",
			"teks": "Gimana pagi ini, Pak?",
			"portrait": "res://Asset/character/PortraitsFinal/raka.png",
			"posisi": "kiri"
		},
		{
			"nama": "Pak Beni",
			"teks": "Ada beberapa pembeli. Uangnya sudah Bapak taruh di laci.",
			"portrait": "res://Asset/character/PortraitsFinal/pakbeni.png",
			"posisi": "kanan"
		},
		{
			"nama": "Raka",
			"teks": "Makasih, Pak. Lumayan buat nambah modal.",
			"portrait": "res://Asset/character/PortraitsFinal/raka.png",
			"posisi": "kiri"
		},
		{
			"nama": "Raka",
			"teks": "Pak, kalau ambil barang dulu, bayarnya nanti... bisa nggak?",
			"portrait": "res://Asset/character/PortraitsFinal/raka.png",
			"posisi": "kiri"
		},
		{
			"nama": "Pak Beni",
			"teks": "Bapak sudah coba tanya supplier lama.",
			"portrait": "res://Asset/character/PortraitsFinal/pakbeni.png",
			"posisi": "kanan"
		},
		{
			"nama": "Pak Beni",
			"teks": "Mereka minta bayar cash dulu. Katanya masih ada catatan utang lama.",
			"portrait": "res://Asset/character/PortraitsFinal/pakbeni.png",
			"posisi": "kanan"
		},
		{
			"nama": "Raka",
			"teks": "Jadi kalau modalnya kurang, toko ini susah berkembang.",
			"portrait": "res://Asset/character/PortraitsFinal/raka.png",
			"posisi": "kiri"
		},
		{
			"nama": "Pak Beni",
			"teks": "Iya. Tapi jangan ambil jalan cepat yang bikin kamu makin berat.",
			"portrait": "res://Asset/character/PortraitsFinal/pakbeni.png",
			"posisi": "kanan"
		},
		{
			"nama": "Pak Beni",
			"teks": "Bapak pulang dulu. Sore ini toko kamu yang pegang.",
			"portrait": "res://Asset/character/PortraitsFinal/pakbeni.png",
			"posisi": "kanan"
		}
	]

	var dialog_list = get_tree().get_nodes_in_group("DialogSystem")

	if dialog_list.size() == 0:
		GameManager.player_bisa_gerak = true
		GameManager.set_story_step("hari_4_buka_toko")
		return

	var dialog_ui = dialog_list[0]
	dialog_ui.mulai_dialog(percakapan)

	yield(dialog_ui, "dialog_selesai")

	if pemasukan_pagi > 0:
		get_tree().call_group("UI", "tampilkan_info", "Pemasukan pagi dari Pak Beni: Rp " + str(pemasukan_pagi), Color.gold)

	GameManager.player_bisa_gerak = true
	GameManager.set_story_step("hari_4_buka_toko")

	if is_instance_valid(pak_beni_instance):
		pak_beni_instance.pulang()

	get_tree().call_group("UI", "tampilkan_info", "Sekarang buka toko untuk shift sore.", Color.gold)

func munculkan_pilihan_pinjol():
	var dialog_list = get_tree().get_nodes_in_group("DialogSystem")

	if dialog_list.size() == 0:
		get_tree().call_group("UI", "tampilkan_info", "DialogSystem tidak ditemukan.", Color.red)
		GameManager.player_bisa_gerak = true
		return

	var dialog_ui = dialog_list[0]

	if not dialog_ui.has_method("tampilkan_choice_pinjol"):
		get_tree().call_group("UI", "tampilkan_info", "ChoicePanel belum ada di DialogUI.", Color.red)
		GameManager.player_bisa_gerak = true
		return

	dialog_ui.tampilkan_choice_pinjol()

	var pilihan = yield(dialog_ui, "pilihan_dipilih")

	if pilihan == "pinjol":
		GameManager.pinjol += 10000000
		GameManager.set_story_step("ending_pinjaman")
		get_tree().change_scene("res://scene/ending_screen.tscn")

	elif pilihan == "tanpa_pinjol":
		GameManager.set_story_step("ending_tanpa_pinjaman")
		get_tree().change_scene("res://scene/ending_screen.tscn")
