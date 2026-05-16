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


func _on_Peraturan_pressed():
	show_settings()


func _on_toktok_pressed():
	show_toktok()


func _on_crome_pressed():
	show_crome()


func _on_Supplier_pressed():
	show_supplier()


func _on_bankku_pressed():
	show_bank()


func _on_BackButton_pressed():
	show_home()


func hide_all_panels():
	$HomePanel.visible = false
	$SupplierPanel.visible = false
	$BankPanel.visible = false
	$TokTokPanel.visible = false
	$SettingsPanel.visible = false
	$CromePanel.visible = false


func show_home():
	hide_all_panels()
	$HomePanel.visible = true


func show_supplier():
	hide_all_panels()
	$SupplierPanel.visible = true
	update_supplier_ui()


func show_bank():
	hide_all_panels()
	$BankPanel.visible = true


func show_toktok():
	hide_all_panels()
	$TokTokPanel.visible = true


func show_settings():
	hide_all_panels()
	$SettingsPanel.visible = true


func show_crome():
	hide_all_panels()
	$CromePanel.visible = true


func update_supplier_ui():
	$SupplierPanel/miePanel/StokLabel.text = "Stok: " + str(GameManager.stock["mie"])
	$SupplierPanel/MinyakPanel/StokLabel.text = "Stok: " + str(GameManager.stock["minyak"])
	$SupplierPanel/BerasPanel/StokLabel.text = "Stok: " + str(GameManager.stock["beras"])


func _on_BeliMie_pressed():
	GameManager.restock_item("mie", 5, 10000)
	update_supplier_ui()


func _on_BeliMinyak_pressed():
	GameManager.restock_item("minyak", 3, 75000)
	update_supplier_ui()


func _on_BeliBeras_pressed():
	GameManager.restock_item("beras", 2, 80000)
	update_supplier_ui()
