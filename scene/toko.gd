extends Node2D

signal pelayanan_selesai

var layanin = false

func _process(delta):
	# Logika melayani pelanggan
	if layanin: 
		$pelangganBar.value += 40 * delta
		if $pelangganBar.value >= 100:
			selesai_melayani()

func selesai_melayani():
	layanin = false
	$pelangganBar.visible = false
	GameManager.customer_served()
	

func mulaiLayanin():
	$pelangganBar.visible = true
	$pelangganBar.value = 0
	layanin = true

func _on_layaniPelanggan_pressed():
	if GameManager.served_today < GameManager.max_customer_per_day and not layanin:
		mulaiLayanin()

