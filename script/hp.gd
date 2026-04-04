extends Control

signal hp_ditutup 

func _on_nutupHP_pressed():
	emit_signal("hp_ditutup")
	queue_free()


func _on_AkhiriHari_pressed():
	if GameManager.day_can_end:
		GameManager.end_day()
		
	else:
		print("Wah kamu belum bisa mengakhiri hari!  masih ada pelangan hari ini")


func _on_Peraturan_pressed():
	print("membuka peraturan")


func _on_toktok_pressed():
	print("membuka toktok")


func _on_crome_pressed():
	print("membuka crome")


func _on_Supplier_pressed():
	print("membuka app supplier")


func _on_bankku_pressed():
	GameManager.pay_debt(1_000_000)
