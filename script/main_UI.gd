extends Control

func _process(delta):
	$dayPanel/dayLabel.text = "Hari " + str(GameManager.current_day)
	$moneyPanel/moneyLabel.text = "💰 Rp " + str(GameManager.money)
