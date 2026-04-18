extends Node2D

signal pelayanan_selesai

var sedang_melayani = false
var npc_scene = preload("res://scene/NPC_ibu2.tscn")
var npc_saat_ini = null
var player_di_kasir = false

onready var p_bar = $layani/pelangganBar
onready var tombol_layani = $layani/layaniPelanggan

func _ready():
	p_bar.visible = false
	p_bar.value = 0
	tombol_layani.visible = false
	
	spawn_npc()

func _process(delta):
	if sedang_melayani: 
		p_bar.value += 40 * delta
		if p_bar.value >= p_bar.max_value:
			selesai_melayani()

func mulaiLayanin():
	sedang_melayani = true
	p_bar.value = 0
	p_bar.visible = true
	tombol_layani.disabled = true 
	
	GameManager.player_bisa_gerak = false


func selesai_melayani():
	sedang_melayani = false
	p_bar.visible = false
	tombol_layani.disabled = false
	
	GameManager.customer_served()
	GameManager.player_bisa_gerak = true
	
	if is_instance_valid(npc_saat_ini):
		npc_saat_ini.pulang()
	
	emit_signal("pelayanan_selesai")
	
	get_tree().call_group("UI", "tampilkan_info", "Selesai + Rp 10.000", Color.darkblue)

func _on_layaniPelanggan_pressed():
	if GameManager.served_today < GameManager.max_customer_per_day and not sedang_melayani and player_di_kasir:
		mulaiLayanin()
	elif not player_di_kasir:
		print("player terlalu jauh dari kasir")
		


#NPC SPAWN

func spawn_npc():
	var npc = npc_scene.instance()
	npc.position = Vector2(414, 609)
	add_child(npc)
	npc_saat_ini = npc


func _on_player_bisa_layani_body_entered(body):
	if body.is_in_group("Player"):
		player_di_kasir = true
		tombol_layani.visible = true


func _on_player_bisa_layani_body_exited(body):
	if body.is_in_group("Player"):
		player_di_kasir = false
		tombol_layani.visible = false
