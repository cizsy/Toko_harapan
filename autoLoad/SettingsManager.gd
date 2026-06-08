extends Node

const SAVE_PATH = "user://settings.cfg"

var config = ConfigFile.new()


func _ready():
	load_settings()


func save_setting(section, key, value):
	config.set_value(section, key, value)
	config.save(SAVE_PATH)


func get_setting(section, key, default_value):
	return config.get_value(section, key, default_value)


func load_settings():
	var err = config.load(SAVE_PATH)
	if err != OK:
		return

	# Nilai disimpan dalam skala 0-100 (dari settings.gd)
	# jadi normalize dulu ke 0.0-1.0 sebelum dipakai
	var master_vol = config.get_value("audio", "master_volume", 80)
	var music_vol = config.get_value("audio", "music_volume", 70)
	var sfx_vol = config.get_value("audio", "sfx_volume", 80)

	_set_bus_volume("Master", master_vol)
	_set_bus_volume("Music", music_vol)
	_set_bus_volume("SFX", sfx_vol)


func _set_bus_volume(bus_name, value):
	var index = AudioServer.get_bus_index(bus_name)
	if index == -1:
		return

	# value dalam skala 0-100, normalize ke 0.0-1.0
	var normalized = clamp(float(value) / 100.0, 0.0, 1.0)

	if normalized <= 0.001:
		AudioServer.set_bus_volume_db(index, -80)
		AudioServer.set_bus_mute(index, true)
	else:
		AudioServer.set_bus_mute(index, false)
		AudioServer.set_bus_volume_db(index, linear2db(normalized))
