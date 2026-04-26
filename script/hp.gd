extends Control

signal hp_ditutup 

onready var label_jam = $TeksJam 

func _process(delta):
	var jam_sekarang = GameManager.jam
	var menit_sekarang = GameManager.menit

	# Masukkan teksnya ke dalam properti .text milik label_jam
	label_jam.text = "%02d:%02d" % [jam_sekarang, menit_sekarang]

func _on_nutupHP_pressed():
	emit_signal("hp_ditutup")
	queue_free()


func _on_AkhiriHari_pressed():
	if GameManager.day_can_end:
		GameManager.end_day()
		
	else:
		print("Wah kamu belum bisa mengakhiri hari!  masih ada pelangan hari ini")


func _on_Peraturan_pressed():
	get_tree().change_scene("res://scene/settings.tscn")


func _on_toktok_pressed():
	print("membuka toktok")


func _on_crome_pressed():
	print("membuka crome")


func _on_Supplier_pressed():
	print("membuka app supplier")


func _on_bankku_pressed():
	GameManager.pay_debt(200_000)
