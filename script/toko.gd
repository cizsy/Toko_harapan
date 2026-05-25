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
	
	# Memastikan fungsi acak di-seed sekali saja di awal
	randomize()

	if GameManager.current_day == 1 and GameManager.story_step == "hari_1_intro":
		spawn_pak_beni()


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
	
	# Sinkronisasi visual tombol jika player kebetulan sudah stand-by di kasir
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
