extends Control

var hp_scene = preload("res://scene/ui_hp.tscn")
var hp_instance = null

func _process(_delta):
	$rootUI/dayPanel/dayLabel.text = "Hari " + str(GameManager.current_day)
	$rootUI/moneyPanel/moneyLabel.text = "💰 Rp " + str(GameManager.money)

func _on_HpButton_pressed():
	if hp_instance == null:
		hp_instance = hp_scene.instance()
		add_child(hp_instance)
