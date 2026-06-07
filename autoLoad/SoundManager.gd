extends Node

var sfx = {}

func _ready():
	sfx = {
		"cash": preload("res://Asset/music/soundEffect/transaksi berhasil.mp3")
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
