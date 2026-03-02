extends Control

var hp_scene = preload("res://scene/ui_hp.tscn")
var hp_instance = null

func _ready():
	update_ui()

func _process(_delta):
	update_ui()

func update_ui():
	$dayPanel/dayLabel.text = "Hari " + str(GameManager.current_day)
	$moneyPanel/moneyLabel.text = "💰 Rp " + str(GameManager.money)

func _on_HpButton_pressed():
	if hp_instance == null:
		hp_instance = hp_scene.instance()
		get_parent().add_child(hp_instance)
	else:
		hp_instance.queue_free()
		hp_instance = null
		
		
