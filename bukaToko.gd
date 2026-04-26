extends Area2D

var player_di_area = false
onready var tombolInteract = $Interact
onready var signBuka = $SignBuka
onready var signTutup = $SignTutup

func _ready():
	tombolInteract.visible = false
	signBuka.visible = false
	signTutup.visible = true
	
func _process(_delta):
	if player_di_area and not GameManager.toko_buka and GameManager.jam >= 15:
		tombolInteract.visible = true
	else:
		tombolInteract.visible = false

	# 2. LOGIKA SAAT TOMBOL 'E' DITEKAN
	if player_di_area and Input.is_action_just_pressed("interact"):
		if not GameManager.toko_buka:
			if GameManager.jam >= 15:
				eksekusi_buka_toko()



func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		player_di_area = true
		get_tree().call_group("UI", "tampilkan_info", "Tekan 'E' untuk Buka Toko", Color.black)

func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		player_di_area = false

func eksekusi_buka_toko():
	GameManager.toko_buka = true
	signTutup.visible = false
	signBuka.visible = true

	get_tree().call_group("UI", "tampilkan_info", "Toko Dibuka!", Color.green)

	# Panggil NPC
	get_tree().call_group("LevelToko", "spawn_npc")
