extends Node2D

signal pelayanan_selesai

var sedang_melayani = false # Ganti nama variabel agar tidak bentrok dengan nama node

# Referensi node agar ngetik kodenya lebih pendek
onready var p_bar = $layani/pelangganBar
onready var tombol_layani = $layani/layaniPelanggan

func _ready():
	p_bar.visible = false
	p_bar.value = 0

func _process(delta):
	if sedang_melayani: 
		p_bar.value += 40 * delta
		if p_bar.value >= p_bar.max_value:
			selesai_melayani()

func mulaiLayanin():
	print("Mulai melayani...") # Tambahkan ini buat cek di console
	sedang_melayani = true
	p_bar.value = 0
	p_bar.visible = true
	tombol_layani.disabled = true 

	# LOCK PLAYER
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# JANGAN gunakan set_process(false) kalau script ini nempel di player
		# Cukup matikan physics-nya agar tidak bisa jalan
		player.set_physics_process(false)
		# Jika player punya variabel custom untuk gerak, matikan di sini
		# contoh: player.bisajalan = false

func selesai_melayani():
	sedang_melayani = false
	p_bar.visible = false
	tombol_layani.disabled = false
	
	GameManager.customer_served()
	# Unlock Player
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(true)
	
	emit_signal("pelayanan_selesai")
	
	get_tree().call_group("UI", "tampilkan_info", "+ Rp 10.000", Color.darkblue)

func _on_layaniPelanggan_pressed():
	if GameManager.served_today < GameManager.max_customer_per_day and not sedang_melayani:
		mulaiLayanin()
		


#NPC SPAWN

var npc_scene = preload("res://scene/NPC_ibu2.tscn")

func spawn_npc():
	var npc = npc_scene.instance()
	npc.position = Vector2(408, 578)
	add_child(npc)
