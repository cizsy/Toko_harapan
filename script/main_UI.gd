extends Control

var hp_scene = preload("res://scene/ui_hp.tscn")
var hp_instance = null


func _ready():
	
	
	update_ui()
	$HpButton.visible = true # Pastikan tombol muncul di awal
	
	
	# FIX: Pengecekan otomatis jika hp_instance tiba-tiba hilang/di-free dari dalam scene HP itu sendiri
	if $HpButton.visible == false and not is_instance_valid(hp_instance):
		$HpButton.visible = true
		hp_instance = null

func update_ui():
	$dayPanel/dayLabel.text = "Hari " + str(GameManager.current_day)
	$moneyPanel/moneyLabel.text = "💰 Uang : Rp " + str(GameManager.money)

func _on_HpButton_pressed():
	if not is_instance_valid(hp_instance):
		hp_instance = hp_scene.instance()
		add_child(hp_instance)
		
		hp_instance.connect("hp_ditutup", self, "_on_hp_terhapus_manual")
		
		$HpButton.visible = false
	else:
		tutup_hp()

func _on_hp_terhapus_manual():
	$HpButton.visible = true
	hp_instance = null

func tutup_hp():
	if is_instance_valid(hp_instance):
		hp_instance.queue_free()
	
	hp_instance = null
	$HpButton.visible = true



