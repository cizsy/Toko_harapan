extends Node

var sfx = {}
var sedang_play = {}


func _ready():
	sfx = {
		"cash": preload("res://Asset/music/soundEffect/transaksi berhasil.mp3")
	}


func play(name):
	if not sfx.has(name):
		print("SFX tidak ditemukan: ", name)
		return

	# Anti spam: kalau sound yang sama masih jalan, jangan play ulang
	if sedang_play.has(name) and sedang_play[name] == true:
		return

	var player = AudioStreamPlayer.new()
	add_child(player)

	player.stream = sfx[name]
	player.bus = "SFX"

	sedang_play[name] = true
	player.play()

	player.connect("finished", self, "_on_sfx_finished", [player, name])


func _on_sfx_finished(player, name):
	sedang_play[name] = false

	if is_instance_valid(player):
		player.queue_free()
