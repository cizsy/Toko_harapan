extends Control

onready var master_slider = get_node_or_null("VBoxContainer/volume/slider/masterSlider")
onready var music_slider = get_node_or_null("VBoxContainer/volume/slider/musicSlider")
onready var sfx_slider = get_node_or_null("VBoxContainer/volume/slider/sfxSlider")


func _ready():
	load_slider_values()


func load_slider_values():
	if master_slider:
		master_slider.value = SettingsManager.get_setting("audio", "master_volume", master_slider.value)
	if music_slider:
		music_slider.value = SettingsManager.get_setting("audio", "music_volume", music_slider.value)
	if sfx_slider:
		sfx_slider.value = SettingsManager.get_setting("audio", "sfx_volume", sfx_slider.value)


func _on_masterSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(max(value, 0.001)))
	SettingsManager.save_setting("audio", "master_volume", value)


func _on_musicSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(max(value, 0.001)))
	SettingsManager.save_setting("audio", "music_volume", value)


func _on_sfxSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(max(value, 0.001)))
	SettingsManager.save_setting("audio", "sfx_volume", value)


func _on_Back_pressed():
	if GameManager.prev_scen != "":
		get_tree().change_scene(GameManager.prev_scen)
	else:
		get_tree().change_scene("res://scene/mainMenu.tscn")
