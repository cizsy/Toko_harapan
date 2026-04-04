extends Node2D

signal pelayanan_selesai

var sedang_melayani = false # Ganti nama variabel agar tidak bentrok dengan nama node

# Referensi node agar ngetik kodenya lebih pendek
@onready var p_bar = $layani/pelangganBar
@onready var tombol_layani = $layani/layaniPelanggan

func _ready():
	p_bar.visible = false
	p_bar.value = 0

func _process(delta):
	if sedang_melayani: 
		p_bar.value += 40 * delta
		if p_bar.value >= p_bar.max_value:
			selesai_melayani()

func mulaiLayanin():
	sedang_melayani = true
	p_bar.visible = true
	p_bar.value = 0
	
	# LOCK PLAYER: Asumsikan player ada di group "player"
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false) # Player berhenti total
		player.set_process(false)
	
	# Beri warna terang ke Bar agar kelihatan
	p_bar.modulate = Color(1, 1, 1) 
	# Matikan tombol supaya tidak di-spam
	tombol_layani.disabled = true 

func selesai_melayani():
	sedang_melayani = false
	p_bar.visible = false
	tombol_layani.disabled = false
	
	# UNLOCK PLAYER
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(true)
		player.set_process(true)
	
	if GameManager.has_method("customer_served"):
		GameManager.customer_served()
	
	emit_signal("pelayanan_selesai")
	print("Pelayanan selesai!")

func _on_layaniPelanggan_pressed():
	if GameManager.served_today < GameManager.max_customer_per_day and not sedang_melayani:
		mulaiLayanin()
