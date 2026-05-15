extends Control

var hp_scene = preload("res://scene/ui_hp.tscn")
var hp_instance = null

onready var label_uang = $moneyPanel/moneyLabel
onready var day_label = $dayPanel/dayLabel
onready var infoLabel = $infoPanel/infoLabel
onready var infoPanel = $infoPanel
onready var hp_button = $HpButton


func _ready():
	add_to_group("UI")

	infoLabel.text = ""
	infoPanel.visible = false
	hp_button.visible = true

	if not GameManager.is_connected("data_update", self, "update_ui"):
		GameManager.connect("data_update", self, "update_ui")

	update_ui()


func _process(_delta):
	update_ui()


func update_ui():
	day_label.text = "Hari " + str(GameManager.current_day)
	label_uang.text = "💰 Rp " + str(GameManager.money)


func _on_HpButton_pressed():
	if not is_instance_valid(hp_instance):
		hp_instance = hp_scene.instance()
		add_child(hp_instance)

		if hp_instance.has_signal("hp_ditutup"):
			hp_instance.connect("hp_ditutup", self, "_on_hp_terhapus_manual")
		hp_instance.connect("tree_exited", self, "_on_hp_tree_exited")

		hp_button.visible = false
		GameManager.player_bisa_gerak = false
	else:
		tutup_hp()


func _on_hp_terhapus_manual():
	hp_button.visible = true
	hp_instance = null
	GameManager.player_bisa_gerak = true


func _on_hp_tree_exited():
	hp_button.visible = true
	hp_instance = null
	GameManager.player_bisa_gerak = true


func tutup_hp():
	if is_instance_valid(hp_instance):
		hp_instance.queue_free()

	hp_instance = null
	hp_button.visible = true
	GameManager.player_bisa_gerak = true


func tampilkan_info(pesan, warna = Color.black):
	infoLabel.text = str(pesan)
	infoLabel.modulate = warna
	infoPanel.visible = true

	yield(get_tree().create_timer(2.0), "timeout")

	if infoLabel.text == str(pesan):
		infoLabel.text = ""
		infoPanel.visible = false
