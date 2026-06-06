extends Control

onready var master_slider = get_node_or_null("VBoxContainer/volume/slider/masterSlider")
onready var music_slider = get_node_or_null("VBoxContainer/volume/slider/musicSlider")
onready var sfx_slider = get_node_or_null("VBoxContainer/volume/slider/sfxSlider")

onready var keluar_button = get_node_or_null("Keluar")
onready var save_button = get_node_or_null("save")
onready var back_button = get_node_or_null("Back")


func _ready():
	load_slider_values()
	update_button_visibility()


func update_button_visibility():
	# Kalau settings dibuka dari Main Menu, tombol Keluar disembunyikan.
	# Kalau settings dibuka dari gameplay, tombol Keluar boleh muncul.
	if keluar_button:
		if GameManager.prev_scen == "" or GameManager.prev_scen == "res://scene/mainMenu.tscn" or GameManager.prev_scen == "res://scene/main_menu.tscn":
			keluar_button.visible = false
		else:
			keluar_button.visible = true


func load_slider_values():
	if master_slider:
		master_slider.min_value = 0
		master_slider.max_value = 100
		master_slider.value = SettingsManager.get_setting("audio", "master_volume", 80)
		apply_bus_volume("Master", master_slider.value)

	if music_slider:
		music_slider.min_value = 0
		music_slider.max_value = 100
		music_slider.value = SettingsManager.get_setting("audio", "music_volume", 70)
		apply_bus_volume("Music", music_slider.value)

	if sfx_slider:
		sfx_slider.min_value = 0
		sfx_slider.max_value = 100
		sfx_slider.value = SettingsManager.get_setting("audio", "sfx_volume", 80)
		apply_bus_volume("SFX", sfx_slider.value)


func apply_bus_volume(bus_name, slider_value):
	var bus_index = AudioServer.get_bus_index(bus_name)

	if bus_index == -1:
		print("Audio bus tidak ditemukan: ", bus_name)
		return

	var normalized_value = clamp(float(slider_value) / 100.0, 0.0, 1.0)

	if normalized_value <= 0.001:
		AudioServer.set_bus_volume_db(bus_index, -80)
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		AudioServer.set_bus_volume_db(bus_index, linear2db(normalized_value))


func _on_masterSlider_value_changed(value):
	apply_bus_volume("Master", value)
	SettingsManager.save_setting("audio", "master_volume", value)


func _on_musicSlider_value_changed(value):
	apply_bus_volume("Music", value)
	SettingsManager.save_setting("audio", "music_volume", value)


func _on_sfxSlider_value_changed(value):
	apply_bus_volume("SFX", value)
	SettingsManager.save_setting("audio", "sfx_volume", value)


func _on_Back_pressed():
	kembali_ke_scene_sebelumnya()


func _on_save_pressed():
	# Slider sudah otomatis disimpan saat value berubah.
	get_tree().call_group("UI", "tampilkan_info", "Pengaturan disimpan.", Color.green)


func _on_Keluar_pressed():
	# Keluar ke main menu dari gameplay.
	GameManager.prev_scen = ""
	get_tree().change_scene("res://scene/mainMenu.tscn")


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		kembali_ke_scene_sebelumnya()


func kembali_ke_scene_sebelumnya():
	if GameManager.prev_scen != "":
		var tujuan = GameManager.prev_scen
		GameManager.prev_scen = ""
		get_tree().change_scene(tujuan)
	else:
		get_tree().change_scene("res://scene/mainMenu.tscn")
