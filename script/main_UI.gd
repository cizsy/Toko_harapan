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
	# Jika HP belum ada, buat baru
	if not is_instance_valid(hp_instance):
		hp_instance = hp_scene.instance()
		add_child(hp_instance) # Spawn di dalam main_UI (CanvasLayer)
		
		hp_instance.raise()
		
		$HpButton.visible = false
		
		# Jika di dalam ui_hp.tscn kamu punya tombol "Close", 
		# pastikan dia memanggil queue_free() atau kirim signal ke sini.
	else:
		# Jika tombol ditekan saat HP masih ada, kita tutup
		tutup_hp()

# FUNGSI KUNCI: Gunakan ini untuk menutup HP dengan aman
func tutup_hp():
	if is_instance_valid(hp_instance):
		hp_instance.queue_free()
	
	hp_instance = null
	$HpButton.visible = true



