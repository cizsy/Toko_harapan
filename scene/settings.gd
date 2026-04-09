extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_masterSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),linear2db(value))
	
	SettingsManager.save_setting("audio", "$VBoxContainer/volume/slider/masterSlider", value)

func _on_musicSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),linear2db(value))
	
	SettingsManager.save_setting("audio", "$VBoxContainer/volume/slider/musicSlider", value)

func _on_sfxSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),linear2db(value))

	SettingsManager.save_setting("audio", "$VBoxContainer/volume/slider/sfxSlider", value)


func _on_Back_pressed():
	if GameManager.prev_scen != "":
		get_tree().change_scene(GameManager.prev_scen)
