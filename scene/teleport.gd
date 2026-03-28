extends Area2D

var active = false

func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")

func _on_Area2D_body_entered(body):
	if body.name == "player":
		active = true
	

func _on_Area2D_body_exited(body):
	if body.name == "player":
		active = false

func _process(delta):
	$Interact.visible = active
	if active and Input.is_action_just_pressed("interact"):
		get_tree().change_scene("res://scene/rumah.tscn")
	

	
