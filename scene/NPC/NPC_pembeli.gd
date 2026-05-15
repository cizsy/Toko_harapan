extends KinematicBody2D

var kecepatan = 100
var titik_kasir = Vector2(451, 405)
var titik_pintu = Vector2(439, 577)
var target_tujuan = titik_kasir
var sudah_sampai = false
var sedang_pulang = false

var requested_item = "mie"
var request_icons = {
	"mie": "🍜",
	"minyak": "🛢️",
	"beras": "🍚"
}

func _ready():
	randomize()
	set_random_request()
	_update_request_label()

func _physics_process(_delta):
	if not sudah_sampai:
		var arah = (target_tujuan - global_position).normalized()
		move_and_slide(arah * kecepatan)
		
		if global_position.distance_to(target_tujuan) < 10:
			sudah_sampai = true
			if sedang_pulang:
				queue_free()

func set_random_request():
	var items = ["mie", "minyak", "beras"]
	requested_item = items[randi() % items.size()]

func _update_request_label():
	if has_node("RequestLabel"):
		var label = $RequestLabel
		if request_icons.has(requested_item):
			label.text = request_icons[requested_item]
		else:
			label.text = str(requested_item)

func get_requested_item():
	return requested_item

func pulang():
	target_tujuan = titik_pintu
	sudah_sampai = false
	sedang_pulang = true
	print("NPC: Makasih ya, saya pulang dulu!")
