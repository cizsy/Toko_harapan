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

	var master_vol = config.get_value("audio", "master_volume", 0.8)
	var music_vol = config.get_value("audio", "music_volume", 0.8)
	var sfx_vol = config.get_value("audio", "sfx_volume", 0.8)

	_set_bus_volume("Master", master_vol)
	_set_bus_volume("Music", music_vol)
	_set_bus_volume("SFX", sfx_vol)


func _set_bus_volume(bus_name, value):
	var index = AudioServer.get_bus_index(bus_name)
	if index == -1:
		return

	AudioServer.set_bus_volume_db(index, linear2db(max(value, 0.001)))
