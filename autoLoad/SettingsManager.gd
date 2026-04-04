extends Node

const SAVE_PATH = "user://settings.cfg" # Disimpan di folder user komputer
var config = ConfigFile.new()

func _ready():
	load_settings()

# Fungsi untuk menyimpan nilai
func save_setting(section, key, value):
	config.set_value(section, key, value)
	config.save(SAVE_PATH)

# Fungsi untuk memuat nilai saat game buka
func load_settings():
	var err = config.load(SAVE_PATH)
	if err != OK:
		return # Jika file belum ada, pakai default saja

	# Load Volume Master
	var master_vol = config.get_value("audio", "master_volume", 0.8)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(master_vol))
