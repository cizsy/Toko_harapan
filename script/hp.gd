extends Control

signal hp_ditutup 

onready var label_jam = $HomePanel/TeksJam 

func _ready():
	show_home()


func _process(_delta):
	label_jam.text = "%02d:%02d" % [GameManager.jam, GameManager.menit]


func _on_nutupHP_pressed():
	emit_signal("hp_ditutup")
	queue_free()


func _on_AkhiriHari_pressed():
	get_tree().call_group("UI", "tampilkan_info", "Sekarang akhiri hari lewat kasur di rumah.", Color.orange)


func _on_Supplier_pressed():
	show_supplier()

func _on_Note_pressed():
	show_note()

func _on_BackButton_pressed():
	show_home()


func hide_all_panels():
	$HomePanel.visible = false
	$SupplierPanel.visible = false
	$NotePanel.visible = false


func show_home():
	hide_all_panels()
	$HomePanel.visible = true


func show_supplier():
	hide_all_panels()
	$SupplierPanel.visible = true
	update_supplier_ui()


func show_note():
	hide_all_panels()
	$BankPanel.visible = true



func update_supplier_ui():
	$SupplierPanel/miePanel/StokLabel.text = "Stok: " + str(GameManager.stock["mie"])
	$SupplierPanel/MinyakPanel/StokLabel.text = "Stok: " + str(GameManager.stock["minyak"])
	$SupplierPanel/BerasPanel/StokLabel.text = "Stok: " + str(GameManager.stock["beras"])


func _on_BeliMie_pressed():
	if GameManager.current_day == 1:
		get_tree().call_group("UI", "tampilkan_info", "Belum waktunya belanja stok di hari pertama.", Color.red)
		return
		
	var sukses = GameManager.restock_item("mie", 5, 10000)
	if sukses:
		update_supplier_ui()
		GameManager.emit_signal("data_update")


func _on_BeliMinyak_pressed():
	if GameManager.current_day == 1:
		get_tree().call_group("UI", "tampilkan_info", "Belum waktunya belanja stok di hari pertama.", Color.red)
		return
		
	var sukses = GameManager.restock_item("minyak", 3, 75000)
	if sukses:
		update_supplier_ui()
		GameManager.emit_signal("data_update")


func _on_BeliBeras_pressed():
	if GameManager.current_day == 1:
		get_tree().call_group("UI", "tampilkan_info", "Belum waktunya belanja stok di hari pertama.", Color.red)
		return
		
	var sukses = GameManager.restock_item("beras", 2, 80000)
	if sukses:
		update_supplier_ui()
		GameManager.emit_signal("data_update")



