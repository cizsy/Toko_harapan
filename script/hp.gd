extends Control

signal hp_ditutup 

onready var label_jam = $HomePanel/TeksJam
onready var notif_button = $HomePanel/NotifButton

onready var label_uang = $NotePanel/LabelUang
onready var label_hutang = $NotePanel/LabelHutang
onready var stock_label = $NotePanel/StockLabel



func _ready():
	notif_button.visible = false
	
	show_home()
	update_hp_ui()

	if not GameManager.is_connected("data_update", self, "update_hp_ui"):
		GameManager.connect("data_update", self, "update_hp_ui")



func _process(_delta):
	update_jam()


func update_jam():
	# Menit tetap jalan di sistem, tapi yang tampil di HP cuma jam bulat
	label_jam.text = "%02d:00" % GameManager.jam


func update_hp_ui():
	update_jam()

	if GameManager.has_method("format_rupiah"):
		label_uang.text = "Uang: " + GameManager.format_rupiah(GameManager.money)
		label_hutang.text = "Hutang: " + GameManager.format_rupiah(GameManager.hutang_utama)
	else:
		label_uang.text = "Uang: Rp " + str(GameManager.money)
		label_hutang.text = "Hutang: Rp " + str(GameManager.hutang_utama)

	stock_label.text = "Stok:\nMie: " + str(GameManager.stock.get("mie", 0)) + "\nMinyak: " + str(GameManager.stock.get("minyak", 0)) + "\nBeras: " + str(GameManager.stock.get("beras", 0))

	update_supplier_ui()
	cek_notifikasi_hari_5()


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
	update_hp_ui()


func show_supplier():
	hide_all_panels()
	$SupplierPanel.visible = true
	update_supplier_ui()


func show_note():
	hide_all_panels()
	$NotePanel.visible = true
	update_hp_ui()


func update_supplier_ui():
	$SupplierPanel/miePanel/StokLabel.text = "Stok: " + str(GameManager.stock.get("mie", 0))
	$SupplierPanel/MinyakPanel/StokLabel.text = "Stok: " + str(GameManager.stock.get("minyak", 0))
	$SupplierPanel/BerasPanel/StokLabel.text = "Stok: " + str(GameManager.stock.get("beras", 0))


func _on_BeliMie_pressed():
	if GameManager.current_day == 1:
		get_tree().call_group("UI", "tampilkan_info", "Belum waktunya belanja stok di hari pertama.", Color.red)
		return
		
	var sukses = GameManager.restock_item("mie", 5, 10000)
	if sukses:
		update_hp_ui()
		GameManager.emit_signal("data_update")


func _on_BeliMinyak_pressed():
	if GameManager.current_day == 1:
		get_tree().call_group("UI", "tampilkan_info", "Belum waktunya belanja stok di hari pertama.", Color.red)
		return
		
	var sukses = GameManager.restock_item("minyak", 3, 75000)
	if sukses:
		update_hp_ui()
		GameManager.emit_signal("data_update")


func _on_BeliBeras_pressed():
	if GameManager.current_day == 1:
		get_tree().call_group("UI", "tampilkan_info", "Belum waktunya belanja stok di hari pertama.", Color.red)
		return
		
	var sukses = GameManager.restock_item("beras", 2, 80000)
	if sukses:
		update_hp_ui()
		GameManager.emit_signal("data_update")


func cek_notifikasi_hari_5():
	if GameManager.current_day == 5 and GameManager.story_step != "ending_pinjaman" and GameManager.story_step != "ending_tanpa_pinjaman":
		notif_button.visible = true
	else:
		notif_button.visible = false

func _on_NotifButton_pressed():
	get_tree().call_group("UI", "tampilkan_info", "Pinjaman modal cepat tersedia.", Color.orange)
	notif_button.visible = false
	emit_signal("hp_ditutup")
	queue_free()
