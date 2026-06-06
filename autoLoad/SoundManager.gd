extends Node

var sfx = {}

func _ready():
	sfx = {
		"click": preload("res://Asset/audio/sfx/click.wav"),
		"open_shop": preload("res://Asset/audio/sfx/open_shop.wav"),
		"close_shop": preload("res://Asset/audio/sfx/close_shop.wav"),
		"clean": preload("res://Asset/audio/sfx/clean.wav"),
		"cash": preload("res://Asset/music/soundEffect/transaksi berhasil.mp3"),
		"notification": preload("res://Asset/music/soundEffect/notif hp.wav",
		"transition": preload("res://Asset/audio/sfx/transition.wav")
	}

func play(name):
	if not sfx.has(name):
		print("SFX tidak ditemukan: ", name)
		return

	var player = AudioStreamPlayer.new()
	add_child(player)

	player.stream = sfx[name]
	player.bus = "SFX"
	player.play()

	player.connect("finished", player, "queue_free")
