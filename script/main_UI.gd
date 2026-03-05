extends Control

var hp_scene = preload("res://scene/ui_hp.tscn")
var hp_instance = null
var layanin = false

func _ready():
	update_ui()

func _process(delta):
	update_ui()
	
	if layanin: 
		$pelangganBar.value += 40*delta
		
		if $pelangganBar.value >= 100:
			print("selesai melayani")
			layanin = false
			$pelangganBar.visible = false
			GameManager.customer_served()

func update_ui():
	$dayPanel/dayLabel.text = "Hari " + str(GameManager.current_day)
	$moneyPanel/moneyLabel.text = "💰 Uang : Rp " + str(GameManager.money)

func _on_HpButton_pressed():
	if hp_instance == null:
		hp_instance = hp_scene.instance()
		get_tree().current_scene.add_child(hp_instance)
	else:
		hp_instance.queue_free()
		hp_instance = null
		
func showInfo(text):
	$infoPanel/infoLabel.text = text
	

func mulaiLayanin():
	$pelangganBar.visible = true
	$pelangganBar.value = 0
	layanin = true


func _on_layaniPelanggan_pressed():
	if GameManager.served_today < GameManager.max_customer_per_day and not layanin:
		mulaiLayanin()
	else:
		showInfo("Hari ini sudah cukup pelanggan kamu bisa mengakhiri hari!")
