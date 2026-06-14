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

	# Jalan ke kasir = arah atas
	_update_animation(Vector2.UP)


func _physics_process(_delta):
	if not sudah_sampai:
		var arah = (target_tujuan - global_position).normalized()

		move_and_slide(arah * kecepatan)

		# Update animasi sesuai arah gerak
		_update_animation(arah)

		if global_position.distance_to(target_tujuan) < 10:
			sudah_sampai = true

			# Berhenti animasi saat sampai
			_stop_animation()

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
	if sedang_pulang:
		return

	target_tujuan = titik_pintu
	sedang_pulang = true
	sudah_sampai = false

	if has_node("RequestLabel"):
		$RequestLabel.visible = false

	# Pulang ke bawah
	_update_animation(Vector2.DOWN)

	print("NPC: Makasih ya, saya pulang dulu!")


# =====================
# ANIMASI
# =====================

func _update_animation(arah):
	if not has_node("AnimatedSprite"):
		return

	var anim = $AnimatedSprite

	if arah.y < 0:
		anim.play("walk_up")
	elif arah.y > 0:
		anim.play("walk_down")


func _stop_animation():
	if not has_node("AnimatedSprite"):
		return

	$AnimatedSprite.stop()
	$AnimatedSprite.frame = 0
